`timescale 1ns/1ps
//Yanheng Lu
//IBM CSL OpenPower
//lyhlu@cn.ibm.com

module job_manager #(
    parameter KERNEL_NUM = 8,
    parameter ID_WIDTH = 1,
    parameter ARUSER_WIDTH = 8,
    parameter AWUSER_WIDTH = 8,
    parameter DATA_WIDTH = 512,
    parameter ADDR_WIDTH = 64
)(
        input                               clk             ,
        input                               rst_n           ,
        input      [063:0]                  init_addr       ,
        input                               manager_start   ,
        input                               new_job         ,
        input                               job_done        ,
        output reg                          job_start       ,

        //---- AXI bus ----
           // AXI read address channel
        output     [ID_WIDTH - 1:0]       m_axi_arid    ,
        output reg [ADDR_WIDTH - 1:0]     m_axi_araddr  ,
        output reg [007:0]                m_axi_arlen   ,
        output     [002:0]                m_axi_arsize  ,
        output     [001:0]                m_axi_arburst ,
        output     [ARUSER_WIDTH - 1:0]   m_axi_aruser  ,
        output     [003:0]                m_axi_arcache ,
        output     [001:0]                m_axi_arlock  ,
        output     [002:0]                m_axi_arprot  ,
        output     [003:0]                m_axi_arqos   ,
        output     [003:0]                m_axi_arregion,
        output reg                        m_axi_arvalid ,
        input                             m_axi_arready ,
          // AXI read data channel
        output reg                        m_axi_rready  ,
        input      [ID_WIDTH - 1:0]       m_axi_rid     ,
        input      [DATA_WIDTH - 1:0]     m_axi_rdata   ,
        input      [001:0]                m_axi_rresp   ,
        input                             m_axi_rlast   ,
        input                             m_axi_rvalid  ,

        //output
        output reg [511:0]                system_register       ,
        output reg [511:0]                user_register
);

parameter IDLE = 0;
parameter READ = 1;
parameter ANAL = 2;
parameter MORE = 3;
parameter DATA = 4;
parameter RUN  = 5;
parameter TMP  = 6;
parameter WAIT = 7;

    reg [2:0]   nxt_state;
    reg [2:0]   cur_state;
    reg [1:0]   delay;
    reg [63:0]  next_addr;
    wire        read_busy;
    wire        read_done;
    wire        fifo_empty;
    wire        fifo_full;
    wire        fifo_valid;
    wire        fifo_pull;
    wire [511:0] fifo_out;
    reg [11:0]  user_length;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            cur_state <= IDLE;
        else
            cur_state <= nxt_state;

    always@(*)
        case(cur_state)
        IDLE:
            if(manager_start)
                nxt_state = READ;
            else
                nxt_state = IDLE;
        READ:
            if(m_axi_arvalid & m_axi_arready)
                nxt_state = ANAL;
            else
                nxt_state = READ;
        ANAL:
            if(read_done & (user_length < 'd8))
                nxt_state = WAIT;
            else if(read_done)
                nxt_state = MORE;
            else
                nxt_state = ANAL;
        MORE:
            if(m_axi_arvalid & m_axi_arready)
                nxt_state = DATA;
            else
                nxt_state = MORE;
        DATA:
            if(read_done)
                nxt_state = WAIT;
            else
                nxt_state = DATA;
        WAIT:
            if(!fifo_full & (next_addr != 'd0))
                nxt_state = READ;
            else if(job_done & (next_addr == 'd0) & fifo_empty)
                nxt_state = IDLE;
            else
                nxt_state = WAIT;
        default:
            nxt_state = IDLE;
        endcase

    assign m_axi_arid     = 0;
    assign m_axi_arsize   = 3'd6; // 2^6=512
    assign m_axi_arburst  = 2'd1; // INCR mode for memory access
    assign m_axi_arcache  = 4'd3; // Normal Non-cacheable Bufferable
    assign m_axi_aruser   = 0;//i_snap_context[ARUSER_WIDTH - 1:0];
    assign m_axi_arprot   = 3'd0;
    assign m_axi_arqos    = 4'd0;
    assign m_axi_arregion = 4'd0; //?
    assign m_axi_arlock   = 2'b00; // normal access

    assign read_busy = 1'b0;
    assign read_done = m_axi_rvalid & m_axi_rlast & m_axi_rready;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            next_addr <= 64'b0;
        else if(cur_state == IDLE)
            next_addr <= init_addr;
        else if((cur_state == ANAL) & read_done)
            next_addr <= m_axi_rdata[255:192];

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            user_register <= 512'b0;
        else if((cur_state == DATA) & read_done)
            user_register <= m_axi_rdata;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            user_length <= 12'b0;
        else if((cur_state == ANAL) & read_done)
            user_length <= m_axi_rdata[267:256];

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            m_axi_arvalid <= 1'b0;
        else if(m_axi_arready & m_axi_arvalid)
            m_axi_arvalid <= 1'b0;
        else if(cur_state == READ || cur_state == MORE)
            m_axi_arvalid <= 1'b1;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            m_axi_arlen <= 8'b0;
        else if(cur_state == READ)
            m_axi_arlen <= 8'd0;
        else if((cur_state == MORE))
            m_axi_arlen <= user_length;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            m_axi_araddr <= 64'd0;
        else if(cur_state == READ)
            m_axi_araddr <= next_addr;
        else if(cur_state == MORE)
            m_axi_araddr <= next_addr + 'd64;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            m_axi_rready <= 1'b0;
        else if(read_busy)
            m_axi_rready <= 1'b0;
        else
            m_axi_rready <= 1'b1;

    assign fifo_pull = (delay == 2'b00) && new_job && !fifo_empty && !job_start;

job_manager_fifo fifo_job_manager (
    .clk        (clk            ), // input clk
    .rst        (!rst_n         ), // input rst
    .din        (m_axi_rdata    ), // input [511 : 0] din
    .wr_en      (m_axi_rvalid & m_axi_rready), // input wr_en
    .rd_en      (fifo_pull      ), // input rd_en
    .valid      (fifo_valid     ), // output dv
    .dout       (fifo_out       ), // output [511 : 0] dout
    .full       (fifo_full      ), // output full
    .empty      (fifo_empty     ), // output empty
    .data_count (               ) // output [4 : 0] data_count
);

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            delay <= 2'b00;
        else if(job_start)
            delay <= 2'b11;
        else if(delay != 2'b00)
            delay <= delay - 1'b1;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            job_start <= 1'b0;
        else if(job_start)
            job_start <= 1'b0;
        else if(delay == 2'b00)
            job_start <= new_job & !fifo_empty;
        else
            job_start <= 1'b0;

    always@(posedge clk or negedge rst_n)
        if(!rst_n)
            system_register <= 512'b0;
        else if(fifo_valid)
            system_register <= fifo_out;

endmodule
