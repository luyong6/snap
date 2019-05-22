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
#include "WorkerMemCopy.h"
#include "BufMemCopy.h"
#include "hdl_eng8.h"

WorkerMemCopy::WorkerMemCopy (HardwareManagerPtr in_hw_mgr)
    : WorkerBase (in_hw_mgr),
      m_interrupt (true)
{
    m_job_manager_en = false;
}

WorkerMemCopy::~WorkerMemCopy()
{
}

void WorkerMemCopy::set_mode (bool in_interrupt)
{
    m_interrupt = in_interrupt;
}

int WorkerMemCopy::check()
{
    int rc = 0;

    for (int i = 0; i < (int)m_bufs.size(); i++) {
        BufMemCopyPtr buf = boost::dynamic_pointer_cast<BufMemCopy> (m_bufs[i]);

        if (buf->check()) {
            rc = -1;
        }
    }

    return rc;
}

void WorkerMemCopy::check_buf_done()
{
    if (!m_interrupt) {
        std::cout << "Poll mode is not supported yet!" << std::endl;

        for (int i = 0; i < (int)m_bufs.size(); i++) {
            m_bufs[i]->stop();
        }

        return;
    }

    // TODO: workaround the completion queue issue
    void* cq_ptr = malloc (8192);
    m_hw_mgr->reg_write (ACTION_CMPL_ADDR_HI, (uint32_t) (((uint64_t)cq_ptr) >> 32));
    m_hw_mgr->reg_write (ACTION_CMPL_ADDR_LO, (uint32_t) (((uint64_t)cq_ptr) & 0xFFFFFFFF));
    m_hw_mgr->reg_write (ACTION_CMPL_SIZE, (uint32_t) 8192);

    while (true) {
        bool all_done = true;

        for (int i = 0; i < (int)m_bufs.size(); i++) {
            if (0 == m_bufs[i]->get_num_remaining_jobs()) {
                m_bufs[i]->stop();
            } else {
                all_done = false;
            }
        }

        if (all_done) {
            std::cout << "All buffers are done their job, let it go ... " << std::endl;
            break;
        }

        if (m_hw_mgr->wait_interrupt() == 0) {
            boost::lock_guard<boost::mutex> lock (BufBase::m_global_mutex);
            uint32_t reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_INTERRUPT_MASK);

            if (0 == reg_data) {
                std::cout << "WARNING! Interrupt mask is zero!" << std::endl;
            }

            // Clear the interrupt
            m_hw_mgr->reg_write (ACTION_GLOBAL_INTERRUPT_CTRL, reg_data);

            for (int i = 0; i < 8; i++) {
                uint32_t m = (1 << i);

                if (reg_data & m) {
                    // Make sure the transactions are finished before interrupt the buffers (threads)
                    m_bufs[ (i * 2)]->interrupt();
                    m_bufs[ (i * 2) + 1]->interrupt();
                }
            }
        }
    }
}

