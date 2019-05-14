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

#ifndef MT_TEST_H
#define MT_TEST_H

#ifdef __cplusplus
extern "C" {
#endif
enum test_mode {POLL = 0, INTERRUPT, INVALID};
typedef struct {
    int card_no;
    int job_num;
    int buf_num;
    uint32_t memcopy_size;
    int timeout;
    enum test_mode mode;
    bool debug;
} test_params;

void print_test_params (test_params in_params);

int mt_test_16_threads (test_params in_test_params);
int mt_jm_test_16_threads (test_params in_test_params);
#ifdef __cplusplus
}
#endif

#endif
