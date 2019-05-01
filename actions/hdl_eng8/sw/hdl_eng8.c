/*
 * Copyright 2017 International Business Machines
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <malloc.h>
#include <unistd.h>
#include <sys/time.h>
#include <time.h>
#include <getopt.h>
#include <ctype.h>

#include <libsnap.h>
#include <snap_tools.h>
#include <snap_s_regs.h>

#include "hdl_eng8.h"
#include "MtTest.h"

static void usage (const char* prog)
{
    printf ("Usage: %s [-h] [-v, --verbose] [-V, --version]\n"
            "  -C, --card <cardno>        can be (0...3)\n"
            "  -b, --buf-num <buf_num>    number of buffers.\n"
            "  -j, --job-num <job_num>    number of jobs per buffer.\n"
            "  -s, --memcopy-size <memory copy size> number of bytes copied by each job.\n"
            "  -t, --timeout              timeout in sec to wait for done.\n"
            "  -p, --poll                 disable Interrupts, use polling to check done status.\n"
            "  -m, --job-manager          Use job manager mode.\n"
            "\n",
            prog);
}

int main (int argc, char* argv[])
{
    static const char* version = GIT_VERSION;
    int ch;
    int card_no = 0;
    int buf_num = 16; // By default, 16 buffers
    int job_num = 1; // By default, 1 jobs per buffer
    uint32_t memcopy_size = 4096; // By default, 4K bytes to copy for each job
    int timeout = 1; // By default, 1 seconds to wait for card attachment and interrupt
    bool interrupt = true; // By default, use interrupt mode
    bool debug = false; // By default, disable debug mode
    bool job_manager = false; // By default, don't use job manager

    // collecting the command line arguments
    while (1) {
        int option_index = 0;
        static struct option long_options[] = {
            { "card", required_argument, NULL, 'C' },
            { "buf-num", required_argument, NULL, 'b' },
            { "job-num", required_argument, NULL, 'j' },
            { "memcopy-size", required_argument, NULL, 's' },
            { "timeout", required_argument, NULL, 't' },
            { "poll", no_argument, NULL, 'p' },
            { "job-manager", no_argument, NULL, 'm' },
            { "version", no_argument, NULL, 'V' },
            { "verbose", no_argument, NULL, 'v' },
            { "help", no_argument, NULL, 'h' },
            { 0, no_argument, NULL, 0   },
        };

        ch = getopt_long (argc, argv,
                          "C:b:j:s:t:pmVvh",
                          long_options, &option_index);

        if (ch == -1) {
            break;
        }

        switch (ch) {
        case 'C':
            card_no = strtol (optarg, (char**)NULL, 0);
            break;

        case 'b':
            buf_num = strtol (optarg, (char**)NULL, 0);
            break;

        case 'j':
            job_num = strtol (optarg, (char**)NULL, 0);
            break;

        case 's':
            memcopy_size = __str_to_num (optarg);
            break;

        case 't':
            timeout = strtol (optarg, (char**)NULL, 0);
            break;

        case 'p':
            interrupt = false;
            break;

        case 'm':
            job_manager = true;
            break;

        case 'V':
            printf ("%s\n", version);
            exit (EXIT_SUCCESS);

        case 'v':
            debug = true;
            break;

        case 'h':
            usage (argv[0]);
            exit (EXIT_SUCCESS);
            break;

        default:
            usage (argv[0]);
            exit (EXIT_FAILURE);
        }
    }

    if (optind != argc) {
        usage (argv[0]);
        exit (EXIT_FAILURE);
    }

    test_params params;
    params.card_no = card_no;
    params.job_num = job_num;
    params.buf_num = buf_num;
    params.memcopy_size = memcopy_size;
    params.timeout = timeout;
    params.mode = interrupt ? INTERRUPT : POLL;
    params.debug = debug;
    print_test_params (params);

    int rc = 0;

    if (job_manager) {
        rc = mt_jm_test_16_threads (params);
    } else {
        rc = mt_test_16_threads (params);
    }

    return rc;
} // main end
