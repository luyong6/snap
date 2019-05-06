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

#include <malloc.h>
#include "BufMemCopyJM.h"
#include "JobMemCopyJM.h"

BufMemCopyJM::BufMemCopyJM()
    : BufBase (0, 600),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopyJM::BufMemCopyJM (int in_id)
    : BufBase (in_id),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopyJM::BufMemCopyJM (int in_id, int in_timeout)
    : BufBase (in_id, in_timeout),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopyJM::~BufMemCopyJM()
{
    if (NULL != m_src) {
        free (m_src);
    }

    if (NULL != m_dest) {
        free (m_dest);
    }
}

void* BufMemCopyJM::get_src_ptr()
{
    return m_src;
}

void* BufMemCopyJM::get_dest_ptr()
{
    return m_dest;
}

size_t BufMemCopyJM::get_src_size()
{
    return m_src_size;
}

size_t BufMemCopyJM::get_dest_size()
{
    return m_dest_size;
}

void* BufMemCopyJM::aalloc (int align, int size)
{
    void* a;
    int size2 = size + align;

    if (posix_memalign ((void**)&a, 4096, size2) != 0) {
        return NULL;
    }

    return a;
}

int BufMemCopyJM::allocate (size_t in_src_size, size_t in_dest_size)
{
    // Allocate 4096-byte aligned memory
    m_src = aalloc (64, in_src_size);
    m_dest = aalloc (64, in_dest_size);

    m_src_size = in_src_size;
    m_dest_size = in_dest_size;

    if (m_src == NULL || m_dest == NULL) {
        return -1;
    }

    return 0;
}

void BufMemCopyJM::work_with_job (JobPtr in_job)
{
    JobMemCopyJMPtr job = boost::dynamic_pointer_cast<JobMemCopyJM> (in_job);

    if (job == NULL) {
        std::cerr << "Failed to get pointer to JobMemCopyJM" << std::endl;
        return;
    }

    //if (m_src == NULL || m_dest == NULL) {
    //    std::cerr << "NULL src or dest pointer in BufMemCopyJM" << std::endl;
    //    return;
    //}

    //if (m_dest_size < m_src_size) {
    //    std::cerr << "Destination buffer size should be larger than source buffer size" << std::endl;
    //    std::cerr << "Destination buffer size " << std::dec << m_dest_size << std::endl;
    //    std::cerr << "Source buffer size " << std::dec << m_src_size << std::endl;
    //    return;
    //}

    //job->set_src (m_src);
    //job->set_dest (m_dest);
    //job->set_size (m_src_size);

    do {
        if (0 != job->run()) {
            std::cerr << "Failed to run the JobMemCopyJM" << std::endl;
            return;
        }
    } while (0);

    return;
}

int BufMemCopyJM::check()
{
    int err_jobs = 0;

    for (size_t i = 0; i < m_jobs.size(); i++) {
        JobMemCopyJMPtr job = boost::dynamic_pointer_cast<JobMemCopyJM> (m_jobs[i]);

        if (job->mem_check()) {
            err_jobs ++;
        };
    }

    std::cout << "Memory copy result error on " << std::dec << err_jobs << " jobs!" << std::endl;
    return err_jobs;
}
