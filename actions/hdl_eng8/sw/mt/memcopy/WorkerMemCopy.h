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

#ifndef WORKERMEMCOPY_H_h
#define WORKERMEMCOPY_H_h

#include <iostream>
#include "WorkerBase.h"

class WorkerMemCopy : public WorkerBase
{
public:
    // Constructor of the worker base
    WorkerMemCopy (HardwareManagerPtr in_hw_mgr);

    // Destructor of the worker base
    ~WorkerMemCopy();

    // Check if all buffers have done their job
    virtual void check_buf_done();

    // Set if we are going to use interrupt or polling
    void set_mode (bool in_interrupt);

    // Check the result
    int check();

private:
    // Use interrupt or poll to check buffer done?
    bool m_interrupt;
};

typedef boost::shared_ptr<WorkerMemCopy> WorkerMemCopyPtr;

#endif
