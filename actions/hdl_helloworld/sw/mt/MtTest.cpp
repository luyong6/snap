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

#include <iostream>
#include "boost/make_shared.hpp"
#include "boost/shared_ptr.hpp"
#include "MtTest.h"
#include "WorkerMemCopy.h"
#include "BufMemCopy.h"
#include "JobMemCopy.h"
#include "HardwareManager.h"

int mt_test_16_threads()
{
    WorkerMemCopyPtr worker = boost::make_shared<WorkerMemCopy>();
    HardwareManagerPtr hw_mgr =  boost::make_shared<HardwareManager> (0);
    // Initialize the hardware
    if (hw_mgr->init()) {
        std::cerr << "Failed to initialize card" << std::endl;
        return -1;
    }

    // Create 16 buffers, each have 1 job to perform memory copy
    for (int i = 0; i < 16; i++) {
        BufMemCopyPtr buf = boost::make_shared<BufMemCopy> (i, 1000);

        // 4K source and 4K destination
        if (buf->allocate (4096, 4096)) {
            std::cerr << "Failed to allocate buffer for buf " << i << std::endl;
            return -1;
        }

        // Create 1 job for each buf
        JobMemCopyPtr job = boost::make_shared<JobMemCopy> (0, i, hw_mgr);
        buf->add_job (job);

        // Add buf to worker
        worker->add_buf (buf);
    }

    // Start work
    worker->start();

    return 0;
}
