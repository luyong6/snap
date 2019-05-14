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

#include "boost/make_shared.hpp"
#include "BufBase.h"

boost::mutex BufBase::m_global_mutex;

BufBase::BufBase()
    : m_thread (NULL),
      m_id (0),
      m_timeout (600),
      m_stopped (false),
      m_current_job_idx (0)
{
}

BufBase::BufBase (int in_id)
    : m_thread (NULL),
      m_id (in_id),
      m_timeout (600),
      m_stopped (false),
      m_current_job_idx (0)
{
}

BufBase::BufBase (int in_id, int in_timeout)
    : m_thread (NULL),
      m_id (in_id),
      m_timeout (in_timeout),
      m_stopped (false),
      m_current_job_idx (0)
{
}

BufBase::~BufBase()
{
}

int BufBase::get_id()
{
    return m_id;
}

void BufBase::set_id (int in_id)
{
    m_id = in_id;
}

int BufBase::add_job (JobPtr in_job)
{
    m_jobs.push_back (in_job);

    return m_jobs.size() - 1;
}

void BufBase::delete_job (int job_id)
{
    if (job_id >= (int)m_jobs.size()) {
        return;
    }

    m_jobs.erase (m_jobs.begin() + job_id);
}

int BufBase::start()
{
    if (NULL != m_thread) {
        std::cerr << "m_thread is not NULL on start" << std::endl;
    } else {
        m_thread = boost::make_shared<boost::thread> (&BufBase::work, this);
    }

    return 0;
}

void BufBase::work()
{
    m_stopped = false;

    m_current_job_idx = 0;

    while (true) {
        if (m_current_job_idx < (int) m_jobs.size()) {
            JobPtr job = m_jobs[m_current_job_idx];
            work_with_job (job);
            m_current_job_idx++;
        }

        boost::this_thread::interruption_point();
    }
}

int BufBase::stop()
{
    if (m_stopped) {
        return m_jobs.size();
    }

    if (m_thread != NULL) {
        m_thread->interrupt();
    }

    m_stopped = true;

    std::cout << "BUF[" <<
              std::setfill ('0') << std::setw (2)
              << m_id << "] finished work!" << std::endl;

    // Return the number of remaining jobs
    return m_jobs.size();
}

void BufBase::join()
{
    if (m_thread != NULL) {
        m_thread->join();
    }
}

int BufBase::wait_interrupt()
{
    boost::mutex::scoped_lock lock (m_mutex);

    int time = m_timeout;

    while (0 < (time = m_cond.timed_wait (lock,
                                          boost::get_system_time()
                                          + boost::posix_time::seconds (time)))) {
        return 0;
    }

    std::cerr << "BufBase::wait_interrupt timeout on buf" << std::dec << m_id << std::endl;
    return -1;
}

void BufBase::interrupt()
{
    boost::lock_guard<boost::mutex> lock (m_mutex);

    m_cond.notify_all();
}

int BufBase::get_num_remaining_jobs()
{
    return (int) ((int)m_jobs.size() - m_current_job_idx);
}
