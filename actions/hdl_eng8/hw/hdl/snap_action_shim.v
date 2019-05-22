`timescale 1ns/1ps

module snap_action_shim #(
           parameter KERNEL_NUM = 8,

           // Parameters of Axi Master Bus Interface AXI_CARD_MEM0 ; to DDR memory
           //parameter C_M_AXI_CARD_MEM0_ID_WIDTH     = 2,
           //parameter C_M_AXI_CARD_MEM0_ADDR_WIDTH   = 33,
           //parameter C_M_AXI_CARD_MEM0_DATA_WIDTH   = 512,
           //parameter C_M_AXI_CARD_MEM0_AWUSER_WIDTH = 8,
           //parameter C_M_AXI_CARD_MEM0_ARUSER_WIDTH = 8,
           //parameter C_M_AXI_CARD_MEM0_WUSER_WIDTH  = 1,
           //parameter C_M_AXI_CARD_MEM0_RUSER_WIDTH  = 1,
           //parameter C_M_AXI_CARD_MEM0_BUSER_WIDTH  = 1,

           // Parameters of Axi Slave Bus Interface AXI_CTRL_REG
           parameter C_S_AXI_CTRL_REG_DATA_WIDTH    = 32,
           parameter C_S_AXI_CTRL_REG_ADDR_WIDTH    = 32,

           // Parameters of Axi Master Bus Interface AXI_HOST_MEM ; to Host memory
       // 8-to-1 interconnect: kernel ID_WIDTH=1,
       // output ID_WIDTH=4(awid, arid, bid, rid, but no wid)
       // No USER signals
       // LOCK width = 1
       // No WID

           parameter C_M_AXI_HOST_MEM_ID_WIDTH      = 4,
           parameter C_M_AXI_HOST_MEM_ADDR_WIDTH    = 64,
           parameter C_M_AXI_HOST_MEM_DATA_WIDTH    = 512,

       //Following USER signals are not used at all.
           parameter C_M_AXI_HOST_MEM_AWUSER_WIDTH  = 8,
           parameter C_M_AXI_HOST_MEM_ARUSER_WIDTH  = 8,
           parameter C_M_AXI_HOST_MEM_WUSER_WIDTH   = 1,
           parameter C_M_AXI_HOST_MEM_RUSER_WIDTH   = 1,
           parameter C_M_AXI_HOST_MEM_BUSER_WIDTH   = 1

)(
                        input              clk                      ,
                        input              rst_n                    ,


                        //---- AXI bus interfaced with SNAP core ----
                          // AXI write address channel
                        output    [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0] m_axi_snap_awid          ,
                        output    [C_M_AXI_HOST_MEM_ADDR_WIDTH - 1:0] m_axi_snap_awaddr        ,
                        output    [0007:0] m_axi_snap_awlen         ,
                        output    [0002:0] m_axi_snap_awsize        ,
                        output    [0001:0] m_axi_snap_awburst       ,
                        output    [0003:0] m_axi_snap_awcache       ,
                        output             m_axi_snap_awlock        ,
                        output    [0002:0] m_axi_snap_awprot        ,
                        output    [0003:0] m_axi_snap_awqos         ,
                        output    [0003:0] m_axi_snap_awregion      ,
                        output    [C_M_AXI_HOST_MEM_AWUSER_WIDTH - 1:0] m_axi_snap_awuser        ,
                        output             m_axi_snap_awvalid       ,
                        input              m_axi_snap_awready       ,
                          // AXI write data channel
                        output    [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0] m_axi_snap_wid           ,
                        output    [C_M_AXI_HOST_MEM_DATA_WIDTH - 1:0] m_axi_snap_wdata         ,
                        output    [(C_M_AXI_HOST_MEM_DATA_WIDTH/8) - 1:0] m_axi_snap_wstrb         ,
                        output             m_axi_snap_wlast         ,
                        output             m_axi_snap_wvalid        ,
                        input              m_axi_snap_wready        ,
                          // AXI write response channel
                        output             m_axi_snap_bready        ,
                        input     [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0] m_axi_snap_bid           ,
                        input     [0001:0] m_axi_snap_bresp         ,
                        input              m_axi_snap_bvalid        ,
                          // AXI read address channel
                        output    [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0] m_axi_snap_arid          ,
                        output    [C_M_AXI_HOST_MEM_ADDR_WIDTH - 1:0] m_axi_snap_araddr        ,
                        output    [0007:0] m_axi_snap_arlen         ,
                        output    [0002:0] m_axi_snap_arsize        ,
                        output    [0001:0] m_axi_snap_arburst       ,
                        output    [C_M_AXI_HOST_MEM_ARUSER_WIDTH - 1:0] m_axi_snap_aruser        ,
                        output    [0003:0] m_axi_snap_arcache       ,
                        output             m_axi_snap_arlock        ,
                        output    [0002:0] m_axi_snap_arprot        ,
                        output    [0003:0] m_axi_snap_arqos         ,
                        output    [0003:0] m_axi_snap_arregion      ,
                        output             m_axi_snap_arvalid       ,
                        input              m_axi_snap_arready       ,
                          // AXI read data channel
                        output             m_axi_snap_rready        ,
                        input     [C_M_AXI_HOST_MEM_ID_WIDTH - 1:0] m_axi_snap_rid           ,
                        input     [C_M_AXI_HOST_MEM_DATA_WIDTH - 1:0] m_axi_snap_rdata         ,
                        input     [0001:0] m_axi_snap_rresp         ,
                        input              m_axi_snap_rlast         ,
                        input              m_axi_snap_rvalid        ,

                        /*
                        //---- AXI bus interfaced with DDR ----
                          // AXI write address channel
                        output    [C_M_AXI_CARD_MEM0_ID_WIDTH - 1:0] m_axi_ddr_awid           ,
                        output    [C_M_AXI_CARD_MEM0_ADDR_WIDTH - 1:0] m_axi_ddr_awaddr         ,
                        output    [0007:0] m_axi_ddr_awlen          ,
                        output    [0002:0] m_axi_ddr_awsize         ,
                        output    [0001:0] m_axi_ddr_awburst        ,
                        output    [0003:0] m_axi_ddr_awcache        ,
                        output    [0001:0] m_axi_ddr_awlock         ,
                        output    [0002:0] m_axi_ddr_awprot         ,
                        output    [0003:0] m_axi_ddr_awqos          ,
                        output    [0003:0] m_axi_ddr_awregion       ,
                        output    [C_M_AXI_CARD_MEM0_AWUSER_WIDTH - 1:0] m_axi_ddr_awuser         ,
                        output             m_axi_ddr_awvalid        ,
                        input              m_axi_ddr_awready        ,
                          // AXI write data channel
                        output    [C_M_AXI_CARD_MEM0_ID_WIDTH - 1:0] m_axi_ddr_wid            ,
                        output    [C_M_AXI_CARD_MEM0_DATA_WIDTH - 1:0] m_axi_ddr_wdata          ,
                        output    [(C_M_AXI_CARD_MEM0_DATA_WIDTH/8) - 1:0] m_axi_ddr_wstrb          ,
                        output             m_axi_ddr_wlast          ,
                        output             m_axi_ddr_wvalid         ,
                        input              m_axi_ddr_wready         ,
                          // AXI write response channel
                        output             m_axi_ddr_bready         ,
                        input     [C_M_AXI_CARD_MEM0_ID_WIDTH - 1:0] m_axi_ddr_bid            ,
                        input     [0001:0] m_axi_ddr_bresp          ,
                        input              m_axi_ddr_bvalid         ,
                          // AXI read address channel
                        output    [C_M_AXI_CARD_MEM0_ID_WIDTH - 1:0] m_axi_ddr_arid           ,
                        output    [C_M_AXI_CARD_MEM0_ADDR_WIDTH - 1:0] m_axi_ddr_araddr         ,
                        output    [0007:0] m_axi_ddr_arlen          ,
                        output    [0002:0] m_axi_ddr_arsize         ,
                        output    [0001:0] m_axi_ddr_arburst        ,
                        output    [C_M_AXI_HOST_MEM_ARUSER_WIDTH - 1:0] m_axi_ddr_aruser         ,
                        output    [0003:0] m_axi_ddr_arcache        ,
                        output    [0001:0] m_axi_ddr_arlock         ,
                        output    [0002:0] m_axi_ddr_arprot         ,
                        output    [0003:0] m_axi_ddr_arqos          ,
                        output    [0003:0] m_axi_ddr_arregion       ,
                        output             m_axi_ddr_arvalid        ,
                        input              m_axi_ddr_arready        ,
                          // AXI  ead data channel
                        output             m_axi_ddr_rready         ,
                        input     [C_M_AXI_CARD_MEM0_ID_WIDTH - 1:0] m_axi_ddr_rid            ,
                        input     [C_M_AXI_CARD_MEM0_DATA_WIDTH - 1:0] m_axi_ddr_rdata          ,
                        input     [0001:0] m_axi_ddr_rresp          ,
                        input              m_axi_ddr_rlast          ,
                        input              m_axi_ddr_rvalid         ,
                        */

                        //---- AXI Lite bus interfaced with SNAP core ----
                          // AXI write address channel
                        output             s_axi_snap_awready       ,
                        input     [C_S_AXI_CTRL_REG_ADDR_WIDTH - 1:0] s_axi_snap_awaddr        ,
                        input     [0002:0] s_axi_snap_awprot        ,
                        input              s_axi_snap_awvalid       ,
                          // axi write data channel
                        output             s_axi_snap_wready        ,
                        input     [C_S_AXI_CTRL_REG_DATA_WIDTH - 1:0] s_axi_snap_wdata         ,
                        input     [(C_S_AXI_CTRL_REG_DATA_WIDTH/8) - 1:0] s_axi_snap_wstrb         ,
                        input              s_axi_snap_wvalid        ,
                          // AXI response channel
                        output    [0001:0] s_axi_snap_bresp         ,
                        output             s_axi_snap_bvalid        ,
                        input              s_axi_snap_bready        ,
                          // AXI read address channel
                        output             s_axi_snap_arready       ,
                        input              s_axi_snap_arvalid       ,
                        input     [C_S_AXI_CTRL_REG_ADDR_WIDTH - 1:0] s_axi_snap_araddr        ,
                        input     [0002:0] s_axi_snap_arprot        ,
                          // AXI read data channel
                        output    [C_S_AXI_CTRL_REG_DATA_WIDTH - 1:0] s_axi_snap_rdata         ,
                        output    [0001:0] s_axi_snap_rresp         ,
                        input              s_axi_snap_rready        ,
                        output             s_axi_snap_rvalid        ,

                        // Other signals
                        input              i_app_ready              ,
                        input      [31:0]  i_action_type            ,
                        input      [31:0]  i_action_version         ,
                        output             o_interrupt              ,
                        input              i_interrupt_ack
                       );

wire      [KERNEL_NUM-1:0]         kernel_o_complete ;
wire      [KERNEL_NUM-1:0]         kernel_complete_p ;
wire      [KERNEL_NUM-1:0]         kernel_i_start    ;
wire                               new_job           ;
wire                               job_done          ;
wire                               job_start         ;
wire      [63:0]                   init_addr         ;
wire      [63:0]                   completion_addr   ;
wire      [31:0]                   completion_size   ;
wire                               manager_start     ;
wire                               run_mode          ;
wire      [511:0]                  system_register   ;
wire      [511:0]                  user_register     ;

                                                           // AXI write address channel
wire                                                kernel_m_axi_snap_awid [KERNEL_NUM-1:0];
wire   [C_M_AXI_HOST_MEM_ADDR_WIDTH -1 :0]          kernel_m_axi_snap_awaddr [KERNEL_NUM-1:0];
wire   [0007:0]                                     kernel_m_axi_snap_awlen [KERNEL_NUM-1:0];
wire   [0002:0]                                     kernel_m_axi_snap_awsize [KERNEL_NUM-1:0];
wire   [0001:0]                                     kernel_m_axi_snap_awburst [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_awcache [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_awlock [KERNEL_NUM-1:0];
wire   [0002:0]                                     kernel_m_axi_snap_awprot [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_awqos [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_awregion [KERNEL_NUM-1:0];
wire   [C_M_AXI_HOST_MEM_AWUSER_WIDTH - 1:0]        kernel_m_axi_snap_awuser [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_awvalid [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_awready [KERNEL_NUM-1:0];
                                                           // AXI write data channel
wire                                                kernel_m_axi_snap_wid [KERNEL_NUM-1:0];
wire   [63:0]                                       kernel_m_axi_snap_wdata [KERNEL_NUM-1:0];
wire   [7:0]                                        kernel_m_axi_snap_wstrb [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_wlast [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_wvalid [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_wready [KERNEL_NUM-1:0];
                                                           // AXI write response channel
wire                                                kernel_m_axi_snap_bready [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_bid [KERNEL_NUM-1:0];
wire   [1:0]                                        kernel_m_axi_snap_bresp [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_bvalid [KERNEL_NUM-1:0];
                                                           // AXI read address channel
wire                                                kernel_m_axi_snap_arid [KERNEL_NUM-1:0];
wire   [C_M_AXI_HOST_MEM_ADDR_WIDTH-1:0]            kernel_m_axi_snap_araddr [KERNEL_NUM-1:0];
wire   [0007:0]                                     kernel_m_axi_snap_arlen [KERNEL_NUM-1:0];
wire   [0002:0]                                     kernel_m_axi_snap_arsize [KERNEL_NUM-1:0];
wire   [0001:0]                                     kernel_m_axi_snap_arburst [KERNEL_NUM-1:0];
wire   [C_M_AXI_HOST_MEM_ARUSER_WIDTH-1:0]          kernel_m_axi_snap_aruser [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_arcache [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_arlock [KERNEL_NUM-1:0];
wire   [0002:0]                                     kernel_m_axi_snap_arprot [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_arqos [KERNEL_NUM-1:0];
wire   [0003:0]                                     kernel_m_axi_snap_arregion [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_arvalid [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_arready [KERNEL_NUM-1:0];
                                                           // AXI read data channel
wire                                                kernel_m_axi_snap_rready [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_rid [KERNEL_NUM-1:0];
wire    [63:0]                                      kernel_m_axi_snap_rdata [KERNEL_NUM-1:0];
wire    [1:0]                                       kernel_m_axi_snap_rresp [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_rlast [KERNEL_NUM-1:0];
wire                                                kernel_m_axi_snap_rvalid [KERNEL_NUM-1:0];

                                                           // AXI write address channel
wire                                                job_m_axi_snap_awid;
wire   [C_M_AXI_HOST_MEM_ADDR_WIDTH -1 :0]          job_m_axi_snap_awaddr;
wire   [0007:0]                                     job_m_axi_snap_awlen;
wire   [0002:0]                                     job_m_axi_snap_awsize;
wire   [0001:0]                                     job_m_axi_snap_awburst;
wire   [0003:0]                                     job_m_axi_snap_awcache;
wire                                                job_m_axi_snap_awlock;
wire   [0002:0]                                     job_m_axi_snap_awprot;
wire   [0003:0]                                     job_m_axi_snap_awqos;
wire   [0003:0]                                     job_m_axi_snap_awregion;
wire   [C_M_AXI_HOST_MEM_AWUSER_WIDTH - 1:0]        job_m_axi_snap_awuser;
wire                                                job_m_axi_snap_awvalid;
wire                                                job_m_axi_snap_awready;
                                                           // AXI write data channel
wire                                                job_m_axi_snap_wid;
wire   [511:0]                                      job_m_axi_snap_wdata;
wire   [63:0]                                       job_m_axi_snap_wstrb;
wire                                                job_m_axi_snap_wlast;
wire                                                job_m_axi_snap_wvalid;
wire                                                job_m_axi_snap_wready;
                                                           // AXI write response channel
wire                                                job_m_axi_snap_bready;
wire                                                job_m_axi_snap_bid;
wire   [1:0]                                        job_m_axi_snap_bresp;
wire                                                job_m_axi_snap_bvalid;
                                                           // AXI read address channel
wire                                                job_m_axi_snap_arid;
wire   [C_M_AXI_HOST_MEM_ADDR_WIDTH-1:0]            job_m_axi_snap_araddr;
wire   [0007:0]                                     job_m_axi_snap_arlen;
wire   [0002:0]                                     job_m_axi_snap_arsize;
wire   [0001:0]                                     job_m_axi_snap_arburst;
wire   [C_M_AXI_HOST_MEM_ARUSER_WIDTH-1:0]          job_m_axi_snap_aruser;
wire   [0003:0]                                     job_m_axi_snap_arcache;
wire                                                job_m_axi_snap_arlock;
wire   [0002:0]                                     job_m_axi_snap_arprot;
wire   [0003:0]                                     job_m_axi_snap_arqos;
wire   [0003:0]                                     job_m_axi_snap_arregion;
wire                                                job_m_axi_snap_arvalid;
wire                                                job_m_axi_snap_arready;
                                                           // AXI read data channel
wire                                                job_m_axi_snap_rready;
wire                                                job_m_axi_snap_rid;
wire    [511:0]                                     job_m_axi_snap_rdata;
wire    [1:0]                                       job_m_axi_snap_rresp;
wire                                                job_m_axi_snap_rlast;
wire                                                job_m_axi_snap_rvalid;

//////////////////////////////////////////////////////////////////////////
// AXI lite. Has KERNEL_NUM + 1 slaves
//
// signal [0] ----> kernel 0 --> 0x200
// signal [1] ----> kernel 1 --> 0x300
// signal [2] ----> kernel 2 --> 0x400
// signal [3] ----> kernel 3 --> 0x500
// signal [4] ----> kernel 4 --> 0x600
// signal [5] ----> kernel 5 --> 0x700
// signal [6] ----> kernel 6 --> 0x800
// signal [7] ----> kernel 7 --> 0x900
// signal [KERNEL_NUM] ------> global registers (0x000-0x0FF)

wire               kernel_s_axi_snap_awready [KERNEL_NUM:0];
wire [31:0]        kernel_s_axi_snap_awaddr [KERNEL_NUM:0];
wire [2:0]         kernel_s_axi_snap_awprot [KERNEL_NUM:0];
wire               kernel_s_axi_snap_awvalid [KERNEL_NUM:0];
                        // axi write data channel
wire               kernel_s_axi_snap_wready [KERNEL_NUM:0];
wire [31:0]        kernel_s_axi_snap_wdata [KERNEL_NUM:0];
wire [3:0]         kernel_s_axi_snap_wstrb [KERNEL_NUM:0];
wire               kernel_s_axi_snap_wvalid [KERNEL_NUM:0];
                        // AXI response channel
wire [1:0]         kernel_s_axi_snap_bresp [KERNEL_NUM:0];
wire               kernel_s_axi_snap_bvalid [KERNEL_NUM:0];
wire               kernel_s_axi_snap_bready [KERNEL_NUM:0];
                        // AXI read address channel
wire               kernel_s_axi_snap_arready [KERNEL_NUM:0];
wire               kernel_s_axi_snap_arvalid [KERNEL_NUM:0];
wire [31:0]        kernel_s_axi_snap_araddr [KERNEL_NUM:0];
wire [2:0]         kernel_s_axi_snap_arprot [KERNEL_NUM:0];
                        // AXI read data channel
wire [31:0]        kernel_s_axi_snap_rdata [KERNEL_NUM:0];
wire [1:0]         kernel_s_axi_snap_rresp [KERNEL_NUM:0];
wire               kernel_s_axi_snap_rready [KERNEL_NUM:0];
wire               kernel_s_axi_snap_rvalid [KERNEL_NUM:0];
//Instantiate kernels

genvar i;
generate
for (i = 0; i < KERNEL_NUM; i = i + 1) begin:k_inst

example_kernel #(
           .ENGINE_AXI_S_LITE_DATA_WIDTH    ( 32 ),
           .ENGINE_AXI_S_LITE_ADDR_WIDTH    ( 32 ),

           .ENGINE_AXI_MM_ID_WIDTH      ( 1 ),
           .ENGINE_AXI_MM_ADDR_WIDTH    ( 64 ),
           .ENGINE_AXI_MM_DATA_WIDTH    ( 64 ),
           .ENGINE_AXI_MM_AWUSER_WIDTH  ( C_M_AXI_HOST_MEM_AWUSER_WIDTH ),
           .ENGINE_AXI_MM_ARUSER_WIDTH  ( C_M_AXI_HOST_MEM_ARUSER_WIDTH )
          ) kernel (
                        .clk                    (clk                    ),
                        .rst_n                  (rst_n                  ),

                        //---- AXI bus interfaced with SNAP core ----
                          // AXI write address channel
                        .m_axi_snap_awid        (kernel_m_axi_snap_awid[i]        ),
                        .m_axi_snap_awaddr      (kernel_m_axi_snap_awaddr[i]      ),
                        .m_axi_snap_awlen       (kernel_m_axi_snap_awlen[i]       ),
                        .m_axi_snap_awsize      (kernel_m_axi_snap_awsize[i]      ),
                        .m_axi_snap_awburst     (kernel_m_axi_snap_awburst[i]     ),
                        .m_axi_snap_awcache     (kernel_m_axi_snap_awcache[i]     ),
                        .m_axi_snap_awlock      (kernel_m_axi_snap_awlock[i]      ),
                        .m_axi_snap_awprot      (kernel_m_axi_snap_awprot[i]      ),
                        .m_axi_snap_awqos       (kernel_m_axi_snap_awqos[i]       ),
                        .m_axi_snap_awregion    (kernel_m_axi_snap_awregion[i]    ),
                        .m_axi_snap_awuser      (kernel_m_axi_snap_awuser[i]      ),
                        .m_axi_snap_awvalid     (kernel_m_axi_snap_awvalid[i]     ),
                        .m_axi_snap_awready     (kernel_m_axi_snap_awready[i]     ),
                          // AXI write data channel
                        .m_axi_snap_wid         (kernel_m_axi_snap_wid[i]         ),
                        .m_axi_snap_wdata       (kernel_m_axi_snap_wdata[i]       ),
                        .m_axi_snap_wstrb       (kernel_m_axi_snap_wstrb[i]       ),
                        .m_axi_snap_wlast       (kernel_m_axi_snap_wlast[i]       ),
                        .m_axi_snap_wvalid      (kernel_m_axi_snap_wvalid[i]      ),
                        .m_axi_snap_wready      (kernel_m_axi_snap_wready[i]      ),
                          // AXI write response channel
                        .m_axi_snap_bready     (kernel_m_axi_snap_bready[i]     ),
                        .m_axi_snap_bid         (kernel_m_axi_snap_bid[i]         ),
                        .m_axi_snap_bresp       (kernel_m_axi_snap_bresp[i]       ),
                        .m_axi_snap_bvalid      (kernel_m_axi_snap_bvalid[i]      ),
                          // AXI read address channel
                        .m_axi_snap_arid        (kernel_m_axi_snap_arid[i]        ),
                        .m_axi_snap_araddr      (kernel_m_axi_snap_araddr[i]      ),
                        .m_axi_snap_arlen       (kernel_m_axi_snap_arlen[i]       ),
                        .m_axi_snap_arsize      (kernel_m_axi_snap_arsize[i]      ),
                        .m_axi_snap_arburst     (kernel_m_axi_snap_arburst[i]     ),
                        .m_axi_snap_aruser      (kernel_m_axi_snap_aruser[i]      ),
                        .m_axi_snap_arcache     (kernel_m_axi_snap_arcache[i]     ),
                        .m_axi_snap_arlock      (kernel_m_axi_snap_arlock[i]      ),
                        .m_axi_snap_arprot      (kernel_m_axi_snap_arprot[i]      ),
                        .m_axi_snap_arqos       (kernel_m_axi_snap_arqos[i]       ),
                        .m_axi_snap_arregion    (kernel_m_axi_snap_arregion[i]    ),
                        .m_axi_snap_arvalid     (kernel_m_axi_snap_arvalid[i]     ),
                        .m_axi_snap_arready     (kernel_m_axi_snap_arready[i]     ),
                          // AXI  ead data channel
                        .m_axi_snap_rready      (kernel_m_axi_snap_rready[i]      ),
                        .m_axi_snap_rid         (kernel_m_axi_snap_rid[i]         ),
                        .m_axi_snap_rdata       (kernel_m_axi_snap_rdata[i]       ),
                        .m_axi_snap_rresp       (kernel_m_axi_snap_rresp[i]       ),
                        .m_axi_snap_rlast       (kernel_m_axi_snap_rlast[i]       ),
                        .m_axi_snap_rvalid      (kernel_m_axi_snap_rvalid[i]      ),


                        //---- AXI Lite bus interfaced with SNAP core ----
                        .s_axi_snap_baseaddr      (32'h200 + i*32'h100                ),
                          // AXI write address channel
                        .s_axi_snap_awready       (kernel_s_axi_snap_awready[i]       ),
                        .s_axi_snap_awaddr        (kernel_s_axi_snap_awaddr[i]        ),
                        .s_axi_snap_awprot        (kernel_s_axi_snap_awprot[i]        ),
                        .s_axi_snap_awvalid       (kernel_s_axi_snap_awvalid[i]       ),
                        // axi write data channel
                        .s_axi_snap_wready        (kernel_s_axi_snap_wready[i]        ),
                        .s_axi_snap_wdata         (kernel_s_axi_snap_wdata[i]         ),
                        .s_axi_snap_wstrb         (kernel_s_axi_snap_wstrb[i]         ),
                        .s_axi_snap_wvalid        (kernel_s_axi_snap_wvalid[i]        ),
                        // AXI response channel
                        .s_axi_snap_bresp         (kernel_s_axi_snap_bresp[i]         ),
                        .s_axi_snap_bvalid        (kernel_s_axi_snap_bvalid[i]        ),
                        .s_axi_snap_bready        (kernel_s_axi_snap_bready[i]        ),
                        // AXI read address channel
                        .s_axi_snap_arready       (kernel_s_axi_snap_arready[i]       ),
                        .s_axi_snap_arvalid       (kernel_s_axi_snap_arvalid[i]       ),
                        .s_axi_snap_araddr        (kernel_s_axi_snap_araddr[i]        ),
                        .s_axi_snap_arprot        (kernel_s_axi_snap_arprot[i]        ),
                        // AXI read data channel
                        .s_axi_snap_rdata         (kernel_s_axi_snap_rdata[i]         ),
                        .s_axi_snap_rresp         (kernel_s_axi_snap_rresp[i]         ),
                        .s_axi_snap_rready        (kernel_s_axi_snap_rready[i]        ),
                        .s_axi_snap_rvalid        (kernel_s_axi_snap_rvalid[i]        ),

                        // Other signals
                        .i_app_ready              (i_app_ready                        ),
                        .i_action_type            (i_action_type                      ),
                        .i_action_version         (i_action_version                   ),
                        .i_start                  (kernel_i_start[i]                  ),
                        .run_mode                 (run_mode                           ),
                        .system_register          (system_register                    ),
                        .user_register            (user_register                      ),
                        .o_complete               (kernel_o_complete[i]               )
                       );
end
endgenerate

//8-to-1 AXI MM interconnect
host_axi_interconnect_0 axi_mm_X (
  .INTERCONNECT_ACLK(clk),
  .INTERCONNECT_ARESETN(rst_n),
  .S00_AXI_ARESET_OUT_N ( ),
  .S00_AXI_ACLK (clk),
  .S00_AXI_AWID (kernel_m_axi_snap_awid[00]),
  .S00_AXI_AWADDR (kernel_m_axi_snap_awaddr[00]),
  .S00_AXI_AWLEN (kernel_m_axi_snap_awlen[00]),
  .S00_AXI_AWSIZE (kernel_m_axi_snap_awsize[00]),
  .S00_AXI_AWBURST (kernel_m_axi_snap_awburst[00]),
  .S00_AXI_AWLOCK (kernel_m_axi_snap_awlock[00]),
  .S00_AXI_AWCACHE (kernel_m_axi_snap_awcache[00]),
  .S00_AXI_AWPROT (kernel_m_axi_snap_awprot[00]),
  .S00_AXI_AWQOS (kernel_m_axi_snap_awqos[00]),
  .S00_AXI_AWVALID (kernel_m_axi_snap_awvalid[00]),
  .S00_AXI_AWREADY (kernel_m_axi_snap_awready[00]),
  .S00_AXI_WDATA (kernel_m_axi_snap_wdata[00]),
  .S00_AXI_WSTRB (kernel_m_axi_snap_wstrb[00]),
  .S00_AXI_WLAST (kernel_m_axi_snap_wlast[00]),
  .S00_AXI_WVALID (kernel_m_axi_snap_wvalid[00]),
  .S00_AXI_WREADY (kernel_m_axi_snap_wready[00]),
  .S00_AXI_BID (kernel_m_axi_snap_bid[00]),
  .S00_AXI_BRESP (kernel_m_axi_snap_bresp[00]),
  .S00_AXI_BVALID (kernel_m_axi_snap_bvalid[00]),
  .S00_AXI_BREADY (kernel_m_axi_snap_bready[00]),
  .S00_AXI_ARID (kernel_m_axi_snap_arid[00]),
  .S00_AXI_ARADDR (kernel_m_axi_snap_araddr[00]),
  .S00_AXI_ARLEN (kernel_m_axi_snap_arlen[00]),
  .S00_AXI_ARSIZE (kernel_m_axi_snap_arsize[00]),
  .S00_AXI_ARBURST (kernel_m_axi_snap_arburst[00]),
  .S00_AXI_ARLOCK (kernel_m_axi_snap_arlock[00]),
  .S00_AXI_ARCACHE (kernel_m_axi_snap_arcache[00]),
  .S00_AXI_ARPROT (kernel_m_axi_snap_arprot[00]),
  .S00_AXI_ARQOS (kernel_m_axi_snap_arqos[00]),
  .S00_AXI_ARVALID (kernel_m_axi_snap_arvalid[00]),
  .S00_AXI_ARREADY (kernel_m_axi_snap_arready[00]),
  .S00_AXI_RID (kernel_m_axi_snap_rid[00]),
  .S00_AXI_RDATA (kernel_m_axi_snap_rdata[00]),
  .S00_AXI_RRESP (kernel_m_axi_snap_rresp[00]),
  .S00_AXI_RLAST (kernel_m_axi_snap_rlast[00]),
  .S00_AXI_RVALID (kernel_m_axi_snap_rvalid[00]),
  .S00_AXI_RREADY (kernel_m_axi_snap_rready[00]),
  .S01_AXI_ARESET_OUT_N ( ),
  .S01_AXI_ACLK (clk),
  .S01_AXI_AWID (kernel_m_axi_snap_awid[01]),
  .S01_AXI_AWADDR (kernel_m_axi_snap_awaddr[01]),
  .S01_AXI_AWLEN (kernel_m_axi_snap_awlen[01]),
  .S01_AXI_AWSIZE (kernel_m_axi_snap_awsize[01]),
  .S01_AXI_AWBURST (kernel_m_axi_snap_awburst[01]),
  .S01_AXI_AWLOCK (kernel_m_axi_snap_awlock[01]),
  .S01_AXI_AWCACHE (kernel_m_axi_snap_awcache[01]),
  .S01_AXI_AWPROT (kernel_m_axi_snap_awprot[01]),
  .S01_AXI_AWQOS (kernel_m_axi_snap_awqos[01]),
  .S01_AXI_AWVALID (kernel_m_axi_snap_awvalid[01]),
  .S01_AXI_AWREADY (kernel_m_axi_snap_awready[01]),
  .S01_AXI_WDATA (kernel_m_axi_snap_wdata[01]),
  .S01_AXI_WSTRB (kernel_m_axi_snap_wstrb[01]),
  .S01_AXI_WLAST (kernel_m_axi_snap_wlast[01]),
  .S01_AXI_WVALID (kernel_m_axi_snap_wvalid[01]),
  .S01_AXI_WREADY (kernel_m_axi_snap_wready[01]),
  .S01_AXI_BID (kernel_m_axi_snap_bid[01]),
  .S01_AXI_BRESP (kernel_m_axi_snap_bresp[01]),
  .S01_AXI_BVALID (kernel_m_axi_snap_bvalid[01]),
  .S01_AXI_BREADY (kernel_m_axi_snap_bready[01]),
  .S01_AXI_ARID (kernel_m_axi_snap_arid[01]),
  .S01_AXI_ARADDR (kernel_m_axi_snap_araddr[01]),
  .S01_AXI_ARLEN (kernel_m_axi_snap_arlen[01]),
  .S01_AXI_ARSIZE (kernel_m_axi_snap_arsize[01]),
  .S01_AXI_ARBURST (kernel_m_axi_snap_arburst[01]),
  .S01_AXI_ARLOCK (kernel_m_axi_snap_arlock[01]),
  .S01_AXI_ARCACHE (kernel_m_axi_snap_arcache[01]),
  .S01_AXI_ARPROT (kernel_m_axi_snap_arprot[01]),
  .S01_AXI_ARQOS (kernel_m_axi_snap_arqos[01]),
  .S01_AXI_ARVALID (kernel_m_axi_snap_arvalid[01]),
  .S01_AXI_ARREADY (kernel_m_axi_snap_arready[01]),
  .S01_AXI_RID (kernel_m_axi_snap_rid[01]),
  .S01_AXI_RDATA (kernel_m_axi_snap_rdata[01]),
  .S01_AXI_RRESP (kernel_m_axi_snap_rresp[01]),
  .S01_AXI_RLAST (kernel_m_axi_snap_rlast[01]),
  .S01_AXI_RVALID (kernel_m_axi_snap_rvalid[01]),
  .S01_AXI_RREADY (kernel_m_axi_snap_rready[01]),
  .S02_AXI_ARESET_OUT_N ( ),
  .S02_AXI_ACLK (clk),
  .S02_AXI_AWID (kernel_m_axi_snap_awid[02]),
  .S02_AXI_AWADDR (kernel_m_axi_snap_awaddr[02]),
  .S02_AXI_AWLEN (kernel_m_axi_snap_awlen[02]),
  .S02_AXI_AWSIZE (kernel_m_axi_snap_awsize[02]),
  .S02_AXI_AWBURST (kernel_m_axi_snap_awburst[02]),
  .S02_AXI_AWLOCK (kernel_m_axi_snap_awlock[02]),
  .S02_AXI_AWCACHE (kernel_m_axi_snap_awcache[02]),
  .S02_AXI_AWPROT (kernel_m_axi_snap_awprot[02]),
  .S02_AXI_AWQOS (kernel_m_axi_snap_awqos[02]),
  .S02_AXI_AWVALID (kernel_m_axi_snap_awvalid[02]),
  .S02_AXI_AWREADY (kernel_m_axi_snap_awready[02]),
  .S02_AXI_WDATA (kernel_m_axi_snap_wdata[02]),
  .S02_AXI_WSTRB (kernel_m_axi_snap_wstrb[02]),
  .S02_AXI_WLAST (kernel_m_axi_snap_wlast[02]),
  .S02_AXI_WVALID (kernel_m_axi_snap_wvalid[02]),
  .S02_AXI_WREADY (kernel_m_axi_snap_wready[02]),
  .S02_AXI_BID (kernel_m_axi_snap_bid[02]),
  .S02_AXI_BRESP (kernel_m_axi_snap_bresp[02]),
  .S02_AXI_BVALID (kernel_m_axi_snap_bvalid[02]),
  .S02_AXI_BREADY (kernel_m_axi_snap_bready[02]),
  .S02_AXI_ARID (kernel_m_axi_snap_arid[02]),
  .S02_AXI_ARADDR (kernel_m_axi_snap_araddr[02]),
  .S02_AXI_ARLEN (kernel_m_axi_snap_arlen[02]),
  .S02_AXI_ARSIZE (kernel_m_axi_snap_arsize[02]),
  .S02_AXI_ARBURST (kernel_m_axi_snap_arburst[02]),
  .S02_AXI_ARLOCK (kernel_m_axi_snap_arlock[02]),
  .S02_AXI_ARCACHE (kernel_m_axi_snap_arcache[02]),
  .S02_AXI_ARPROT (kernel_m_axi_snap_arprot[02]),
  .S02_AXI_ARQOS (kernel_m_axi_snap_arqos[02]),
  .S02_AXI_ARVALID (kernel_m_axi_snap_arvalid[02]),
  .S02_AXI_ARREADY (kernel_m_axi_snap_arready[02]),
  .S02_AXI_RID (kernel_m_axi_snap_rid[02]),
  .S02_AXI_RDATA (kernel_m_axi_snap_rdata[02]),
  .S02_AXI_RRESP (kernel_m_axi_snap_rresp[02]),
  .S02_AXI_RLAST (kernel_m_axi_snap_rlast[02]),
  .S02_AXI_RVALID (kernel_m_axi_snap_rvalid[02]),
  .S02_AXI_RREADY (kernel_m_axi_snap_rready[02]),
  .S03_AXI_ARESET_OUT_N ( ),
  .S03_AXI_ACLK (clk),
  .S03_AXI_AWID (kernel_m_axi_snap_awid[03]),
  .S03_AXI_AWADDR (kernel_m_axi_snap_awaddr[03]),
  .S03_AXI_AWLEN (kernel_m_axi_snap_awlen[03]),
  .S03_AXI_AWSIZE (kernel_m_axi_snap_awsize[03]),
  .S03_AXI_AWBURST (kernel_m_axi_snap_awburst[03]),
  .S03_AXI_AWLOCK (kernel_m_axi_snap_awlock[03]),
  .S03_AXI_AWCACHE (kernel_m_axi_snap_awcache[03]),
  .S03_AXI_AWPROT (kernel_m_axi_snap_awprot[03]),
  .S03_AXI_AWQOS (kernel_m_axi_snap_awqos[03]),
  .S03_AXI_AWVALID (kernel_m_axi_snap_awvalid[03]),
  .S03_AXI_AWREADY (kernel_m_axi_snap_awready[03]),
  .S03_AXI_WDATA (kernel_m_axi_snap_wdata[03]),
  .S03_AXI_WSTRB (kernel_m_axi_snap_wstrb[03]),
  .S03_AXI_WLAST (kernel_m_axi_snap_wlast[03]),
  .S03_AXI_WVALID (kernel_m_axi_snap_wvalid[03]),
  .S03_AXI_WREADY (kernel_m_axi_snap_wready[03]),
  .S03_AXI_BID (kernel_m_axi_snap_bid[03]),
  .S03_AXI_BRESP (kernel_m_axi_snap_bresp[03]),
  .S03_AXI_BVALID (kernel_m_axi_snap_bvalid[03]),
  .S03_AXI_BREADY (kernel_m_axi_snap_bready[03]),
  .S03_AXI_ARID (kernel_m_axi_snap_arid[03]),
  .S03_AXI_ARADDR (kernel_m_axi_snap_araddr[03]),
  .S03_AXI_ARLEN (kernel_m_axi_snap_arlen[03]),
  .S03_AXI_ARSIZE (kernel_m_axi_snap_arsize[03]),
  .S03_AXI_ARBURST (kernel_m_axi_snap_arburst[03]),
  .S03_AXI_ARLOCK (kernel_m_axi_snap_arlock[03]),
  .S03_AXI_ARCACHE (kernel_m_axi_snap_arcache[03]),
  .S03_AXI_ARPROT (kernel_m_axi_snap_arprot[03]),
  .S03_AXI_ARQOS (kernel_m_axi_snap_arqos[03]),
  .S03_AXI_ARVALID (kernel_m_axi_snap_arvalid[03]),
  .S03_AXI_ARREADY (kernel_m_axi_snap_arready[03]),
  .S03_AXI_RID (kernel_m_axi_snap_rid[03]),
  .S03_AXI_RDATA (kernel_m_axi_snap_rdata[03]),
  .S03_AXI_RRESP (kernel_m_axi_snap_rresp[03]),
  .S03_AXI_RLAST (kernel_m_axi_snap_rlast[03]),
  .S03_AXI_RVALID (kernel_m_axi_snap_rvalid[03]),
  .S03_AXI_RREADY (kernel_m_axi_snap_rready[03]),
  .S04_AXI_ARESET_OUT_N ( ),
  .S04_AXI_ACLK (clk),
  .S04_AXI_AWID (kernel_m_axi_snap_awid[04]),
  .S04_AXI_AWADDR (kernel_m_axi_snap_awaddr[04]),
  .S04_AXI_AWLEN (kernel_m_axi_snap_awlen[04]),
  .S04_AXI_AWSIZE (kernel_m_axi_snap_awsize[04]),
  .S04_AXI_AWBURST (kernel_m_axi_snap_awburst[04]),
  .S04_AXI_AWLOCK (kernel_m_axi_snap_awlock[04]),
  .S04_AXI_AWCACHE (kernel_m_axi_snap_awcache[04]),
  .S04_AXI_AWPROT (kernel_m_axi_snap_awprot[04]),
  .S04_AXI_AWQOS (kernel_m_axi_snap_awqos[04]),
  .S04_AXI_AWVALID (kernel_m_axi_snap_awvalid[04]),
  .S04_AXI_AWREADY (kernel_m_axi_snap_awready[04]),
  .S04_AXI_WDATA (kernel_m_axi_snap_wdata[04]),
  .S04_AXI_WSTRB (kernel_m_axi_snap_wstrb[04]),
  .S04_AXI_WLAST (kernel_m_axi_snap_wlast[04]),
  .S04_AXI_WVALID (kernel_m_axi_snap_wvalid[04]),
  .S04_AXI_WREADY (kernel_m_axi_snap_wready[04]),
  .S04_AXI_BID (kernel_m_axi_snap_bid[04]),
  .S04_AXI_BRESP (kernel_m_axi_snap_bresp[04]),
  .S04_AXI_BVALID (kernel_m_axi_snap_bvalid[04]),
  .S04_AXI_BREADY (kernel_m_axi_snap_bready[04]),
  .S04_AXI_ARID (kernel_m_axi_snap_arid[04]),
  .S04_AXI_ARADDR (kernel_m_axi_snap_araddr[04]),
  .S04_AXI_ARLEN (kernel_m_axi_snap_arlen[04]),
  .S04_AXI_ARSIZE (kernel_m_axi_snap_arsize[04]),
  .S04_AXI_ARBURST (kernel_m_axi_snap_arburst[04]),
  .S04_AXI_ARLOCK (kernel_m_axi_snap_arlock[04]),
  .S04_AXI_ARCACHE (kernel_m_axi_snap_arcache[04]),
  .S04_AXI_ARPROT (kernel_m_axi_snap_arprot[04]),
  .S04_AXI_ARQOS (kernel_m_axi_snap_arqos[04]),
  .S04_AXI_ARVALID (kernel_m_axi_snap_arvalid[04]),
  .S04_AXI_ARREADY (kernel_m_axi_snap_arready[04]),
  .S04_AXI_RID (kernel_m_axi_snap_rid[04]),
  .S04_AXI_RDATA (kernel_m_axi_snap_rdata[04]),
  .S04_AXI_RRESP (kernel_m_axi_snap_rresp[04]),
  .S04_AXI_RLAST (kernel_m_axi_snap_rlast[04]),
  .S04_AXI_RVALID (kernel_m_axi_snap_rvalid[04]),
  .S04_AXI_RREADY (kernel_m_axi_snap_rready[04]),
  .S05_AXI_ARESET_OUT_N ( ),
  .S05_AXI_ACLK (clk),
  .S05_AXI_AWID (kernel_m_axi_snap_awid[05]),
  .S05_AXI_AWADDR (kernel_m_axi_snap_awaddr[05]),
  .S05_AXI_AWLEN (kernel_m_axi_snap_awlen[05]),
  .S05_AXI_AWSIZE (kernel_m_axi_snap_awsize[05]),
  .S05_AXI_AWBURST (kernel_m_axi_snap_awburst[05]),
  .S05_AXI_AWLOCK (kernel_m_axi_snap_awlock[05]),
  .S05_AXI_AWCACHE (kernel_m_axi_snap_awcache[05]),
  .S05_AXI_AWPROT (kernel_m_axi_snap_awprot[05]),
  .S05_AXI_AWQOS (kernel_m_axi_snap_awqos[05]),
  .S05_AXI_AWVALID (kernel_m_axi_snap_awvalid[05]),
  .S05_AXI_AWREADY (kernel_m_axi_snap_awready[05]),
  .S05_AXI_WDATA (kernel_m_axi_snap_wdata[05]),
  .S05_AXI_WSTRB (kernel_m_axi_snap_wstrb[05]),
  .S05_AXI_WLAST (kernel_m_axi_snap_wlast[05]),
  .S05_AXI_WVALID (kernel_m_axi_snap_wvalid[05]),
  .S05_AXI_WREADY (kernel_m_axi_snap_wready[05]),
  .S05_AXI_BID (kernel_m_axi_snap_bid[05]),
  .S05_AXI_BRESP (kernel_m_axi_snap_bresp[05]),
  .S05_AXI_BVALID (kernel_m_axi_snap_bvalid[05]),
  .S05_AXI_BREADY (kernel_m_axi_snap_bready[05]),
  .S05_AXI_ARID (kernel_m_axi_snap_arid[05]),
  .S05_AXI_ARADDR (kernel_m_axi_snap_araddr[05]),
  .S05_AXI_ARLEN (kernel_m_axi_snap_arlen[05]),
  .S05_AXI_ARSIZE (kernel_m_axi_snap_arsize[05]),
  .S05_AXI_ARBURST (kernel_m_axi_snap_arburst[05]),
  .S05_AXI_ARLOCK (kernel_m_axi_snap_arlock[05]),
  .S05_AXI_ARCACHE (kernel_m_axi_snap_arcache[05]),
  .S05_AXI_ARPROT (kernel_m_axi_snap_arprot[05]),
  .S05_AXI_ARQOS (kernel_m_axi_snap_arqos[05]),
  .S05_AXI_ARVALID (kernel_m_axi_snap_arvalid[05]),
  .S05_AXI_ARREADY (kernel_m_axi_snap_arready[05]),
  .S05_AXI_RID (kernel_m_axi_snap_rid[05]),
  .S05_AXI_RDATA (kernel_m_axi_snap_rdata[05]),
  .S05_AXI_RRESP (kernel_m_axi_snap_rresp[05]),
  .S05_AXI_RLAST (kernel_m_axi_snap_rlast[05]),
  .S05_AXI_RVALID (kernel_m_axi_snap_rvalid[05]),
  .S05_AXI_RREADY (kernel_m_axi_snap_rready[05]),
  .S06_AXI_ARESET_OUT_N ( ),
  .S06_AXI_ACLK (clk),
  .S06_AXI_AWID (kernel_m_axi_snap_awid[06]),
  .S06_AXI_AWADDR (kernel_m_axi_snap_awaddr[06]),
  .S06_AXI_AWLEN (kernel_m_axi_snap_awlen[06]),
  .S06_AXI_AWSIZE (kernel_m_axi_snap_awsize[06]),
  .S06_AXI_AWBURST (kernel_m_axi_snap_awburst[06]),
  .S06_AXI_AWLOCK (kernel_m_axi_snap_awlock[06]),
  .S06_AXI_AWCACHE (kernel_m_axi_snap_awcache[06]),
  .S06_AXI_AWPROT (kernel_m_axi_snap_awprot[06]),
  .S06_AXI_AWQOS (kernel_m_axi_snap_awqos[06]),
  .S06_AXI_AWVALID (kernel_m_axi_snap_awvalid[06]),
  .S06_AXI_AWREADY (kernel_m_axi_snap_awready[06]),
  .S06_AXI_WDATA (kernel_m_axi_snap_wdata[06]),
  .S06_AXI_WSTRB (kernel_m_axi_snap_wstrb[06]),
  .S06_AXI_WLAST (kernel_m_axi_snap_wlast[06]),
  .S06_AXI_WVALID (kernel_m_axi_snap_wvalid[06]),
  .S06_AXI_WREADY (kernel_m_axi_snap_wready[06]),
  .S06_AXI_BID (kernel_m_axi_snap_bid[06]),
  .S06_AXI_BRESP (kernel_m_axi_snap_bresp[06]),
  .S06_AXI_BVALID (kernel_m_axi_snap_bvalid[06]),
  .S06_AXI_BREADY (kernel_m_axi_snap_bready[06]),
  .S06_AXI_ARID (kernel_m_axi_snap_arid[06]),
  .S06_AXI_ARADDR (kernel_m_axi_snap_araddr[06]),
  .S06_AXI_ARLEN (kernel_m_axi_snap_arlen[06]),
  .S06_AXI_ARSIZE (kernel_m_axi_snap_arsize[06]),
  .S06_AXI_ARBURST (kernel_m_axi_snap_arburst[06]),
  .S06_AXI_ARLOCK (kernel_m_axi_snap_arlock[06]),
  .S06_AXI_ARCACHE (kernel_m_axi_snap_arcache[06]),
  .S06_AXI_ARPROT (kernel_m_axi_snap_arprot[06]),
  .S06_AXI_ARQOS (kernel_m_axi_snap_arqos[06]),
  .S06_AXI_ARVALID (kernel_m_axi_snap_arvalid[06]),
  .S06_AXI_ARREADY (kernel_m_axi_snap_arready[06]),
  .S06_AXI_RID (kernel_m_axi_snap_rid[06]),
  .S06_AXI_RDATA (kernel_m_axi_snap_rdata[06]),
  .S06_AXI_RRESP (kernel_m_axi_snap_rresp[06]),
  .S06_AXI_RLAST (kernel_m_axi_snap_rlast[06]),
  .S06_AXI_RVALID (kernel_m_axi_snap_rvalid[06]),
  .S06_AXI_RREADY (kernel_m_axi_snap_rready[06]),
  .S07_AXI_ARESET_OUT_N ( ),
  .S07_AXI_ACLK (clk),
  .S07_AXI_AWID (kernel_m_axi_snap_awid[07]),
  .S07_AXI_AWADDR (kernel_m_axi_snap_awaddr[07]),
  .S07_AXI_AWLEN (kernel_m_axi_snap_awlen[07]),
  .S07_AXI_AWSIZE (kernel_m_axi_snap_awsize[07]),
  .S07_AXI_AWBURST (kernel_m_axi_snap_awburst[07]),
  .S07_AXI_AWLOCK (kernel_m_axi_snap_awlock[07]),
  .S07_AXI_AWCACHE (kernel_m_axi_snap_awcache[07]),
  .S07_AXI_AWPROT (kernel_m_axi_snap_awprot[07]),
  .S07_AXI_AWQOS (kernel_m_axi_snap_awqos[07]),
  .S07_AXI_AWVALID (kernel_m_axi_snap_awvalid[07]),
  .S07_AXI_AWREADY (kernel_m_axi_snap_awready[07]),
  .S07_AXI_WDATA (kernel_m_axi_snap_wdata[07]),
  .S07_AXI_WSTRB (kernel_m_axi_snap_wstrb[07]),
  .S07_AXI_WLAST (kernel_m_axi_snap_wlast[07]),
  .S07_AXI_WVALID (kernel_m_axi_snap_wvalid[07]),
  .S07_AXI_WREADY (kernel_m_axi_snap_wready[07]),
  .S07_AXI_BID (kernel_m_axi_snap_bid[07]),
  .S07_AXI_BRESP (kernel_m_axi_snap_bresp[07]),
  .S07_AXI_BVALID (kernel_m_axi_snap_bvalid[07]),
  .S07_AXI_BREADY (kernel_m_axi_snap_bready[07]),
  .S07_AXI_ARID (kernel_m_axi_snap_arid[07]),
  .S07_AXI_ARADDR (kernel_m_axi_snap_araddr[07]),
  .S07_AXI_ARLEN (kernel_m_axi_snap_arlen[07]),
  .S07_AXI_ARSIZE (kernel_m_axi_snap_arsize[07]),
  .S07_AXI_ARBURST (kernel_m_axi_snap_arburst[07]),
  .S07_AXI_ARLOCK (kernel_m_axi_snap_arlock[07]),
  .S07_AXI_ARCACHE (kernel_m_axi_snap_arcache[07]),
  .S07_AXI_ARPROT (kernel_m_axi_snap_arprot[07]),
  .S07_AXI_ARQOS (kernel_m_axi_snap_arqos[07]),
  .S07_AXI_ARVALID (kernel_m_axi_snap_arvalid[07]),
  .S07_AXI_ARREADY (kernel_m_axi_snap_arready[07]),
  .S07_AXI_RID (kernel_m_axi_snap_rid[07]),
  .S07_AXI_RDATA (kernel_m_axi_snap_rdata[07]),
  .S07_AXI_RRESP (kernel_m_axi_snap_rresp[07]),
  .S07_AXI_RLAST (kernel_m_axi_snap_rlast[07]),
  .S07_AXI_RVALID (kernel_m_axi_snap_rvalid[07]),
  .S07_AXI_RREADY (kernel_m_axi_snap_rready[07]),
  .S08_AXI_ARESET_OUT_N ( ),
  .S08_AXI_ACLK (clk),
  .S08_AXI_AWID (job_m_axi_snap_awid),
  .S08_AXI_AWADDR (job_m_axi_snap_awaddr),
  .S08_AXI_AWLEN (job_m_axi_snap_awlen),
  .S08_AXI_AWSIZE (job_m_axi_snap_awsize),
  .S08_AXI_AWBURST (job_m_axi_snap_awburst),
  .S08_AXI_AWLOCK (job_m_axi_snap_awlock),
  .S08_AXI_AWCACHE (job_m_axi_snap_awcache),
  .S08_AXI_AWPROT (job_m_axi_snap_awprot),
  .S08_AXI_AWQOS (job_m_axi_snap_awqos),
  .S08_AXI_AWVALID (job_m_axi_snap_awvalid),
  .S08_AXI_AWREADY (job_m_axi_snap_awready),
  .S08_AXI_WDATA (job_m_axi_snap_wdata),
  .S08_AXI_WSTRB (job_m_axi_snap_wstrb),
  .S08_AXI_WLAST (job_m_axi_snap_wlast),
  .S08_AXI_WVALID (job_m_axi_snap_wvalid),
  .S08_AXI_WREADY (job_m_axi_snap_wready),
  .S08_AXI_BID (job_m_axi_snap_bid),
  .S08_AXI_BRESP (job_m_axi_snap_bresp),
  .S08_AXI_BVALID (job_m_axi_snap_bvalid),
  .S08_AXI_BREADY (job_m_axi_snap_bready),
  .S08_AXI_ARID (job_m_axi_snap_arid),
  .S08_AXI_ARADDR (job_m_axi_snap_araddr),
  .S08_AXI_ARLEN (job_m_axi_snap_arlen),
  .S08_AXI_ARSIZE (job_m_axi_snap_arsize),
  .S08_AXI_ARBURST (job_m_axi_snap_arburst),
  .S08_AXI_ARLOCK (job_m_axi_snap_arlock),
  .S08_AXI_ARCACHE (job_m_axi_snap_arcache),
  .S08_AXI_ARPROT (job_m_axi_snap_arprot),
  .S08_AXI_ARQOS (job_m_axi_snap_arqos),
  .S08_AXI_ARVALID (job_m_axi_snap_arvalid),
  .S08_AXI_ARREADY (job_m_axi_snap_arready),
  .S08_AXI_RID (job_m_axi_snap_rid),
  .S08_AXI_RDATA (job_m_axi_snap_rdata),
  .S08_AXI_RRESP (job_m_axi_snap_rresp),
  .S08_AXI_RLAST (job_m_axi_snap_rlast),
  .S08_AXI_RVALID (job_m_axi_snap_rvalid),
  .S08_AXI_RREADY (job_m_axi_snap_rready),
  .M00_AXI_ARESET_OUT_N( ),
  .M00_AXI_ACLK(clk),
  .M00_AXI_AWID (m_axi_snap_awid),
  .M00_AXI_AWADDR (m_axi_snap_awaddr),
  .M00_AXI_AWLEN (m_axi_snap_awlen),
  .M00_AXI_AWSIZE (m_axi_snap_awsize),
  .M00_AXI_AWBURST (m_axi_snap_awburst),
  .M00_AXI_AWLOCK (m_axi_snap_awlock),
  .M00_AXI_AWCACHE (m_axi_snap_awcache),
  .M00_AXI_AWPROT (m_axi_snap_awprot),
  .M00_AXI_AWQOS (m_axi_snap_awqos),
  .M00_AXI_AWVALID (m_axi_snap_awvalid),
  .M00_AXI_AWREADY (m_axi_snap_awready),
  .M00_AXI_WDATA (m_axi_snap_wdata),
  .M00_AXI_WSTRB (m_axi_snap_wstrb),
  .M00_AXI_WLAST (m_axi_snap_wlast),
  .M00_AXI_WVALID (m_axi_snap_wvalid),
  .M00_AXI_WREADY (m_axi_snap_wready),
  .M00_AXI_BID (m_axi_snap_bid),
  .M00_AXI_BRESP (m_axi_snap_bresp),
  .M00_AXI_BVALID (m_axi_snap_bvalid),
  .M00_AXI_BREADY (m_axi_snap_bready),
  .M00_AXI_ARID (m_axi_snap_arid),
  .M00_AXI_ARADDR (m_axi_snap_araddr),
  .M00_AXI_ARLEN (m_axi_snap_arlen),
  .M00_AXI_ARSIZE (m_axi_snap_arsize),
  .M00_AXI_ARBURST (m_axi_snap_arburst),
  .M00_AXI_ARLOCK (m_axi_snap_arlock),
  .M00_AXI_ARCACHE (m_axi_snap_arcache),
  .M00_AXI_ARPROT (m_axi_snap_arprot),
  .M00_AXI_ARQOS (m_axi_snap_arqos),
  .M00_AXI_ARVALID (m_axi_snap_arvalid),
  .M00_AXI_ARREADY (m_axi_snap_arready),
  .M00_AXI_RID (m_axi_snap_rid),
  .M00_AXI_RDATA (m_axi_snap_rdata),
  .M00_AXI_RRESP (m_axi_snap_rresp),
  .M00_AXI_RLAST (m_axi_snap_rlast),
  .M00_AXI_RVALID (m_axi_snap_rvalid),
  .M00_AXI_RREADY (m_axi_snap_rready)
);

//1-to-8 AXI-lite crossbar (demux)
host_axi_lite_crossbar_0 axi_lite_X (
  .aclk(clk),
  .aresetn(rst_n),
  .s_axi_awaddr( s_axi_snap_awaddr ),
  .s_axi_awprot( s_axi_snap_awprot ),
  .s_axi_awvalid( s_axi_snap_awvalid ),
  .s_axi_awready( s_axi_snap_awready ),
  .s_axi_wdata( s_axi_snap_wdata ),
  .s_axi_wstrb( s_axi_snap_wstrb ),
  .s_axi_wvalid( s_axi_snap_wvalid ),
  .s_axi_wready( s_axi_snap_wready ),
  .s_axi_bresp( s_axi_snap_bresp ),
  .s_axi_bvalid( s_axi_snap_bvalid ),
  .s_axi_bready( s_axi_snap_bready ),
  .s_axi_araddr( s_axi_snap_araddr ),
  .s_axi_arprot( s_axi_snap_arprot ),
  .s_axi_arvalid( s_axi_snap_arvalid ),
  .s_axi_arready( s_axi_snap_arready ),
  .s_axi_rdata( s_axi_snap_rdata ),
  .s_axi_rresp( s_axi_snap_rresp ),
  .s_axi_rvalid( s_axi_snap_rvalid ),
  .s_axi_rready( s_axi_snap_rready ),
  .m_axi_awaddr( {kernel_s_axi_snap_awaddr[8], kernel_s_axi_snap_awaddr[7],kernel_s_axi_snap_awaddr[6],kernel_s_axi_snap_awaddr[5],kernel_s_axi_snap_awaddr[4],kernel_s_axi_snap_awaddr[3],kernel_s_axi_snap_awaddr[2],kernel_s_axi_snap_awaddr[1],kernel_s_axi_snap_awaddr[0]} ),
  .m_axi_awprot( {kernel_s_axi_snap_awprot[8], kernel_s_axi_snap_awprot[7],kernel_s_axi_snap_awprot[6],kernel_s_axi_snap_awprot[5],kernel_s_axi_snap_awprot[4],kernel_s_axi_snap_awprot[3],kernel_s_axi_snap_awprot[2],kernel_s_axi_snap_awprot[1],kernel_s_axi_snap_awprot[0]} ),
  .m_axi_awvalid( {kernel_s_axi_snap_awvalid[8], kernel_s_axi_snap_awvalid[7],kernel_s_axi_snap_awvalid[6],kernel_s_axi_snap_awvalid[5],kernel_s_axi_snap_awvalid[4],kernel_s_axi_snap_awvalid[3],kernel_s_axi_snap_awvalid[2],kernel_s_axi_snap_awvalid[1],kernel_s_axi_snap_awvalid[0]} ),
  .m_axi_awready( {kernel_s_axi_snap_awready[8], kernel_s_axi_snap_awready[7],kernel_s_axi_snap_awready[6],kernel_s_axi_snap_awready[5],kernel_s_axi_snap_awready[4],kernel_s_axi_snap_awready[3],kernel_s_axi_snap_awready[2],kernel_s_axi_snap_awready[1],kernel_s_axi_snap_awready[0]} ),
  .m_axi_wdata( {kernel_s_axi_snap_wdata[8], kernel_s_axi_snap_wdata[7],kernel_s_axi_snap_wdata[6],kernel_s_axi_snap_wdata[5],kernel_s_axi_snap_wdata[4],kernel_s_axi_snap_wdata[3],kernel_s_axi_snap_wdata[2],kernel_s_axi_snap_wdata[1],kernel_s_axi_snap_wdata[0]} ),
  .m_axi_wstrb( {kernel_s_axi_snap_wstrb[8], kernel_s_axi_snap_wstrb[7],kernel_s_axi_snap_wstrb[6],kernel_s_axi_snap_wstrb[5],kernel_s_axi_snap_wstrb[4],kernel_s_axi_snap_wstrb[3],kernel_s_axi_snap_wstrb[2],kernel_s_axi_snap_wstrb[1],kernel_s_axi_snap_wstrb[0]} ),
  .m_axi_wvalid( {kernel_s_axi_snap_wvalid[8], kernel_s_axi_snap_wvalid[7],kernel_s_axi_snap_wvalid[6],kernel_s_axi_snap_wvalid[5],kernel_s_axi_snap_wvalid[4],kernel_s_axi_snap_wvalid[3],kernel_s_axi_snap_wvalid[2],kernel_s_axi_snap_wvalid[1],kernel_s_axi_snap_wvalid[0]} ),
  .m_axi_wready( {kernel_s_axi_snap_wready[8], kernel_s_axi_snap_wready[7],kernel_s_axi_snap_wready[6],kernel_s_axi_snap_wready[5],kernel_s_axi_snap_wready[4],kernel_s_axi_snap_wready[3],kernel_s_axi_snap_wready[2],kernel_s_axi_snap_wready[1],kernel_s_axi_snap_wready[0]} ),
  .m_axi_bresp( {kernel_s_axi_snap_bresp[8], kernel_s_axi_snap_bresp[7],kernel_s_axi_snap_bresp[6],kernel_s_axi_snap_bresp[5],kernel_s_axi_snap_bresp[4],kernel_s_axi_snap_bresp[3],kernel_s_axi_snap_bresp[2],kernel_s_axi_snap_bresp[1],kernel_s_axi_snap_bresp[0]} ),
  .m_axi_bvalid( {kernel_s_axi_snap_bvalid[8], kernel_s_axi_snap_bvalid[7],kernel_s_axi_snap_bvalid[6],kernel_s_axi_snap_bvalid[5],kernel_s_axi_snap_bvalid[4],kernel_s_axi_snap_bvalid[3],kernel_s_axi_snap_bvalid[2],kernel_s_axi_snap_bvalid[1],kernel_s_axi_snap_bvalid[0]} ),
  .m_axi_bready( {kernel_s_axi_snap_bready[8], kernel_s_axi_snap_bready[7],kernel_s_axi_snap_bready[6],kernel_s_axi_snap_bready[5],kernel_s_axi_snap_bready[4],kernel_s_axi_snap_bready[3],kernel_s_axi_snap_bready[2],kernel_s_axi_snap_bready[1],kernel_s_axi_snap_bready[0]} ),
  .m_axi_araddr( {kernel_s_axi_snap_araddr[8], kernel_s_axi_snap_araddr[7],kernel_s_axi_snap_araddr[6],kernel_s_axi_snap_araddr[5],kernel_s_axi_snap_araddr[4],kernel_s_axi_snap_araddr[3],kernel_s_axi_snap_araddr[2],kernel_s_axi_snap_araddr[1],kernel_s_axi_snap_araddr[0]} ),
  .m_axi_arprot( {kernel_s_axi_snap_arprot[8], kernel_s_axi_snap_arprot[7],kernel_s_axi_snap_arprot[6],kernel_s_axi_snap_arprot[5],kernel_s_axi_snap_arprot[4],kernel_s_axi_snap_arprot[3],kernel_s_axi_snap_arprot[2],kernel_s_axi_snap_arprot[1],kernel_s_axi_snap_arprot[0]} ),
  .m_axi_arvalid( {kernel_s_axi_snap_arvalid[8], kernel_s_axi_snap_arvalid[7],kernel_s_axi_snap_arvalid[6],kernel_s_axi_snap_arvalid[5],kernel_s_axi_snap_arvalid[4],kernel_s_axi_snap_arvalid[3],kernel_s_axi_snap_arvalid[2],kernel_s_axi_snap_arvalid[1],kernel_s_axi_snap_arvalid[0]} ),
  .m_axi_arready( {kernel_s_axi_snap_arready[8], kernel_s_axi_snap_arready[7],kernel_s_axi_snap_arready[6],kernel_s_axi_snap_arready[5],kernel_s_axi_snap_arready[4],kernel_s_axi_snap_arready[3],kernel_s_axi_snap_arready[2],kernel_s_axi_snap_arready[1],kernel_s_axi_snap_arready[0]} ),
  .m_axi_rdata( {kernel_s_axi_snap_rdata[8], kernel_s_axi_snap_rdata[7],kernel_s_axi_snap_rdata[6],kernel_s_axi_snap_rdata[5],kernel_s_axi_snap_rdata[4],kernel_s_axi_snap_rdata[3],kernel_s_axi_snap_rdata[2],kernel_s_axi_snap_rdata[1],kernel_s_axi_snap_rdata[0]} ),
  .m_axi_rresp( {kernel_s_axi_snap_rresp[8], kernel_s_axi_snap_rresp[7],kernel_s_axi_snap_rresp[6],kernel_s_axi_snap_rresp[5],kernel_s_axi_snap_rresp[4],kernel_s_axi_snap_rresp[3],kernel_s_axi_snap_rresp[2],kernel_s_axi_snap_rresp[1],kernel_s_axi_snap_rresp[0]} ),
  .m_axi_rvalid( {kernel_s_axi_snap_rvalid[8], kernel_s_axi_snap_rvalid[7],kernel_s_axi_snap_rvalid[6],kernel_s_axi_snap_rvalid[5],kernel_s_axi_snap_rvalid[4],kernel_s_axi_snap_rvalid[3],kernel_s_axi_snap_rvalid[2],kernel_s_axi_snap_rvalid[1],kernel_s_axi_snap_rvalid[0]} ),
  .m_axi_rready( {kernel_s_axi_snap_rready[8], kernel_s_axi_snap_rready[7],kernel_s_axi_snap_rready[6],kernel_s_axi_snap_rready[5],kernel_s_axi_snap_rready[4],kernel_s_axi_snap_rready[3],kernel_s_axi_snap_rready[2],kernel_s_axi_snap_rready[1],kernel_s_axi_snap_rready[0]} )
);

 axi_lite_global_slave #(
           .KERNEL_NUM   (KERNEL_NUM                     ),
           .DATA_WIDTH   (32                             ),
           .ADDR_WIDTH   (32                             )
 ) maxi_lite_global_slave (
                                .clk                        (clk                   ),
                                .rst_n                      (rst_n                 ),
                                .s_axi_awready              (kernel_s_axi_snap_awready[8]    ),
                                .s_axi_awaddr               (kernel_s_axi_snap_awaddr[8]     ),//32b
                                .s_axi_awprot               (kernel_s_axi_snap_awprot[8]     ),//3b
                                .s_axi_awvalid              (kernel_s_axi_snap_awvalid[8]    ),
                                .s_axi_wready               (kernel_s_axi_snap_wready[8]     ),
                                .s_axi_wdata                (kernel_s_axi_snap_wdata[8]      ),//32b
                                .s_axi_wstrb                (kernel_s_axi_snap_wstrb[8]      ),//4b
                                .s_axi_wvalid               (kernel_s_axi_snap_wvalid[8]     ),
                                .s_axi_bresp                (kernel_s_axi_snap_bresp[8]      ),//2b
                                .s_axi_bvalid               (kernel_s_axi_snap_bvalid[8]     ),
                                .s_axi_bready               (kernel_s_axi_snap_bready[8]     ),
                                .s_axi_arready              (kernel_s_axi_snap_arready[8]    ),
                                .s_axi_arvalid              (kernel_s_axi_snap_arvalid[8]    ),
                                .s_axi_araddr               (kernel_s_axi_snap_araddr[8]     ),//32b
                                .s_axi_arprot               (kernel_s_axi_snap_arprot[8]     ),//3b
                                .s_axi_rdata                (kernel_s_axi_snap_rdata[8]      ),//32b
                                .s_axi_rresp                (kernel_s_axi_snap_rresp[8]      ),//2b
                                .s_axi_rready               (kernel_s_axi_snap_rready[8]     ),
                                .s_axi_rvalid               (kernel_s_axi_snap_rvalid[8]     ),
                                .manager_start              (manager_start                   ),
                                .run_mode                   (run_mode                        ),
                                .init_addr                  (init_addr                       ),
                                .completion_addr            (completion_addr                 ),
                                .completion_size            (completion_size                 ),
                                .new_job                    (new_job                         ),
                                .job_done                   (job_done                        ),
                                .job_start                  (job_start                       ),
                                .real_done                  (real_done                       ),
                                .kernel_start               (kernel_i_start                  ),
                                .i_action_type              (i_action_type                   ),
                                .kernel_complete            (kernel_o_complete               ),
                                .kernel_complete_posedge    (kernel_complete_p               ),
                                .o_interrupt                (o_interrupt                     ),
                                .i_interrupt_ack            (i_interrupt_ack                 )
        );

completion_manager completion_manager0(
                        .clk                    (clk                    ),
                        .rst_n                  (rst_n                  ),
                        .kernel_start           (kernel_i_start         ),
                        .kernel_complete        (kernel_complete_p      ),
                        .system_register        (system_register        ),
                        .completion_addr        (completion_addr        ),
                        .completion_size        (completion_size        ),
                        .real_done              (real_done              ),

                        //---- AXI bus interfaced with SNAP core ----
                          // AXI write address channel
                        .m_axi_awid        (job_m_axi_snap_awid        ),
                        .m_axi_awaddr      (job_m_axi_snap_awaddr      ),
                        .m_axi_awlen       (job_m_axi_snap_awlen       ),
                        .m_axi_awsize      (job_m_axi_snap_awsize      ),
                        .m_axi_awburst     (job_m_axi_snap_awburst     ),
                        .m_axi_awcache     (job_m_axi_snap_awcache     ),
                        .m_axi_awlock      (job_m_axi_snap_awlock      ),
                        .m_axi_awprot      (job_m_axi_snap_awprot      ),
                        .m_axi_awqos       (job_m_axi_snap_awqos       ),
                        .m_axi_awregion    (job_m_axi_snap_awregion    ),
                        .m_axi_awuser      (job_m_axi_snap_awuser      ),
                        .m_axi_awvalid     (job_m_axi_snap_awvalid     ),
                        .m_axi_awready     (job_m_axi_snap_awready     ),
                          // AXI write data channel
                        .m_axi_wid         (job_m_axi_snap_wid         ),
                        .m_axi_wdata       (job_m_axi_snap_wdata       ),
                        .m_axi_wstrb       (job_m_axi_snap_wstrb       ),
                        .m_axi_wlast       (job_m_axi_snap_wlast       ),
                        .m_axi_wvalid      (job_m_axi_snap_wvalid      ),
                        .m_axi_wready      (job_m_axi_snap_wready      ),
                          // AXI write response channel
                        .m_axi_bready      (job_m_axi_snap_bready      ),
                        .m_axi_bid         (job_m_axi_snap_bid         ),
                        .m_axi_bresp       (job_m_axi_snap_bresp       ),
                        .m_axi_bvalid      (job_m_axi_snap_bvalid      )
        );


job_manager job_manager0 (
                        .clk                    (clk                    ),
                        .rst_n                  (rst_n                  ),
                        .init_addr              (init_addr              ),
                        .manager_start          (manager_start          ),
                        .new_job                (new_job                ),
                        .job_done               (job_done               ),
                        .job_start              (job_start              ),

                        //---- AXI bus interfaced with SNAP core ----
                          // AXI read address channel
                        .m_axi_arid        (job_m_axi_snap_arid        ),
                        .m_axi_araddr      (job_m_axi_snap_araddr      ),
                        .m_axi_arlen       (job_m_axi_snap_arlen       ),
                        .m_axi_arsize      (job_m_axi_snap_arsize      ),
                        .m_axi_arburst     (job_m_axi_snap_arburst     ),
                        .m_axi_aruser      (job_m_axi_snap_aruser      ),
                        .m_axi_arcache     (job_m_axi_snap_arcache     ),
                        .m_axi_arlock      (job_m_axi_snap_arlock      ),
                        .m_axi_arprot      (job_m_axi_snap_arprot      ),
                        .m_axi_arqos       (job_m_axi_snap_arqos       ),
                        .m_axi_arregion    (job_m_axi_snap_arregion    ),
                        .m_axi_arvalid     (job_m_axi_snap_arvalid     ),
                        .m_axi_arready     (job_m_axi_snap_arready     ),
                          // AXI  ead data channel
                        .m_axi_rready      (job_m_axi_snap_rready      ),
                        .m_axi_rid         (job_m_axi_snap_rid         ),
                        .m_axi_rdata       (job_m_axi_snap_rdata       ),
                        .m_axi_rresp       (job_m_axi_snap_rresp       ),
                        .m_axi_rlast       (job_m_axi_snap_rlast       ),
                        .m_axi_rvalid      (job_m_axi_snap_rvalid      ),

                        .system_register        (system_register            ),
                        .user_register          (user_register              )
        );

endmodule
