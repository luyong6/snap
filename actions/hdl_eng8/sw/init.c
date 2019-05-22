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

#include "init.h"

/*  defaults */
#define ACTION_WAIT_TIME    1   /* Default in sec */

#define MEGAB      (1024*1024ull)
#define GIGAB      (1024 * MEGAB)

#define VERBOSE0(fmt, ...) do {      \
        printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE1(fmt, ...) do {      \
        if (verbose_level > 0)        \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE2(fmt, ...) do {      \
        if (verbose_level > 1)        \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)


#define VERBOSE3(fmt, ...) do {      \
        if (verbose_level > 2)        \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

#define VERBOSE4(fmt, ...) do {      \
        if (verbose_level > 3)        \
            printf(fmt, ## __VA_ARGS__);    \
    } while (0)

static const char* version = GIT_VERSION;
static  int verbose_level = 0;

static uint64_t get_usec (void)
{
    struct timeval t;

    gettimeofday (&t, NULL);
    return t.tv_sec * 1000000 + t.tv_usec;
}


static void* alloc_mem (int align, int size)
{
    void* a;
    int size2 = size + align;

    VERBOSE2 ("%s Enter Align: %d Size: %d\n", __func__, align, size);

    if (posix_memalign ((void**)&a, 4096, size2) != 0) {
        perror ("FAILED: posix_memalign()");
        return NULL;
    }

    VERBOSE2 ("%s Exit %p\n", __func__, a);
    return a;
}

//static void free_mem (void* a)
//{
//  VERBOSE2 ("Free Mem %p\n", a);
//
//  if (a) {
//      free (a);
//  }
//}


/* Action or Kernel Write and Read are 32 bit MMIO */
static void action_write (struct snap_card* h, uint32_t addr, uint32_t data)
{
    int rc;

    rc = snap_mmio_write32 (h, (uint64_t)addr, data);

    if (0 != rc) {
        VERBOSE0 ("Write MMIO 32 Err\n");
    }

    return;
}

static uint32_t action_read (struct snap_card* h, uint32_t addr)
{
    int rc;
    uint32_t data;

    rc = snap_mmio_read32 (h, (uint64_t)addr, &data);

    if (0 != rc) {
        VERBOSE0 ("Read MMIO 32 Err\n");
    }

    return data;
}


/*
 *  Start Action and wait for Idle.
 */

/*...*/

static int do_action (struct snap_card* dnc,
                      void* src,
                      void* dest,
                      uint64_t* elapsed
                     )
{
    int rc;
    int cntprint;
    uint64_t t_start;   /* time in usec */
    uint64_t td = 0;    /* Diff time in usec */

    rc = 0;

    uint64_t addr;

    VERBOSE0 (" Start register config! \n");

    // source address
    addr = (uint64_t)dest;
    action_write (dnc, ACTION_CMPL_ADDR_HI, (uint32_t) (addr >> 32));
    action_read (dnc, ACTION_CMPL_ADDR_HI);
    action_write (dnc, ACTION_CMPL_ADDR_LO, (uint32_t) (addr & 0xffffffff));
    addr = (uint64_t)src;
    action_write (dnc, ACTION_INIT_ADDR_HI, (uint32_t) (addr >> 32));
    action_write (dnc, ACTION_INIT_ADDR_LO, (uint32_t) (addr & 0xffffffff));
    VERBOSE1 (" Write ADDR done! \n");

    action_write (dnc, ACTION_CMPL_SIZE, 0x00100000);
    VERBOSE1 (" test!\n ");
    t_start = get_usec();


    VERBOSE0 (" test!\n");
    // start copy
    action_write (dnc, ACTION_GLOBAL_CONTROL, 0X00000101);
    action_write (dnc, ACTION_GLOBAL_CONTROL, 0X00000100);

    //done
    while ((action_read (dnc, ACTION_GLOBAL_DONE) & 0x00000001) == 0) {;};

    //sleep(5);

    cntprint = action_read (dnc, ACTION_KERNEL0_CNT);

    printf ("KERNEL0 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL1_CNT);

    printf ("KERNEL1 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL2_CNT);

    printf ("KERNEL2 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL3_CNT);

    printf ("KERNEL3 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL4_CNT);

    printf ("KERNEL4 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL5_CNT);

    printf ("KERNEL5 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL6_CNT);

    printf ("KERNEL6 count = %d \n", cntprint);

    cntprint = action_read (dnc, ACTION_KERNEL7_CNT);

    printf ("KERNEL7 count = %d \n", cntprint);

    VERBOSE0 (" done!\n");

    td = get_usec() - t_start;

    *elapsed = td;

    if (0 != rc) {
        return rc;
    }

    return rc;
}

static struct snap_action* get_action (struct snap_card* handle,
                                       snap_action_flag_t flags, int timeout)
{
    struct snap_action* act;

    act = snap_attach_action (handle, ACTION_TYPE_HDL_INIT,
                              flags, timeout);

    if (NULL == act) {
        VERBOSE0 ("Error: Can not attach Action: %x\n", ACTION_TYPE_HDL_INIT);
        VERBOSE0 ("	   Try to run snap_main tool\n");
    }

    return act;
}

static void usage (const char* prog)
{
    VERBOSE0 ("SNAP String Match (Regular Expression Match) Tool.\n"
              "	Use Option -p and -q for pattern and packet\n"
              "	e.g. %s -p <packet file> -q <pattern file> [-vv] [-I]\n",
              prog);
    VERBOSE0 ("Usage: %s\n"
              "	-h, --help		   print usage information\n"
              "	-v, --verbose		verbose mode\n"
              "	-C, --card <cardno>  use this card for operation\n"
              "	-V, --version\n"
              "	-q, --quiet		  quiece output\n"
              "	-t, --timeout		Timeout after N sec (default 1 sec)\n"
              "	-I, --irq			Enable Action Done Interrupt (default No Interrupts)\n"
              , prog);
}

int main (int argc, char* argv[])
{
    char device[64];
    struct snap_card* dn;   /* lib snap handle */
    int card_no = 0;
    int cmd;
    int rc = 1;
    uint64_t cir;
    int timeout = ACTION_WAIT_TIME;
    snap_action_flag_t attach_flags = 0;
    struct snap_action* act = NULL;
    unsigned long ioctl_data;
    int patt_size = 4096 * 4096;
    int delay = 100;
    int length = 16384;
    int* completion = alloc_mem (64, 8192);
    int* init = alloc_mem (64, 64);
    void* src  = alloc_mem (64, patt_size);
    void* dest = alloc_mem (64, patt_size);
    int* init1 = alloc_mem (64, 64);
    void* src1  = alloc_mem (64, patt_size);
    void* dest1 = alloc_mem (64, patt_size);
    int* init2 = alloc_mem (64, 64);
    void* src2  = alloc_mem (64, patt_size);
    void* dest2 = alloc_mem (64, patt_size);
    int* init3 = alloc_mem (64, 64);
    void* src3  = alloc_mem (64, patt_size);
    void* dest3 = alloc_mem (64, patt_size);
    int* init4 = alloc_mem (64, 64);
    void* src4  = alloc_mem (64, patt_size);
    void* dest4 = alloc_mem (64, patt_size);
    int* init5 = alloc_mem (64, 64);
    void* src5  = alloc_mem (64, patt_size);
    void* dest5 = alloc_mem (64, patt_size);
    int* init6 = alloc_mem (64, 64);
    void* src6  = alloc_mem (64, patt_size);
    void* dest6 = alloc_mem (64, patt_size);
    int* init7 = alloc_mem (64, 64);
    void* src7  = alloc_mem (64, patt_size);
    void* dest7 = alloc_mem (64, patt_size);
    int* init8 = alloc_mem (64, 64);
    void* src8  = alloc_mem (64, patt_size);
    void* dest8 = alloc_mem (64, patt_size);
    int* init9 = alloc_mem (64, 64);
    void* src9  = alloc_mem (64, patt_size);
    void* dest9 = alloc_mem (64, patt_size);
    uint64_t td;

    * init = 0x5A5A0000;
    * (init + 1) = (uint32_t)length;
    * (init + 2) = (uint32_t) ((uint64_t)src & 0xffffffff);
    * (init + 3) = (uint32_t) ((uint64_t)src >> 32);
    * (init + 4) = (uint32_t) ((uint64_t)dest & 0xffffffff);
    * (init + 5) = (uint32_t) ((uint64_t)dest >> 32);
    * (init + 6) = (uint32_t) ((uint64_t)init1 & 0xffffffff);
    * (init + 7) = (uint32_t) ((uint64_t)init1 >> 32);
    * (init + 9) = (uint32_t)delay;

    * init1 = 0x5A5A0100;
    * (init1 + 1) = (uint32_t)length;
    * (init1 + 2) = (uint32_t) ((uint64_t)src1 & 0xffffffff);
    * (init1 + 3) = (uint32_t) ((uint64_t)src1 >> 32);
    * (init1 + 4) = (uint32_t) ((uint64_t)dest1 & 0xffffffff);
    * (init1 + 5) = (uint32_t) ((uint64_t)dest1 >> 32);
    * (init1 + 6) = (uint32_t) ((uint64_t)init2 & 0xffffffff);
    * (init1 + 7) = (uint32_t) ((uint64_t)init2 >> 32);
    * (init1 + 9) = (uint32_t)delay;

    * init2 = 0x5A5A0200;
    * (init2 + 1) = (uint32_t)length;
    * (init2 + 2) = (uint32_t) ((uint64_t)src2 & 0xffffffff);
    * (init2 + 3) = (uint32_t) ((uint64_t)src2 >> 32);
    * (init2 + 4) = (uint32_t) ((uint64_t)dest2 & 0xffffffff);
    * (init2 + 5) = (uint32_t) ((uint64_t)dest2 >> 32);
    * (init2 + 6) = (uint32_t) ((uint64_t)init3 & 0xffffffff);
    * (init2 + 7) = (uint32_t) ((uint64_t)init3 >> 32);
    * (init2 + 9) = (uint32_t)delay;

    * init3 = 0x5A5A0300;
    * (init3 + 1) = (uint32_t)length;
    * (init3 + 2) = (uint32_t) ((uint64_t)src3 & 0xffffffff);
    * (init3 + 3) = (uint32_t) ((uint64_t)src3 >> 32);
    * (init3 + 4) = (uint32_t) ((uint64_t)dest3 & 0xffffffff);
    * (init3 + 5) = (uint32_t) ((uint64_t)dest3 >> 32);
    * (init3 + 6) = (uint32_t) ((uint64_t)init4 & 0xffffffff);
    * (init3 + 7) = (uint32_t) ((uint64_t)init4 >> 32);
    * (init3 + 9) = (uint32_t)delay;

    * init4 = 0x5A5A0400;
    * (init4 + 1) = (uint32_t)length;
    * (init4 + 2) = (uint32_t) ((uint64_t)src4 & 0xffffffff);
    * (init4 + 3) = (uint32_t) ((uint64_t)src4 >> 32);
    * (init4 + 4) = (uint32_t) ((uint64_t)dest4 & 0xffffffff);
    * (init4 + 5) = (uint32_t) ((uint64_t)dest4 >> 32);
    * (init4 + 6) = (uint32_t) ((uint64_t)init5 & 0xffffffff);
    * (init4 + 7) = (uint32_t) ((uint64_t)init5 >> 32);
    * (init4 + 9) = (uint32_t)delay;

    * init5 = 0x5A5A0500;
    * (init5 + 1) = (uint32_t)length;
    * (init5 + 2) = (uint32_t) ((uint64_t)src5 & 0xffffffff);
    * (init5 + 3) = (uint32_t) ((uint64_t)src5 >> 32);
    * (init5 + 4) = (uint32_t) ((uint64_t)dest5 & 0xffffffff);
    * (init5 + 5) = (uint32_t) ((uint64_t)dest5 >> 32);
    * (init5 + 6) = (uint32_t) ((uint64_t)init6 & 0xffffffff);
    * (init5 + 7) = (uint32_t) ((uint64_t)init6 >> 32);
    * (init5 + 9) = (uint32_t)delay;

    * init6 = 0x5A5A0600;
    * (init6 + 1) = (uint32_t)length;
    * (init6 + 2) = (uint32_t) ((uint64_t)src6 & 0xffffffff);
    * (init6 + 3) = (uint32_t) ((uint64_t)src6 >> 32);
    * (init6 + 4) = (uint32_t) ((uint64_t)dest6 & 0xffffffff);
    * (init6 + 5) = (uint32_t) ((uint64_t)dest6 >> 32);
    * (init6 + 6) = (uint32_t) ((uint64_t)init7 & 0xffffffff);
    * (init6 + 7) = (uint32_t) ((uint64_t)init7 >> 32);
    * (init6 + 9) = (uint32_t)delay;

    * init7 = 0x5A5A0700;
    * (init7 + 1) = (uint32_t)length;
    * (init7 + 2) = (uint32_t) ((uint64_t)src7 & 0xffffffff);
    * (init7 + 3) = (uint32_t) ((uint64_t)src7 >> 32);
    * (init7 + 4) = (uint32_t) ((uint64_t)dest7 & 0xffffffff);
    * (init7 + 5) = (uint32_t) ((uint64_t)dest7 >> 32);
    * (init7 + 6) = (uint32_t) ((uint64_t)init8 & 0xffffffff);
    * (init7 + 7) = (uint32_t) ((uint64_t)init8 >> 32);
    * (init7 + 9) = (uint32_t)delay;

    * init8 = 0x5A5A0800;
    * (init8 + 1) = (uint32_t)length;
    * (init8 + 2) = (uint32_t) ((uint64_t)src8 & 0xffffffff);
    * (init8 + 3) = (uint32_t) ((uint64_t)src8 >> 32);
    * (init8 + 4) = (uint32_t) ((uint64_t)dest8 & 0xffffffff);
    * (init8 + 5) = (uint32_t) ((uint64_t)dest8 >> 32);
    * (init8 + 6) = (uint32_t) ((uint64_t)init9 & 0xffffffff);
    * (init8 + 7) = (uint32_t) ((uint64_t)init9 >> 32);
    * (init8 + 9) = (uint32_t)delay;

    * init9 = 0x5A5A0900;
    * (init9 + 1) = (uint32_t)length;
    * (init9 + 2) = (uint32_t) ((uint64_t)src9 & 0xffffffff);
    * (init9 + 3) = (uint32_t) ((uint64_t)src9 >> 32);
    * (init9 + 4) = (uint32_t) ((uint64_t)dest9 & 0xffffffff);
    * (init9 + 5) = (uint32_t) ((uint64_t)dest9 >> 32);
    * (init9 + 6) = 0;
    * (init9 + 7) = 0;
    * (init9 + 9) = (uint32_t)delay;

    while (1) {
        int option_index = 0;
        static struct option long_options[] = {
            { "card",    required_argument, NULL, 'C' },
            { "verbose",  no_argument,     NULL, 'v' },
            { "help",    no_argument,      NULL, 'h' },
            { "version",  no_argument,     NULL, 'V' },
            { "quiet",  no_argument,       NULL, 'q' },
            { "timeout",  required_argument, NULL, 't' },
            { "irq",      no_argument,     NULL, 'I' },
            { 0,          no_argument,     NULL, 0   },
        };
        cmd = getopt_long (argc, argv, "C:t:IqvVh",
                           long_options, &option_index);

        if (cmd == -1) { /* all params processed ? */
            break;
        }

        switch (cmd) {
        case 'v':   /* verbose */
            verbose_level++;
            break;

        case 'V':   /* version */
            VERBOSE0 ("%s\n", version);
            exit (EXIT_SUCCESS);;

        case 'h':   /* help */
            usage (argv[0]);
            exit (EXIT_SUCCESS);;

        case 'C':   /* card */
            card_no = strtol (optarg, (char**)NULL, 0);
            break;

        case 't':
            timeout = strtol (optarg, (char**)NULL, 0); /* in sec */
            break;

        case 'I':     /* irq */
            attach_flags = SNAP_ACTION_DONE_IRQ | SNAP_ATTACH_IRQ;
            break;

        default:
            usage (argv[0]);
            exit (EXIT_FAILURE);
        }
    }

    VERBOSE2 ("Open Card: %d\n", card_no);
    sprintf (device, "/dev/cxl/afu%d.0s", card_no);
    dn = snap_card_alloc_dev (device, SNAP_VENDOR_ID_IBM, SNAP_DEVICE_ID_SNAP);

    if (NULL == dn) {
        errno = ENODEV;
        VERBOSE0 ("ERROR: snap_card_alloc_dev(%s)\n", device);
        return -1;
    }

    /* Read Card Capabilities */
    snap_card_ioctl (dn, GET_CARD_TYPE, (unsigned long)&ioctl_data);
    VERBOSE1 ("SNAP on ");

    //  switch (ioctl_data) {
    //  case  0:
    //      VERBOSE1 ("ADKU3");
    //      break;
    //
    //  case  1:
    //      VERBOSE1 ("N250S");
    //      break;
    //
    //  case 16:
    //      VERBOSE1 ("N250SP");
    //      break;
    //
    //  default:
    //      VERBOSE1 ("Unknown");
    //      break;
    //  }

    //snap_card_ioctl (dn, GET_SDRAM_SIZE, (unsigned long)&ioctl_data);
    //VERBOSE1 (" Card, %d MB of Card Ram avilable.\n", (int)ioctl_data);

    snap_mmio_read64 (dn, SNAP_S_CIR, &cir);
    VERBOSE0 ("Start of Card Handle: %p Context: %d\n", dn,
              (int) (cir & 0x1ff));

    VERBOSE0 ("Start to get action.\n");

    act = get_action (dn, attach_flags, 5 * timeout);


    if (NULL == act) {
        goto __exit1;
    }

    VERBOSE0 ("Finish get action.\n");

    VERBOSE0 ("Start memory copy.\n");
    rc = do_action (dn, init, completion, &td);

    //cmd = *completion;
    //printf("completion data = %x \n",cmd);
    cmd = *(completion+0);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+1);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+2);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+3);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+4);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+5);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+6);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+7);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+8);
    printf("completion data = %x \n",cmd);
    cmd = *(completion+9);
    printf("completion data = %x \n",cmd);

    snap_detach_action (act);

__exit1:
    // Unmap AFU MMIO registers, if previously mapped
    VERBOSE2 ("Free Card Handle: %p\n", dn);
    snap_card_free (dn);

    //free_mem(patt_src_base);
    //free_mem(patt_tgt_base);

    VERBOSE1 ("End of Test rc: %d\n", rc);
    return rc;
}
