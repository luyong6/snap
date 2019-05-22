/*
 * Copyright 2017 International Business Machines
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

#ifndef __HDL_ENG8__
#define __HDL_ENG8__

/*
 * This makes it obvious that we are influenced by HLS details ...
 * The ACTION control bits are defined in the following file.
 */
//#include <snap_hls_if.h>
#define ACTION_TYPE_HDL_ENG8     0x10140003 /* Action Type */
#define ACTION_GLOBAL_INTERRUPT_CTRL   0x30
#define ACTION_GLOBAL_INTERRUPT_MASK   0x34
#define ACTION_STATUS_L                0x30
#define ACTION_STATUS_H                0x34

#define ACTION_CONTROL                 0x38

//Source Address
#define ACTION_PATT_INIT_ADDR_L        0x48
#define ACTION_PATT_INIT_ADDR_H        0x4C
//Target Address
#define ACTION_PATT_DEST_ADDR_L        0x50
#define ACTION_PATT_DEST_ADDR_H        0x54
//Size number (in bytes)
#define ACTION_PATT_TOTAL_NUM          0x68
//Additional waiting time (in cycles)
#define ACTION_ADD_WAIT_CYCLE          0x58

// Registers for job manager mode
#define ACTION_GLOBAL_CONTROL          0x38
#define ACTION_INIT_ADDR_HI            0x3C
#define ACTION_INIT_ADDR_LO            0x40
#define ACTION_GLOBAL_DONE             0x44
#define ACTION_CMPL_ADDR_HI            0x68
#define ACTION_CMPL_ADDR_LO            0x6C
#define ACTION_CMPL_SIZE               0x70

#endif  /* __HDL_ENG8__ */
