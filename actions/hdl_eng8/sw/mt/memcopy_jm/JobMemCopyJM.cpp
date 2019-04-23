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
#include "time.h"
#include "JobMemCopyJM.h"
#include "hdl_eng8.h"

JobMemCopyJM::JobMemCopyJM()
    : JobBase(),
      m_src (NULL),
      m_dest (NULL),
      m_size (0),
      m_worker (NULL)
{
}

JobMemCopyJM::JobMemCopyJM (int in_id, int in_buf_id)
    : JobBase (in_id, in_buf_id),
      m_src (NULL),
      m_dest (NULL),
      m_size (0),
      m_worker (NULL)
{
}

JobMemCopyJM::JobMemCopyJM (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr)
    : JobBase (in_id, in_buf_id, in_hw_mgr),
      m_src (NULL),
      m_dest (NULL),
      m_size (0),
      m_worker (NULL)
{
}

JobMemCopyJM::JobMemCopyJM (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr, bool in_debug)
    : JobBase (in_id, in_buf_id, in_hw_mgr, in_debug),
      m_src (NULL),
      m_dest (NULL),
      m_size (0),
      m_worker (NULL)
{
}

JobMemCopyJM::~JobMemCopyJM()
{
}

void JobMemCopyJM::set_src (void* in_src)
{
    m_src = in_src;
}

void JobMemCopyJM::set_dest (void* in_dest)
{
    m_dest = in_dest;
}

void JobMemCopyJM::set_size (size_t in_size)
{
    m_size = in_size;
}

int JobMemCopyJM::run()
{
    if (NULL == m_src || NULL == m_dest) {
        std::cerr << "Address of source buffer or destination buffer is NULL" << std::endl;
        fail();
        return -1;
    }

    if (0 == m_size) {
        std::cerr << "Copy size is zero, nothing to do" << std::endl;
        fail();
        return -1;
    }

    //if (0 != mem_init()) {
    //    std::cerr << "Failed to perform memory init" << std::endl;
    //    fail();
    //    return -1;
    //}

    if (0 != mem_copy()) {
        std::cerr << "Failed to perform memory copy" << std::endl;
        fail();
        return -1;
    }

    done();

    return 0;
}

void JobMemCopyJM::set_worker (WorkerMemCopyJMPtr in_worker)
{
    m_worker = in_worker;
}

WorkerMemCopyJMPtr JobMemCopyJM::get_worker ()
{
    return m_worker;
}

void* JobMemCopyJM::aalloc (int align, int size)
{
    void* a;
    int size2 = size + align;

    if (posix_memalign ((void**)&a, 4096, size2) != 0) {
        return NULL;
    }

    return a;
}

int JobMemCopyJM::mem_init()
{
    uint8_t* ptr_src = (uint8_t*) m_src;
    uint8_t* ptr_tgt = (uint8_t*) m_dest;
    size_t cnt = 0;
    srand ((unsigned) time (0));

    do {
        * (ptr_src++) = rand() % 256;
        * (ptr_tgt++) = 0;

        cnt++;
    } while (cnt < m_size);

    return 0;
}

int JobMemCopyJM::mem_copy()
{
    if (NULL == m_worker) {
        std::cerr << "Worker points to NULL, cannot perform memory copy" << std::endl;
        return -1;
    }

    //logging (boost::format ("%s") % "------ Memory Copy Start -------- ");
    //logging (boost::format ("SOURCE ADDR:      %#X") % (uint64_t)m_src);
    //logging (boost::format ("DESTINATION ADDR: %#X") % (uint64_t)m_dest);
    //logging (boost::format ("COPY SIZE:        %d") % m_size);

    //logging (boost::format ("%s") % "    Prepare job descriptor!");

    JobDescriptor* job_desc_ptr = (JobDescriptor*) aalloc (64, sizeof(JobDescriptor));
    memset (job_desc_ptr, 0, sizeof(JobDescriptor));

    job_desc_ptr->copy_length = (uint32_t) m_size;
    job_desc_ptr->mem_src = (uint64_t) m_src;
    job_desc_ptr->mem_dest = (uint64_t) m_dest;
    job_desc_ptr->user_config = 100;

    m_worker->append_job_desc (job_desc_ptr);

    //logging (boost::format ("%s") % "    Job descriptor appended!");
    return 0;
}

int JobMemCopyJM::mem_check()
{
    uint8_t* ptr_src = (uint8_t*) m_src;
    uint8_t* ptr_tgt = (uint8_t*) m_dest;
    size_t cnt = 0;
    int rc = 0;

    do {
        if (* (ptr_src) != * (ptr_tgt)) {
            logging (boost::format ("MISCOMPARE on addr %d") % cnt);
            logging (boost::format ("SOURCE DATA %#x") % (uint32_t) (*ptr_src));
            logging (boost::format ("TARGET DATA %#x") % (uint32_t) (*ptr_tgt));
            ptr_src++;
            ptr_tgt++;
            rc = 1;
        }

        cnt++;
    } while (cnt < m_size);

    return rc;
}

