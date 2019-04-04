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

#ifndef WORKERBASE_H_h
#define WORKERBASE_H_h

#include <vector>
#include "BufBase.h"

class WorkerBase
{
public:
    // Constructor of the worker base
    WorkerBase();

    // Destructor of the worker base
    ~WorkerBase();

    // Add a buf to the queue
    int add_buf (BufPtr in_buf);

    // Delete a buf from the queue
    void delete_buf (int buf_id);

    // Start all bufs in m_bufs
    void start();

    // Check if all buffers have done their job
    virtual void check_buf_done() = 0;

protected:
    // Queue of the buffers
    std::vector<BufPtr> m_bufs;

    // Thread to check if buffers are done their job
    boost::shared_ptr<boost::thread> m_check_thread;
};

typedef boost::shared_ptr<WorkerBase> WorkerPtr;

#endif
