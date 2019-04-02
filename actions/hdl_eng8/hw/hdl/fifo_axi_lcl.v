`timescale 1ns/1ps

`define DEPTH 256
`define D_W 8
module fifo_axi_lcl(
                    input             clk  ,
                    input             rst_n, 
                    input             clr  ,
                                           
                    //FIFO status           
                    output reg        ovfl ,
                    output reg        udfl ,
                                           
                    //data input ports      
                    input             iend , //synced with,or after the last input data
                    output reg        irdy , //stop asserting den when irdy is 0, but with margin
                    input             den  , 
                    input     [63:0] din  ,
                                           
                    //data output ports     
                    input             rdrq , //MUST be deasserted when olast is 1
                    output            olast, //synced with the last output data
                    output reg        ordy , //stop asserting rdrq when ordy is 0, but with margin
                    output    [63:0] dout , 
                    output            dv   , 
                    output            empty,
                    output reg        flush
                    );


             
 reg [`D_W-1:0] i_cnt     ;
 reg [`D_W-1:0] o_cnt     ;
 wire[`D_W-1:0] cnt       ;
 wire        full      ;


 parameter IH_LIM = `DEPTH-6,
           IL_LIM = `DEPTH/2,
           OH_LIM = `DEPTH/2,
           OL_LIM = 4;
           
           
//---input data count---
 always@(posedge clk or negedge rst_n)
   if(~rst_n) 
     i_cnt <= 0;
   else if(clr | olast)  //hold the last value, i.e. the number of frame data till they're all read
     i_cnt <= 0;
   else if(den)
     i_cnt <= i_cnt + `D_W'd1;
     
//---output data count---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     o_cnt <= 0;
   else if(clr | olast)  //clear the counter when all frame data are read
     o_cnt <= 0;
   else if(rdrq)
     o_cnt <= o_cnt + `D_W'd1;       

//---flush the rest of the frame data out---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     flush <= 1'b0;
   else if(clr | olast)  //deasserted when all frame data are out of the buffer
     flush <= 1'b0;
   else if(iend)        //asserted when all frame data are in the buffer
     flush <= 1'b1;     

//---input ready, input data allowed to be in when asserted, and forbidden when deasserted---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     irdy <= 1'b0;
   else if(clr)
     irdy <= 1'b0;
   else if(flush | iend)   //input forbidden during flush
     irdy <= 1'b0;
   else if((cnt < IL_LIM) | (cnt == IL_LIM))
     irdy <= 1'b1;
   else if((cnt > IH_LIM) | (cnt == IH_LIM))
     irdy <= 1'b0;

//---output ready, output request responded accordingly when asserted, and forbidden when deasserted---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     ordy <= 1'b0;
   else if(clr)
     ordy <= 1'b0;
   else if(flush)   //output available during flush
     begin
       if(olast)   
         ordy <= 1'b0;
       else 
         ordy <= 1'b1;
     end
   else if((cnt < OL_LIM) | (cnt == OL_LIM))
     ordy <= 1'b0;
   else if((cnt > OH_LIM) | (cnt == OH_LIM))
     ordy <= 1'b1; 

//---the last-data output indicator---
 assign olast = rdrq & flush & (o_cnt == i_cnt - `D_W'd1);
 
//---indicate overflowing---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     ovfl <= 1'b0;
   else if(clr)
     ovfl <= 1'b0;
   else if(full & den)
     ovfl <= 1'b1; 
     
//---indicate underflowing---
 always@(posedge clk or negedge rst_n)
   if(~rst_n)      
     udfl <= 1'b0;
   else if(clr)
     udfl <= 1'b0;
   else if(empty & rdrq)
     udfl <= 1'b1; 
     
//---buffering FIFO---
 fifo_sync_256_64i64o mfifo_buf (
  .clk(clk), // input clk
  .rst(~rst_n | clr), // input rst
  .din(din), // input [511 : 0] din
  .wr_en(den), // input wr_en
  .rd_en(rdrq), // input rd_en
  .valid(dv), // output dv
  .dout(dout), // output [511 : 0] dout
  .full(full), // output full
  .empty(empty), // output empty
  .data_count(cnt) // output [4 : 0] data_count
  );
              
 
                          
endmodule
