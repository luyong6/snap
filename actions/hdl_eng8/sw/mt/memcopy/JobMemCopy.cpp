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
#include "JobMemCopy.h"
#include "hdl_eng8.h"

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

JobMemCopy::JobMemCopy (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr, bool in_debug)
    : JobBase (in_id, in_buf_id, in_hw_mgr, in_debug),
      m_src (NULL),
      m_dest (NULL),
      m_size (0)
{
}

JobMemCopy::~JobMemCopy()
{
    if (NULL != m_src) {
        free (m_src);
    }

    if (NULL != m_dest) {
        free (m_dest);
    }
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

void* JobMemCopy::aalloc (int align, int size)
{
    void* a;
    int size2 = size + align;

    if (posix_memalign ((void**)&a, 4096, size2) != 0) {
        return NULL;
    }

    return a;
}

int JobMemCopy::run()
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

    if (0 != mem_copy()) {
        std::cerr << "Failed to perform memory copy" << std::endl;
        fail();
        return -1;
    }

    done();

    return 0;
}

uint32_t JobMemCopy::reg_addr (uint32_t in_offset)
{
    // TODO: hardcoding the base ?
    return 0x200 + (m_buf_id / 2) * 0x100 + in_offset;
}

int JobMemCopy::mem_init()
{
    uint8_t* ptr_src = (uint8_t*) m_src;
    uint8_t* ptr_tgt = (uint8_t*) m_dest;
    memset (ptr_src, m_id ^ m_buf_id, m_size);
    memset (ptr_tgt, 0, m_size);

    return 0;
}

int JobMemCopy::mem_copy()
{
    if (NULL == m_hw_mgr) {
        std::cerr << "Hardware manager points to NULL, cannot perform memory copy" << std::endl;
        return -1;
    }

    //uint32_t reg_data;
    //uint32_t cnt = 0;

    logging (boost::format ("%s") % "------ Memory Copy Start -------- ");
    logging (boost::format ("SOURCE ADDR:      %#X") % (uint64_t)m_src);
    logging (boost::format ("DESTINATION ADDR: %#X") % (uint64_t)m_dest);
    logging (boost::format ("COPY SIZE:        %d") % m_size);

    logging (boost::format ("%s") % "    Start register config!");

    // source address
    m_hw_mgr->reg_write (reg_addr (ACTION_PATT_INIT_ADDR_L),
                         (uint32_t) (((uint64_t) m_src) & 0xffffffff));
    m_hw_mgr->reg_write (reg_addr (ACTION_PATT_INIT_ADDR_H),
                         (uint32_t) ((((uint64_t) m_src) >> 32) & 0xffffffff));
    logging (boost::format ("%s") % "    Write ACTION_PATT_INIT_ADDR done!");

    // target address
    m_hw_mgr->reg_write (reg_addr (ACTION_PATT_DEST_ADDR_L),
                         (uint32_t) (((uint64_t) m_dest) & 0xffffffff));
    m_hw_mgr->reg_write (reg_addr (ACTION_PATT_DEST_ADDR_H),
                         (uint32_t) ((((uint64_t) m_dest) >> 32) & 0xffffffff));
    logging (boost::format ("%s") % "    Write ACTION_PATT_DEST_ADDR done!");

    // transfer data size (in bytes)
    m_hw_mgr->reg_write (reg_addr (ACTION_PATT_TOTAL_NUM),
                         (uint32_t) (((uint64_t) m_size) & 0xffffffff));
    logging (boost::format ("%s") % "    Write ACTION_PATT_TOTAL_NUM done!");

    // Start memory copy
    logging (boost::format ("%s") % "    Write ACTION_CONTROL for pattern copying!");
    // Write a pulse
    m_hw_mgr->reg_write (reg_addr (ACTION_CONTROL), 0x00000001);
    m_hw_mgr->reg_write (reg_addr (ACTION_CONTROL), 0x00000000);

    return 0;
}

int JobMemCopy::mem_check()
{
    uint8_t* ptr_src = (uint8_t*) m_src;
    uint8_t* ptr_tgt = (uint8_t*) m_dest;
    size_t cnt = 0;
    int rc = 0;

    logging (boost::format ("%s -- size %d") % "Checking!" % m_size);

    if (0 == memcmp (ptr_src, ptr_tgt, m_size)) {
        logging (boost::format ("%s") % "Check PASSED!");
    } else {
        do {
            logging (boost::format ("SOURCE DATA %#x") % (uint32_t) (*ptr_src));
            logging (boost::format ("TARGET DATA %#x") % (uint32_t) (*ptr_tgt));

            if (* (ptr_src) != * (ptr_tgt)) {
                logging (boost::format ("MISCOMPARE on addr %d") % cnt);
                logging (boost::format ("SOURCE DATA %#x") % (uint32_t) (*ptr_src));
                logging (boost::format ("TARGET DATA %#x") % (uint32_t) (*ptr_tgt));
                rc = -1;
            }

            ptr_src++;
            ptr_tgt++;
            cnt++;
        } while (cnt < m_size);
    }

    return rc;
}

int JobMemCopy::allocate (size_t in_size)
{
    // Allocate 4096-byte aligned memory
    m_src = aalloc (64, in_size);
    m_dest = aalloc (64, in_size);

    m_size = in_size;

    if (m_src == NULL || m_dest == NULL) {
        return -1;
    }

    return 0;
}

