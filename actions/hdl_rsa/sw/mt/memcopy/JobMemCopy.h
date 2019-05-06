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

#ifndef JobMemCopy_H_h
#define JobMemCopy_H_h

#include <iostream>
#include "JobBase.h"

class JobMemCopy : public JobBase
{
public:
    enum eStatus {
        DONE = 0,
        FAIL,
        NUM_STATUS
    };

    // Constructor of the job base
    JobMemCopy();
    JobMemCopy (int in_id, int in_buf_id);
    JobMemCopy (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr);
    JobMemCopy (int in_id, int in_buf_id, HardwareManagerPtr in_hw_mgr, bool in_debug);

    // Destructor of the job base
    ~JobMemCopy();

    // Set the address of the source buffer
    void set_src (void* in_src);

    // Set the address of the destination buffer
    void set_dest (void* in_dest);

    // Set the size of the memory copy
    void set_size (size_t in_size);

    // Run this job
    virtual int run();

    // Init the memory before copying
    int mem_init();

    // Perform the memory copy
    int mem_copy();

    // Check the memory result
    int mem_check();

    // Allocate memory buffers
    int allocate (size_t in_size);

private:
    // The address of the source buffer
    void* m_src;

    // The address of the destination buffer
    void* m_dest;

    // The copy size;
    size_t m_size;

    // Calculate the register address for each job
    uint32_t reg_addr (uint32_t in_offset);

    // Helper function to alloc aligned memory buffers
    void* aalloc (int align, int size);
};

typedef boost::shared_ptr<JobMemCopy> JobMemCopyPtr;

#endif
