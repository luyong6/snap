`timescale 1ns/1ps

module axi_lite_global_slave #(
    parameter KERNEL_NUM = 8,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
                      input             clk                   ,
                      input             rst_n                 ,

                      //---- AXI Lite bus----
                        // AXI write address channel
                      output reg        s_axi_awready         ,
                      input      [ADDR_WIDTH - 1:0] s_axi_awaddr          ,
                      input      [02:0] s_axi_awprot          ,
                      input             s_axi_awvalid         ,
                        // axi write data channel
                      output reg        s_axi_wready          ,
                      input      [DATA_WIDTH - 1:0] s_axi_wdata           ,
                      input      [(DATA_WIDTH/8) - 1:0] s_axi_wstrb           ,
                      input             s_axi_wvalid          ,
                        // AXI response channel
                      output     [01:0] s_axi_bresp           ,
                      output reg        s_axi_bvalid          ,
                      input             s_axi_bready          ,
                        // AXI read address channel
                      output reg        s_axi_arready         ,
                      input             s_axi_arvalid         ,
                      input      [ADDR_WIDTH - 1:0] s_axi_araddr          ,
                      input      [02:0] s_axi_arprot          ,
                        // AXI read data channel
                      output reg [DATA_WIDTH - 1:0] s_axi_rdata           ,
                      output     [01:0] s_axi_rresp           ,
                      input             s_axi_rready          ,
                      output reg        s_axi_rvalid          ,
                      //---- local control ----
                      input      [31:0] i_action_type         ,
                      input      [KERNEL_NUM-1:0]       kernel_complete
                      );


//---- declarations ----
// For 32bit write data.
 reg [31:0] write_address;
 wire[31:0] wr_mask;

 wire [31:0] write_data_interrupt_control;
 wire [31:0] write_data_interrupt_mask;

 reg [31:0] completion_q;
 ///////////////////////////////////////////////////
 //***********************************************//
 //>                REGISTERS                    <//
 //***********************************************//
 //                                               //
 /**/   reg [31:0] REG_interrupt_control     ;  /*W1C*/
 /**/   reg [31:0] REG_interrupt_mask        ;  /*RW*/
 //                                               //
 //-----------------------------------------------//
 //                                               //
 ///////////////////////////////////////////////////


//---- parameters ----
 // Register addresses arrangement
 parameter ADDR_GLOBAL_INTR_CONTROL          = 32'h30,
           ADDR_GLOBAL_INTR_MASK             = 32'h34,
           ADDR_SNAP_ACTION_TYPE             = 32'h10;






/***********************************************************************
*                          writing registers                           *
***********************************************************************/

//---- write address capture ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     write_address <= 32'd0;
   else if(s_axi_awvalid & s_axi_awready)
     write_address <= s_axi_awaddr;

//---- write address ready ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_awready <= 1'b0;
   else if(s_axi_awvalid)
     s_axi_awready <= 1'b1;
   else if(s_axi_wvalid & s_axi_wready)
     s_axi_awready <= 1'b0;

//---- write data ready ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_wready <= 1'b0;
   else if(s_axi_awvalid & s_axi_awready)
     s_axi_wready <= 1'b1;
   else if(s_axi_wvalid)
     s_axi_wready <= 1'b0;

//---- handle write data strobe ----
 assign wr_mask = {{8{s_axi_wstrb[3]}},{8{s_axi_wstrb[2]}},{8{s_axi_wstrb[1]}},{8{s_axi_wstrb[0]}}};

 assign write_data_interrupt_control            = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_interrupt_control)};
 assign write_data_interrupt_mask               = {(s_axi_wdata&wr_mask)|(~wr_mask&REG_interrupt_mask)};

//---- registers behaviour ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     begin
       REG_interrupt_control     <= 32'd0;
       REG_interrupt_mask        <= 32'd0;
     end
   else if(s_axi_wvalid & s_axi_wready)
     case(write_address)
       ADDR_GLOBAL_INTR_CONTROL       : REG_interrupt_control <= write_data_interrupt_control;
       ADDR_GLOBAL_INTR_MASK          : REG_interrupt_mask    <= write_data_interrupt_mask;

       default :;
     endcase

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        completion_q <= 0; 
    end
end

/***********************************************************************
*                       reading registers                              *
***********************************************************************/

assign REG_interrupt_control_rd = REG_interrupt_control;
assign REG_interrupt_mask_rd = REG_interrupt_mask;

//---- read registers ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_rdata <= 32'd0;
   else if(s_axi_arvalid & s_axi_arready)
     case(s_axi_araddr)
       ADDR_GLOBAL_INTR_CONTROL  : s_axi_rdata <= REG_interrupt_control_rd;
       ADDR_GLOBAL_INTR_MASK     : s_axi_rdata <= REG_interrupt_mask_rd;
       ADDR_SNAP_ACTION_TYPE     : s_axi_rdata <= i_action_type;

       default                  : s_axi_rdata <= 32'h5a5aa5a5;
     endcase

//---- address ready: deasserts once arvalid is seen; reasserts when current read is done ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_arready <= 1'b1;
   else if(s_axi_arvalid)
     s_axi_arready <= 1'b0;
   else if(s_axi_rvalid & s_axi_rready)
     s_axi_arready <= 1'b1;

//---- data ready: deasserts once rvalid is seen; reasserts when new address has come ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_rvalid <= 1'b0;
   else if (s_axi_arvalid & s_axi_arready)
     s_axi_rvalid <= 1'b1;
   else if (s_axi_rready)
     s_axi_rvalid <= 1'b0;




/***********************************************************************
*                        status reporting                              *
***********************************************************************/

//---- axi write response ----
 always@(posedge clk or negedge rst_n)
   if(~rst_n)
     s_axi_bvalid <= 1'b0;
   else if(s_axi_wvalid & s_axi_wready)
     s_axi_bvalid <= 1'b1;
   else if(s_axi_bready)
     s_axi_bvalid <= 1'b0;

 assign s_axi_bresp = 2'd0;

//---- axi read response ----
 assign s_axi_rresp = 2'd0;


endmodule

