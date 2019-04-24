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

#include "HardwareManager.h"
#include "hdl_eng8.h"

HardwareManager::HardwareManager (int in_card_num)
    : m_card_num (in_card_num),
      m_capi_card (NULL),
      m_capi_action (NULL),
      m_attach_flags ((snap_action_flag_t)0),
      m_timeout_sec (0),
      m_timeout_usec (1000)
{
}

HardwareManager::HardwareManager (int in_card_num, int in_timeout_sec, int in_timeout_usec)
    : m_card_num (in_card_num),
      m_capi_card (NULL),
      m_capi_action (NULL),
      m_attach_flags ((snap_action_flag_t)0),
      m_timeout_sec (in_timeout_sec),
      m_timeout_usec (in_timeout_usec)
{
}

HardwareManager::~HardwareManager()
{
    cleanup();
}

int HardwareManager::init()
{
    std::stringstream ss;
    // Prepare the card and action
    ss << "/dev/cxl/afu" << m_card_num << ".0s";
    m_capi_card = snap_card_alloc_dev (ss.str().c_str(), SNAP_VENDOR_ID_IBM, SNAP_DEVICE_ID_SNAP);

    if (NULL == m_capi_card) {
        std::cerr << "Failed to open Card: " << m_card_num << std::endl;
        return -1;
    }

    m_capi_action = snap_attach_action (m_capi_card, ACTION_TYPE_HDL_ENG8,
                                        m_attach_flags, 5 * ((m_timeout_sec == 0) ? 1 : m_timeout_sec));

    if (NULL == m_capi_action) {
        std::cerr << "Failed to attach action!" << std::endl;
        return -1;
    }

    return 0;
}

void HardwareManager::reg_write (uint32_t in_addr, uint32_t in_data)
{
    int rc;

    rc = snap_mmio_write32 (m_capi_card, (uint64_t)in_addr, in_data);

    if (0 != rc) {
        std::cerr << "Write MMIO 32 Err" << std::endl;
    }

    return;
}

uint32_t HardwareManager::reg_read (uint32_t in_addr)
{
    int rc;
    uint32_t data;

    rc = snap_mmio_read32 (m_capi_card, (uint64_t)in_addr, &data);

    if (0 != rc) {
        std::cerr << "Read MMIO 32 Err" << std::endl;
    }

    return data;
}

void HardwareManager::cleanup()
{
    snap_detach_action (m_capi_action);
    snap_card_free (m_capi_card);
}

int HardwareManager::wait_interrupt()
{
    if (snap_action_wait_interrupt (m_capi_action, m_timeout_sec, m_timeout_usec)) {
        //std::cout << "Retry waiting interrupt ... " << std::endl;
        return -1;
    }

    return 0;
}
