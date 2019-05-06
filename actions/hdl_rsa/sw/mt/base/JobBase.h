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

#ifndef JOBBASE_H_h
#define JOBBASE_H_h

#include <iostream>
#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>
#include "HardwareManager.h"
#include "libsnap.h"

class JobBase
{
public:
    enum eStatus {
        DONE = 0,
        FAIL,
        UNKNOWN,
        NUM_STATUS
    };

    // Constructor of the job base
    JobBase();
    JobBase (int in_id, int in_buf_id);
    JobBase (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr);
    JobBase (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr, bool in_debug);

    // Destructor of the job base
    ~JobBase();

    // Get the buffer id of this job
    int get_buf_id();

    // Get the job id
    int get_id();

    // Set the status to fail
    void fail();

    // Set the status to done
    void done();

    // Run this job
    virtual int run() = 0;

    // Get the pointer to hardware manager
    HardwareManagerPtr get_hw_mgr();

    // The logging method
    void logging (boost::format & in_fmt);

protected:
    // The ID of this job itself
    int m_id;

    // The buffer id of this job (thread ID)
    int m_buf_id;

    // The status of this job
    eStatus m_status;

    // The hardware manager
    HardwareManagerPtr m_hw_mgr;

    // Flag to control debug message
    bool m_debug;
};

typedef boost::shared_ptr<JobBase> JobPtr;

#endif
