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
#include "WorkerBase.h"
#include "hdl_eng8.h"

WorkerBase::WorkerBase (HardwareManagerPtr in_hw_mgr)
    : m_check_thread (NULL),
      m_hw_mgr (in_hw_mgr),
      m_job_manager_en (false)
{
}

WorkerBase::~WorkerBase()
{
}

int WorkerBase::add_buf (BufPtr in_buf)
{
    m_bufs.push_back (in_buf);

    return m_bufs.size() - 1;
}

void WorkerBase::delete_buf (int buf_id)
{
    if (buf_id >= (int)m_bufs.size()) {
        return;
    }

    m_bufs.erase (m_bufs.begin() + buf_id);
}

void WorkerBase::start()
{
    if (m_job_manager_en) {
        m_hw_mgr->reg_write (ACTION_GLOBAL_CONTROL, 0X00000100);
    } else {
        m_hw_mgr->reg_write (ACTION_GLOBAL_CONTROL, 0X00000000);
    }

    // Clear the interrupt status
    uint32_t reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_INTERRUPT_MASK);
    m_hw_mgr->reg_write (ACTION_GLOBAL_INTERRUPT_CTRL, reg_data);
    reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_INTERRUPT_MASK);
    m_hw_mgr->reg_write (ACTION_GLOBAL_INTERRUPT_CTRL, reg_data);
    reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_INTERRUPT_MASK);
    m_hw_mgr->reg_write (ACTION_GLOBAL_INTERRUPT_CTRL, reg_data);
    reg_data = m_hw_mgr->reg_read (ACTION_GLOBAL_INTERRUPT_MASK);
    m_hw_mgr->reg_write (ACTION_GLOBAL_INTERRUPT_CTRL, reg_data);

    for (int i = 0; i < (int)m_bufs.size(); i++) {
        m_bufs[i]->start();
    }

    m_check_thread = boost::make_shared<boost::thread> (&WorkerBase::check_buf_done, this);

    for (int i = 0; i < (int)m_bufs.size(); i++) {
        m_bufs[i]->join();
    }

    m_check_thread->join();
}
