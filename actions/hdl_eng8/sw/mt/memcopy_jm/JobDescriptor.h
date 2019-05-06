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

#ifndef JOBDESCRIPTOR_H_h
#define JOBDESCRIPTOR_H_h
// Descriptor used by hardware job manager
typedef struct {
    uint32_t header;         // 4
    uint32_t copy_length;    // 8
    uint64_t mem_src;        // 16
    uint64_t mem_dest;       // 24
    uint64_t next_desc;      // 32
    uint32_t user_config_len;// 36
    uint32_t user_config_0;  // 40
    uint32_t user_config_1;  // 44
    uint32_t user_config_2;  // 48
    uint32_t user_config_3;  // 52
    uint32_t user_config_4;  // 56
    uint32_t user_config_5;  // 60
    uint32_t user_config_6;  // 64
} JobDescriptor;

#endif
