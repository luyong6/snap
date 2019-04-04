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
#include "BufMemCopy.h"
#include "JobMemCopy.h"

boost::mutex BufMemCopy::m_kernel_mutex[8];

BufMemCopy::BufMemCopy()
    : BufBase (0, 600),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopy::BufMemCopy (int in_id)
    : BufBase (in_id),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopy::BufMemCopy (int in_id, int in_timeout)
    : BufBase (in_id, in_timeout),
      m_src (NULL),
      m_dest (NULL),
      m_src_size (0),
      m_dest_size (0)
{
}

BufMemCopy::~BufMemCopy()
{
    if (NULL != m_src) {
        free (m_src);
    }

    if (NULL != m_dest) {
        free (m_dest);
    }
}

void* BufMemCopy::get_src_ptr()
{
    return m_src;
}

void* BufMemCopy::get_dest_ptr()
{
    return m_dest;
}

size_t BufMemCopy::get_src_size()
{
    return m_src_size;
}

size_t BufMemCopy::get_dest_size()
{
    return m_dest_size;
}

void* BufMemCopy::aalloc (int align, int size)
{
    void* a;
    int size2 = size + align;

    if (posix_memalign ((void**)&a, 4096, size2) != 0) {
        return NULL;
    }

    return a;
}

int BufMemCopy::allocate (size_t in_src_size, size_t in_dest_size)
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

void BufMemCopy::work_with_job (JobPtr in_job)
{
    // Two buffers works on the same kernel, so block the other buffer from touching
    // the kernel until the current one finished the job
    boost::lock_guard<boost::mutex> lock (BufMemCopy::m_kernel_mutex[m_id / 2]);

    JobMemCopyPtr job = boost::dynamic_pointer_cast<JobMemCopy> (in_job);

    if (job == NULL) {
        std::cerr << "Failed to get pointer to JobMemCopy" << std::endl;
        return;
    }

    if (m_src == NULL || m_dest == NULL) {
        std::cerr << "NULL src or dest pointer in BufMemCopy" << std::endl;
        return;
    }

    if (m_dest_size < m_src_size) {
        std::cerr << "Destination buffer size should be larger than source buffer size" << std::endl;
        std::cerr << "Destination buffer size " << std::dec << m_dest_size << std::endl;
        std::cerr << "Source buffer size " << std::dec << m_src_size << std::endl;
        return;
    }

    job->set_src (m_src);
    job->set_dest (m_dest);
    job->set_size (m_src_size);

    do {
        // Lock between buffers (each buffer would have a thread working on it).
        // At one time, only 1 thread is allowed to touching the AXI-lite bus
        boost::lock_guard<boost::mutex> lock (BufMemCopy::m_global_mutex);

        if (0 != job->run()) {
            std::cerr << "Failed to run the JobMemCopy" << std::endl;
            return;
        }
    } while (0);

    // Wait for interrupt
    if (0 != wait_interrupt()) {
        std::cerr << "Failed to wait interrupt for JobMemCopy" << std::endl;
    }

    if (0 != job->mem_check()) {
        std::cerr << "ERROR! Check failed on memory copy" << std::endl;
        job->fail();
        return;
    }

    return;
}
