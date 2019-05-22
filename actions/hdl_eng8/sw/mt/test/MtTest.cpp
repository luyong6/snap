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

#include "boost/make_shared.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/chrono.hpp"
#include "MtTest.h"
#include "WorkerMemCopy.h"
#include "BufMemCopy.h"
#include "JobMemCopy.h"
#include "HardwareManager.h"
#include "WorkerMemCopyJM.h"
#include "BufMemCopyJM.h"
#include "JobMemCopyJM.h"

using namespace boost::chrono;

int mt_test_16_threads (test_params in_params)
{
    std::cout << "Running without job manager" << std::endl;

    HardwareManagerPtr hw_mgr =  boost::make_shared<HardwareManager> (in_params.card_no, 0, 1000);
    WorkerMemCopyPtr worker = boost::make_shared<WorkerMemCopy> (hw_mgr);
    worker->set_mode (INTERRUPT == in_params.mode);

    // Initialize the hardware
    if (hw_mgr->init()) {
        std::cerr << "Failed to initialize card" << std::endl;
        return -1;
    }

    uint64_t total_bytes = (uint64_t)in_params.buf_num * (uint64_t)in_params.job_num * (uint64_t)in_params.memcopy_size;

    std::cout << "Setting up jobs." << std::endl;

    // Create buffers
    for (int i = 0; i < in_params.buf_num; i++) {
        BufMemCopyPtr buf = boost::make_shared<BufMemCopy> (i, 1000);

        // Create jobs for each buffer
        for (int j = 0; j < in_params.job_num; j++) {
            JobMemCopyPtr job = boost::make_shared<JobMemCopy> (j, i, hw_mgr, in_params.debug);

            if (job->allocate (in_params.memcopy_size)) {
                std::cerr << "Failed to allocate buffer for buf "
                          << std::dec << i << " job " << j << std::endl;
                return -1;
            }

            job->mem_init();

            buf->add_job (job);
        }

        // Add buf to worker
        worker->add_buf (buf);
    }

    std::cout << "Finish setting up jobs." << std::endl;

    high_resolution_clock::time_point t_start = high_resolution_clock::now();
    // Start work
    worker->start();
    high_resolution_clock::time_point t_end = high_resolution_clock::now();

    auto duration = duration_cast<microseconds> (t_end - t_start).count();
    std::cout << "Work finished after " << duration << " microseconds (us)" << std::endl;
    double bandwidth = ((double)total_bytes / 1024.0 / 1024.0) / (((double)duration) / 1000000.0);
    std::cout << "Total bytes copied: " << total_bytes << std::endl;
    std::cout << "Sustained bandwidth: " << std::fixed << std::setprecision (5) << bandwidth << " MB/s" << std::endl;

    if (worker->check()) {
        std::cout << "Result check FAILED!" << std::endl;
        return 1;
    };

    std::cout << "Result check PASSED!" << std::endl;

    return 0;
}

int mt_jm_test_16_threads (test_params in_params)
{
    std::cout << "Running with job manager" << std::endl;

    HardwareManagerPtr hw_mgr =  boost::make_shared<HardwareManager> (in_params.card_no, 0, 1000);
    WorkerMemCopyJMPtr worker = boost::make_shared<WorkerMemCopyJM> (hw_mgr, in_params.debug);
    worker->set_mode (INTERRUPT == in_params.mode);
    worker->set_job_start_threshold (in_params.buf_num * in_params.job_num);

    // Initialize the hardware
    if (hw_mgr->init()) {
        std::cerr << "Failed to initialize card" << std::endl;
        return -1;
    }

    uint64_t total_bytes = (uint64_t)in_params.buf_num * (uint64_t)in_params.job_num * (uint64_t)in_params.memcopy_size;

    std::cout << "Setting up jobs." << std::endl;

    // Create buffers
    for (int i = 0; i < in_params.buf_num; i++) {
        BufMemCopyJMPtr buf = boost::make_shared<BufMemCopyJM> (i, 1000);

        // Create jobs for each buffer
        for (int j = 0; j < in_params.job_num; j++) {
            JobMemCopyJMPtr job = boost::make_shared<JobMemCopyJM> (j, i, hw_mgr, in_params.debug);

            if (job->allocate (in_params.memcopy_size)) {
                std::cerr << "Failed to allocate buffer for buf "
                          << std::dec << i << " job " << j << std::endl;
                return -1;
            }

            job->mem_init();
            job->set_worker (worker);

            buf->add_job (job);
        }

        // Add buf to worker
        worker->add_buf (buf);
    }

    std::cout << "Finish setting up jobs." << std::endl;

    worker->setup_completion_queue (in_params.buf_num * in_params.job_num * 4);

    high_resolution_clock::time_point t_start = high_resolution_clock::now();
    // Start work
    worker->start();
    high_resolution_clock::time_point t_end = high_resolution_clock::now();

    auto duration = duration_cast<microseconds> (t_end - t_start).count();
    std::cout << "Work finished after " << duration << " microseconds (us)" << std::endl;
    double bandwidth = ((double)total_bytes / 1024.0 / 1024.0) / (((double)duration) / 1000000.0);
    std::cout << "Total bytes copied: " << total_bytes << std::endl;
    std::cout << "Sustained bandwidth: " << std::fixed << std::setprecision (5) << bandwidth << " MB/s" << std::endl;

    if (worker->check()) {
        std::cout << "Result check FAILED!" << std::endl;
        return 1;
    };

    std::cout << "Result check PASSED!" << std::endl;

    return 0;
}

void print_test_params (test_params in_params)
{
    const char* mode_str[] = {"POLL", "INTERRUPT", "INVALID"};
    printf ("card_no:\t%d\n", in_params.card_no);
    printf ("job_num:\t%d\n", in_params.job_num);
    printf ("buf_num:\t%d\n", in_params.buf_num);
    printf ("memcopy_size:\t%d\n", in_params.memcopy_size);
    printf ("timeout:\t%d\n", in_params.timeout);
    printf ("mode:\t%s\n", mode_str[in_params.mode]);
    printf ("debug:\t%d\n", in_params.debug);
}

