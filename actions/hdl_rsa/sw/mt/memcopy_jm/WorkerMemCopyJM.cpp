/*
 * Copyright 2019 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <boost/chrono.hpp>
#include "WorkerMemCopyJM.h"
#include "BufMemCopyJM.h"
#include "hdl_eng8.h"

WorkerMemCopyJM::WorkerMemCopyJM (HardwareManagerPtr in_hw_mgr, bool in_debug)
    : WorkerBase (in_hw_mgr),
      m_interrupt (true),
      m_job_desc_head (NULL),
      m_job_desc_tail (NULL),
      m_job_desc_count (0),
      m_job_start_threshold (16),
      m_job_started (false),
      m_debug (in_debug)
{
    m_job_manager_en = true;
}

WorkerMemCopyJM::~WorkerMemCopyJM()
{
    JobDescriptor* job_desc_ptr = (JobDescriptor*) m_job_desc_head;

    while (job_desc_ptr != NULL) {
        JobDescriptor* next_job_desc_ptr = (JobDescriptor*) job_desc_ptr->next_desc;
        free (job_desc_ptr);
        job_desc_ptr = next_job_desc_ptr;
    };
}

void WorkerMemCopyJM::set_mode (bool in_interrupt)
{
    m_interrupt = in_interrupt;
}

void WorkerMemCopyJM::set_job_start_threshold (int in_threshold)
{
    m_job_start_threshold = in_threshold;
}

int WorkerMemCopyJM::check()
{
    int total_num = 0;

    for (int i = 0; i < (int)m_bufs.size(); i++) {
        BufMemCopyJMPtr buf = boost::dynamic_pointer_cast<BufMemCopyJM> (m_bufs[i]);

        int rc = buf->check();
        total_num += rc;
    }

    std::cout << "Total error on " << std::dec << total_num << " jobs!" << std::endl;

    return total_num;
}

void WorkerMemCopyJM::append_job_desc (void* in_job_desc)
{
    boost::lock_guard<boost::mutex> lock (m_job_desc_mutex);

    if (0 == m_job_desc_count) {
        m_job_desc_head = in_job_desc;
        m_job_desc_tail = in_job_desc;
    } else {
        JobDescriptor* job_desc_ptr = (JobDescriptor*) m_job_desc_tail;
        job_desc_ptr->next_desc = (uint64_t) in_job_desc;
        m_job_desc_tail = in_job_desc;
    }

    m_job_desc_count ++;
}

void WorkerMemCopyJM::dump_job_desc()
{
    int count = 0;
    JobDescriptor* job_desc_ptr = (JobDescriptor*) m_job_desc_head;

    while (job_desc_ptr != NULL) {
        std::cout << "DESC[" << std::setfill ('0') << std::setw (4) << std::dec << count << "]" << std::endl;
        std::cout << "PTR       0x" << std::setfill ('0') << std::setw (4) << std::hex << (uint64_t) job_desc_ptr << std::endl;
        std::cout << "HEADER    0x" << std::setfill ('0') << std::setw (4) << std::hex << (uint32_t) job_desc_ptr->header << std::endl;
        std::cout << "LENGTH    0x" << std::setfill ('0') << std::setw (4) << std::hex << (uint32_t) job_desc_ptr->copy_length << std::endl;
        std::cout << "SRC       0x" << std::setfill ('0') << std::setw (8) << std::hex << (uint64_t) job_desc_ptr->mem_src << std::endl;
        std::cout << "DEST      0x" << std::setfill ('0') << std::setw (8) << std::hex << (uint64_t) job_desc_ptr->mem_dest << std::endl;
        std::cout << "NEXT      0x" << std::setfill ('0') << std::setw (8) << std::hex << (uint64_t) job_desc_ptr->next_desc << std::endl;
        std::cout << "USER LEN  0x" << std::setfill ('0') << std::setw (4) << std::hex << (uint32_t) job_desc_ptr->user_config_len << std::endl;
        std::cout << "USER CONF 0x" << std::setfill ('0') << std::setw (4) << std::hex << (uint32_t) job_desc_ptr->user_config << std::endl;
        job_desc_ptr = (JobDescriptor*) job_desc_ptr->next_desc;
        count ++;
    };
}

void WorkerMemCopyJM::check_buf_done()
{
    if (m_interrupt) {
        std::cout << "Interrupt mode is not supported yet!" << std::endl;
    } else {
        int count = 0;

        while (true) {
            // Start the job manager when the number of job desc reaches threshold
            if (!m_job_started) {
                boost::lock_guard<boost::mutex> lock (m_job_desc_mutex);

                if (m_job_desc_count >= m_job_start_threshold) {
                    m_hw_mgr->reg_write (ACTION_INIT_ADDR_HI, (uint32_t) (((uint64_t)m_job_desc_head) >> 32));
                    m_hw_mgr->reg_write (ACTION_INIT_ADDR_LO, (uint32_t) (((uint64_t)m_job_desc_head) & 0xFFFFFFFF));
                    m_hw_mgr->reg_write (ACTION_GLOBAL_CONTROL, 0X00000101);
                    m_hw_mgr->reg_write (ACTION_GLOBAL_CONTROL, 0X00000100);
                    m_job_started = true;

                    if (m_debug) {
                        dump_job_desc();
                    }

                    std::cout << "Worker -- Job started with " << std::dec << m_job_desc_count << " jobs" << std::endl;
                }

            } else {
                uint32_t reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_DONE) & 0x00000001;

                // Poll the status done bit
                if (1 == reg_data) {
                    break;
                } else {
                    boost::this_thread::sleep_for (boost::chrono::microseconds{100});
                    count++;
                }
            }

            boost::this_thread::interruption_point();
        }
    }

    for (int i = 0; i < (int)m_bufs.size(); i++) {
        m_bufs[i]->stop();
    }

    for (int i = 0; i < 8; i++) {
        uint32_t reg_data = m_hw_mgr->reg_read (0x48 + (i * 4));
        std::cout << "Kernel " << std::dec << i << " processed " << reg_data << " jobs." << std::endl;
    }

    uint32_t reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_DONE) & 0x00000001;
    std::cout << "Done " << reg_data << std::endl;

    std::cout << "Worker -- All jobs done" << std::endl;

}

