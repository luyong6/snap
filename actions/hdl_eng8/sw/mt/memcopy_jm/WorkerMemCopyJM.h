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

#ifndef WORKERMEMCOPYJM_H_h
#define WORKERMEMCOPYJM_H_h

#include <iostream>
#include "WorkerBase.h"
#include "JobDescriptor.h"

class WorkerMemCopyJM : public WorkerBase
{
public:
    // Constructor of the worker base
    WorkerMemCopyJM (HardwareManagerPtr in_hw_mgr, bool in_debug);

    // Destructor of the worker base
    ~WorkerMemCopyJM();

    // Check if all buffers have done their job
    virtual void check_buf_done();

    // Set if we are going to use interrupt or polling
    void set_mode (bool in_interrupt);

    // Update the job descriptor tail and count
    void append_job_desc (void* in_job_desc);

    // Print the job descriptor list
    void dump_job_desc();

    // Check the result
    int check();

    // Set the job descriptor start threshold
    void set_job_start_threshold (int in_threshold);

    // Set up the completion queue
    int setup_completion_queue (int in_size);

    // Check if the result in completion queue is expected
    int check_completion_queue ();

private:
    // Use interrupt or poll to check buffer done?
    bool m_interrupt;

    // The mutex to guard job descriptors adding from buffers
    boost::mutex m_job_desc_mutex;

    // The pointer to the head and tail of job descriptor list
    // (the first and last job descriptor in the list)
    // Update to this pointer should be guarded by mutex (m_job_desc_mutex)
    void* m_job_desc_head;
    void* m_job_desc_tail;

    // The pointer to completion queue
    void* m_completion_queue_ptr;

    // The size of completion queue (in bytes)
    int m_completion_queue_size;

    // Total count of job descriptors
    int m_job_desc_count;

    // The threshold to start hardware job manager
    // When the m_job_desc_count is larger than this threshold,
    // hardware job manager will be started
    int m_job_start_threshold;

    // The flag to indicate the job manager has been started
    bool m_job_started;

    // Debug flag
    bool m_debug;
};

typedef boost::shared_ptr<WorkerMemCopyJM> WorkerMemCopyJMPtr;

#endif
