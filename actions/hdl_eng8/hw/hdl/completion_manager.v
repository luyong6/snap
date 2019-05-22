`timescale 1ns/1ps
//Yanheng Lu
//IBM CSL OpenPower
//lyhlu@cn.ibm.com

module completion_manager #(
    parameter KERNEL_NUM = 8,
    parameter ID_WIDTH = 1,
    parameter ARUSER_WIDTH = 8,
    parameter AWUSER_WIDTH = 8,
    parameter DATA_WIDTH = 512,
    parameter ADDR_WIDTH = 64
)(
        input                               clk             ,
        input                               rst_n           ,
        input      [KERNEL_NUM-1:0]         kernel_start    ,
        input      [KERNEL_NUM-1:0]         kernel_complete ,
        input      [511:0]                  system_register ,
        input      [63:0]                   completion_addr ,
        input      [31:0]                   completion_size ,
        input                               real_done       ,

        //---- AXI bus ----
           // AXI write address channel
        output     [ID_WIDTH - 1:0]       m_axi_awid    ,
        output     [ADDR_WIDTH - 1:0]     m_axi_awaddr  ,
        output     [007:0]                m_axi_awlen   ,
        output     [002:0]                m_axi_awsize  ,
        output     [001:0]                m_axi_awburst ,
        output     [003:0]                m_axi_awcache ,
        output     [001:0]                m_axi_awlock  ,
        output     [002:0]                m_axi_awprot  ,
        output     [003:0]                m_axi_awqos   ,
        output     [003:0]                m_axi_awregion,
        output     [AWUSER_WIDTH - 1:0]   m_axi_awuser  ,
        output                            m_axi_awvalid ,
        input                             m_axi_awready ,
           // AXI write data channel
        output     [ID_WIDTH - 1:0]       m_axi_wid     ,
        output     [DATA_WIDTH - 1:0]     m_axi_wdata   ,
        output     [(DATA_WIDTH/8) - 1:0] m_axi_wstrb   ,
        output                            m_axi_wlast   ,
        output                            m_axi_wvalid  ,
        input                             m_axi_wready  ,
           // AXI write response channel
        output                            m_axi_bready  ,
        input      [ID_WIDTH - 1:0]       m_axi_bid     ,
        input      [001:0]                m_axi_bresp   ,
        input                             m_axi_bvalid
);

    reg     [23:0]  thread0_id;
    reg     [23:0]  thread1_id;
    reg     [23:0]  thread2_id;
    reg     [23:0]  thread3_id;
    reg     [23:0]  thread4_id;
    reg     [23:0]  thread5_id;
    reg     [23:0]  thread6_id;
    reg     [23:0]  thread7_id;
    reg             pingpong;
    reg             last_dump;
    reg     [2:0]   nxt_state;
    reg     [2:0]   cur_state;
    reg     [31:0]  waddr_offside;
    reg             wvalid_done;
    reg             awvalid_done;

    reg     [1023:0]    write_buf;
    reg     [4:0]       count;
    reg     [7:0]       act;
    reg     [31:0]      complete_data;
    reg                 completion_enable;

parameter IDLE  = 0;
parameter WRITE = 1;
parameter WAIT  = 2;
parameter DONE  = 3;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        completion_enable <= 1'b0;
    else if(kernel_start != 'd0)
        completion_enable <= 1'b1;
    else if(real_done & (cur_state == IDLE) & (count[3:0] == 'd0) & (pingpong == count[4]))
        completion_enable <= 1'b0;

    always@(posedge clk or negedge rst_n) if(!rst_n) thread0_id <= 24'b0;
                                          else if (kernel_start[0]) thread0_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread1_id <= 24'b0;
                                          else if (kernel_start[1]) thread1_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread2_id <= 24'b0;
                                          else if (kernel_start[2]) thread2_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread3_id <= 24'b0;
                                          else if (kernel_start[3]) thread3_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread4_id <= 24'b0;
                                          else if (kernel_start[4]) thread4_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread5_id <= 24'b0;
                                          else if (kernel_start[5]) thread5_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread6_id <= 24'b0;
                                          else if (kernel_start[6]) thread6_id <= system_register[31:8];
    always@(posedge clk or negedge rst_n) if(!rst_n) thread7_id <= 24'b0;
                                          else if (kernel_start[7]) thread7_id <= system_register[31:8];

    always@(*)
    if(!rst_n)
        complete_data = 'd0;
    else casex(act)
        8'b1xxxxxxx: complete_data = {thread7_id,8'b1};
        8'b01xxxxxx: complete_data = {thread6_id,8'b1};
        8'b001xxxxx: complete_data = {thread5_id,8'b1};
        8'b0001xxxx: complete_data = {thread4_id,8'b1};
        8'b00001xxx: complete_data = {thread3_id,8'b1};
        8'b000001xx: complete_data = {thread2_id,8'b1};
        8'b0000001x: complete_data = {thread1_id,8'b1};
        8'b00000001: complete_data = {thread0_id,8'b1};
        default    : complete_data = 32'd0;
    endcase

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        write_buf <= 1024'b0;
    else if(act != 'd0)
        case(count)
            5'b11111: write_buf <= {complete_data,write_buf[991:0]};
            5'b11110: write_buf <= {write_buf[1023:992],complete_data,write_buf[959:0]};
            5'b11101: write_buf <= {write_buf[1023:960],complete_data,write_buf[927:0]};
            5'b11100: write_buf <= {write_buf[1023:928],complete_data,write_buf[895:0]};
            5'b11011: write_buf <= {write_buf[1023:896],complete_data,write_buf[863:0]};
            5'b11010: write_buf <= {write_buf[1023:864],complete_data,write_buf[831:0]};
            5'b11001: write_buf <= {write_buf[1023:832],complete_data,write_buf[799:0]};
            5'b11000: write_buf <= {write_buf[1023:800],complete_data,write_buf[767:0]};
            5'b10111: write_buf <= {write_buf[1023:768],complete_data,write_buf[735:0]};
            5'b10110: write_buf <= {write_buf[1023:736],complete_data,write_buf[703:0]};
            5'b10101: write_buf <= {write_buf[1023:704],complete_data,write_buf[671:0]};
            5'b10100: write_buf <= {write_buf[1023:672],complete_data,write_buf[639:0]};
            5'b10011: write_buf <= {write_buf[1023:640],complete_data,write_buf[607:0]};
            5'b10010: write_buf <= {write_buf[1023:608],complete_data,write_buf[575:0]};
            5'b10001: write_buf <= {write_buf[1023:576],complete_data,write_buf[543:0]};
            5'b10000: write_buf <= {write_buf[1023:544],complete_data,write_buf[511:0]};
            5'b01111: write_buf <= {write_buf[1023:512],complete_data,write_buf[479:0]};
            5'b01110: write_buf <= {write_buf[1023:480],complete_data,write_buf[447:0]};
            5'b01101: write_buf <= {write_buf[1023:448],complete_data,write_buf[415:0]};
            5'b01100: write_buf <= {write_buf[1023:416],complete_data,write_buf[383:0]};
            5'b01011: write_buf <= {write_buf[1023:384],complete_data,write_buf[351:0]};
            5'b01010: write_buf <= {write_buf[1023:352],complete_data,write_buf[319:0]};
            5'b01001: write_buf <= {write_buf[1023:320],complete_data,write_buf[287:0]};
            5'b01000: write_buf <= {write_buf[1023:288],complete_data,write_buf[255:0]};
            5'b00111: write_buf <= {write_buf[1023:256],complete_data,write_buf[223:0]};
            5'b00110: write_buf <= {write_buf[1023:224],complete_data,write_buf[191:0]};
            5'b00101: write_buf <= {write_buf[1023:192],complete_data,write_buf[159:0]};
            5'b00100: write_buf <= {write_buf[1023:160],complete_data,write_buf[127:0]};
            5'b00011: write_buf <= {write_buf[1023:128],complete_data,write_buf[95:0]};
            5'b00010: write_buf <= {write_buf[1023:96],complete_data,write_buf[63:0]};
            5'b00001: write_buf <= {write_buf[1023:64],complete_data,write_buf[31:0]};
            5'b00000: write_buf <= {write_buf[1023:32],complete_data};
        endcase

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        count <= 5'b0;
    else if((last_dump & (cur_state == DONE)) | !completion_enable)
        count <= 5'b0;
    else if(act != 'd0)
        count <= count + 1'b1;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        act <= 8'b0;
    else casex(act)
            8'b1xxxxxxx: act <= {1'b0,act[6:0]|kernel_complete[6:0]};
            8'b01xxxxxx: act <= {kernel_complete[7],1'b0,act[5:0]|kernel_complete[5:0]};
            8'b001xxxxx: act <= {kernel_complete[7:6],1'b0,act[4:0]|kernel_complete[4:0]};
            8'b0001xxxx: act <= {kernel_complete[7:5],1'b0,act[3:0]|kernel_complete[3:0]};
            8'b00001xxx: act <= {kernel_complete[7:4],1'b0,act[2:0]|kernel_complete[2:0]};
            8'b000001xx: act <= {kernel_complete[7:3],1'b0,act[1:0]|kernel_complete[1:0]};
            8'b0000001x: act <= {kernel_complete[7:2],1'b0,act[0]|kernel_complete[0]};
            8'b00000001: act <= {kernel_complete[7:1],1'b0};
            default    : act <= kernel_complete;
        endcase

    assign m_axi_awid     = 0;
    assign m_axi_awlen    = 8'b00000000;
    assign m_axi_awsize   = 3'b011;
    assign m_axi_awburst  = 2'b01;
    assign m_axi_awcache  = 4'b0011;
    assign m_axi_awlock   = 2'b00;
    assign m_axi_awprot   = 3'b000;
    assign m_axi_awqos    = 4'b0000;
    assign m_axi_awregion = 4'b0000;
    assign m_axi_awuser   = 0;
    assign m_axi_wid      = 0;
    assign m_axi_wstrb    = 64'hffffffffffffffff;
    assign m_axi_bready   = 1'b1;


    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            cur_state <= IDLE;
        else
            cur_state <= nxt_state;

    always@(*)
        case(cur_state)
        IDLE:
            if(((pingpong != count[4]) | last_dump) & completion_enable)
                nxt_state = WRITE;
            else
                nxt_state = IDLE;
        WRITE:
            if (awvalid_done & wvalid_done)
                nxt_state = WAIT;
            else
                nxt_state = WRITE;
        WAIT:
            if(m_axi_bvalid & (m_axi_bresp == 2'b00))
                nxt_state = DONE;
            else
                nxt_state = WAIT;
        DONE:
            nxt_state = IDLE;
        endcase

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        pingpong <= 1'b0;
    else if((last_dump & (cur_state == DONE)) | !completion_enable)
        pingpong <= 1'b0;
    else if(cur_state == DONE)
        pingpong <= !pingpong;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        last_dump <= 1'b0;
    else if(real_done & ((count[3:0] != 'd0) | (pingpong == !count[4])) & (cur_state == IDLE))
        last_dump <= 1'b1;
    else if(last_dump & (cur_state == DONE))
        last_dump <= 1'b0;

    assign m_axi_wdata    = pingpong ? write_buf[1023:512] : write_buf[511:0];
    assign m_axi_awaddr   = completion_addr + waddr_offside;
    assign m_axi_wvalid   = (cur_state == WRITE) & !wvalid_done;
    assign m_axi_awvalid  = (cur_state == WRITE) & !awvalid_done;
    assign m_axi_wlast    = m_axi_wvalid;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        awvalid_done <= 1'b0;
    else if(cur_state == DONE)
        awvalid_done <= 1'b0;
    else if(m_axi_awvalid & m_axi_awready)
        awvalid_done <= 1'b1;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        wvalid_done <= 1'b0;
    else if(cur_state == DONE)
        wvalid_done <= 1'b0;
    else if(m_axi_wvalid & m_axi_wready)
        wvalid_done <= 1'b1;

    always@(posedge clk or negedge rst_n)
    if(!rst_n)
        waddr_offside <= 'd0;
    else if (!completion_enable)
        waddr_offside <= 'd0;
    else if (cur_state == DONE)
        waddr_offside <= waddr_offside + 'd64;
    else if(waddr_offside == completion_size)
        waddr_offside <= 'd0;

endmodule
