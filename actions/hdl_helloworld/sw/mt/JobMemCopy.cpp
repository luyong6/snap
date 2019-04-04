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
#include "JobMemCopy.h"
#include "hdl_helloworld.h"

JobMemCopy::JobMemCopy()
    : JobBase(),
      m_src (NULL),
      m_dest (NULL),
      m_size (0)
{
}

JobMemCopy::JobMemCopy (int in_id, int in_buf_id)
    : JobBase (in_id, in_buf_id),
      m_src (NULL),
      m_dest (NULL),
      m_size (0)
{
}

JobMemCopy::JobMemCopy (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr)
    : JobBase (in_id, in_buf_id, in_hw_mgr),
      m_src (NULL),
      m_dest (NULL),
      m_size (0)
{
}

JobMemCopy::~JobMemCopy()
{
}

void JobMemCopy::set_src (void* in_src)
{
    m_src = in_src;
}

void JobMemCopy::set_dest (void* in_dest)
{
    m_dest = in_dest;
}

void JobMemCopy::set_size (size_t in_size)
{
    m_size = in_size;
}

int JobMemCopy::run()
{
    if (NULL == m_src || NULL == m_dest) {
        std::cerr << "Address of source buffer or destination buffer is NULL" << std::endl;
        return -1;
    }

    if (0 == m_size) {
        std::cerr << "Copy size is zero, nothing to do" << std::endl;
        return -1;
    }

    if (0 != mem_copy()) {
        std::cerr << "Failed to perform memory copy" << std::endl;
        return -1;
    }

    return 0;
}

int JobMemCopy::mem_copy()
{
    if (NULL == m_hw_mgr) {
        std::cerr << "Hardware manager points to NULL, cannot perform memory copy" << std::endl;
        return -1;
    }

    uint32_t reg_data;
    uint32_t cnt = 0;

    logging (boost::format("%s") % "------ Memory Copy Start -------- ");
    logging (boost::format("SOURCE ADDR:      %#X") % (uint64_t)m_src);
    logging (boost::format("DESTINATION ADDR: %#X") % (uint64_t)m_dest);
    logging (boost::format("COPY SIZE:        %d") % m_size);

    logging (boost::format("%s") % "    Start register config!");

    // source address
    m_hw_mgr->reg_write (ACTION_PATT_INIT_ADDR_L,
                  (uint32_t) (((uint64_t) m_src) & 0xffffffff));
    m_hw_mgr->reg_write (ACTION_PATT_INIT_ADDR_H,
                  (uint32_t) ((((uint64_t) m_src) >> 32) & 0xffffffff));
    logging (boost::format("%s") % "    Write ACTION_PATT_INIT_ADDR done!");

    // target address
    m_hw_mgr->reg_write (ACTION_PATT_DEST_ADDR_L,
                  (uint32_t) (((uint64_t) m_dest) & 0xffffffff));
    m_hw_mgr->reg_write (ACTION_PATT_DEST_ADDR_H,
                  (uint32_t) ((((uint64_t) m_dest) >> 32) & 0xffffffff));
    logging (boost::format("%s") % "    Write ACTION_PATT_DEST_ADDR done!");

    // transfer data size (in bytes)
    m_hw_mgr->reg_write (ACTION_PATT_TOTAL_NUM,
                  (uint32_t) (((uint64_t) m_size) & 0xffffffff));
    logging (boost::format("%s") % "    Write ACTION_PATT_TOTAL_NUM done!");

    // Start memory copy
    logging (boost::format("%s") % "    Write ACTION_CONTROL for pattern copying!");
    // Write a pulse
    m_hw_mgr->reg_write (ACTION_CONTROL, 0x00000001);
    m_hw_mgr->reg_write (ACTION_CONTROL, 0x00000000);

    // Poll status for memcpy done signal
    cnt = 0;

    do {
        reg_data = m_hw_mgr->reg_read (ACTION_STATUS_L);

        // Status[0]
        if ((reg_data & 0x00000001) == 1) {
            logging (boost::format("%s") % "Memcopy done!");
            break;
        }

        logging (boost::format("Polling Status reg with 0X%X") % reg_data);
        cnt++;
    } while (1);//(cnt < 100);

    cnt = 0;

    do {
        reg_data = m_hw_mgr->reg_read (ACTION_STATUS_L);

        logging (boost::format("Draining Status reg with 0X%X") % reg_data);
        cnt++;
    } while (cnt < 2);

    return 0;
}
