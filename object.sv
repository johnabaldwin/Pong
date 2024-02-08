`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2024 12:00:57 PM
// Design Name: 
// Module Name: object
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module object #( 

// Image resolution
parameter HRES = 1280,
parameter VRES = 720,

// Object Color
parameter COLOR = 24'h 00FF90,

// Paddle Height
parameter PADDLE_H = 20
)
(
    input pixel_clk,
    input rst,
    input fsync, 
    
    // ball location
    input signed [11:0] hpos, 
    input signed [11:0] vpos, 
    
    output [7:0] pixel [0:2] , 
    
    output active 
    
    
);
    localparam OBJ_SIZE = 50; 
    localparam [1:0] DOWN_RIGHT = 2'b00; 
    localparam [1:0] DOWN_LEFT  = 2'b01; 
    localparam [1:0] UP_RIGHT   = 2'b10; 
    localparam [1:0] UP_LEFT    = 2'b11;
    
    // Velocity of ball, 12 pixels per clock cycle
    localparam VEL = 5; 
    
    // Ball location in horizontal/vertical format
    reg signed [11 : 0  ] lhpos; // left horizontal position 
    reg signed [11 : 0  ] rhpos; //right horizonat position 
    reg signed [11 : 0  ] tvpos; // top vertical position 
    reg signed [11 : 0  ] bvpos; // bottom vertical position
    
    
    reg [1 : 0 ] dir ; // direction of object 
    
    /* Calculate the direction when the object hits the four walls */
    always @(posedge pixel_clk) 
    begin 
        if(rst) begin 
           /* Insert values to reset here */
        end else if (fsync) begin 
            /* Insert your code for calculating the direction of the ball when it hits a wall here */
                               /* DOWN_LEFT, DOWN_RIGHT, UP_LEFT, UP_RIGHT */
            if(dir == DOWN_RIGHT) begin 
                if (bvpos >= VRES - PADDLE_H) begin 
                    dir <= UP_RIGHT; 
                end else if (rhpos >= HRES - 1) begin 
                    dir <= DOWN_LEFT;
                end 
            end 

            if(dir == DOWN_LEFT) begin
                if (bvpos >= VRES - PADDLE_H) begin
                    dir <= UP_LEFT;
                end else if (lhpos <= 0) begin
                    dir <= DOWN_RIGHT;
                end
            end

            if(dir == UP_RIGHT) begin 
                if (tvpos <= PADDLE_H) begin 
                    dir <= DOWN_RIGHT; 
                end else if (rhpos >= HRES - 1) begin 
                    dir <= UP_LEFT;
                end 
            end 
            
            if(dir == UP_LEFT) begin 
                if (tvpos <= PADDLE_H) begin 
                    dir <= DOWN_LEFT; 
                end else if (lhpos <= 0) begin 
                    dir <= UP_RIGHT;
                end 
            end            
        end 
   end 
   
   
   
   
    always @(posedge pixel_clk)     
    begin 
        if(rst) begin 
            // set ball to the middle of the screen
            lhpos <= (HRES - OBJ_SIZE)/2;
            rhpos <= (HRES + OBJ_SIZE)/2;
            tvpos <= (VRES - OBJ_SIZE)/2;
            bvpos <= (VRES + OBJ_SIZE)/2;

        end else if (fsync) begin 
           /* Insert your code for calculating whether the ball is still within bounds */
           /* Then update */ 

            // Example Code
            if  (dir == DOWN_RIGHT) begin // Check if new ball location is still within bounds 
                    lhpos <= lhpos + VEL; 
                    rhpos <= rhpos + VEL; 
                    tvpos <= tvpos + VEL; 
                    bvpos <= bvpos + VEL;     
            end else if (dir == DOWN_LEFT) begin
                    lhpos <= lhpos - VEL;
                    rhpos <= rhpos - VEL;
                    tvpos <= tvpos + VEL;
                    bvpos <= bvpos + VEL;
            end else if (dir == UP_RIGHT) begin
                    lhpos <= lhpos + VEL; 
                    rhpos <= rhpos + VEL; 
                    tvpos <= tvpos - VEL; 
                    bvpos <= bvpos - VEL;

            end else if (dir == UP_LEFT) begin
                    lhpos <= lhpos - VEL;
                    rhpos <= rhpos - VEL;
                    tvpos <= tvpos - VEL;
                    bvpos <= bvpos - VEL;
            end
        end 
    end 
    
                                    
    /* Active calculates whether the current pixel being updated by the HDMI controller is within the bounds of the ball's */
    /* Simple Example: If the ball is located at position 0,0 and vpos and rpos = 0, active will be high, placing a green pixel */
    assign active = (hpos >= lhpos && hpos <= rhpos && vpos >= tvpos && vpos <= bvpos ) ? 1'b1 : 1'b0 ; 
    
    /* If active is high, set the RGB values for neon green */
    assign pixel [ 2 ] = (active) ? COLOR [ 23 : 16 ] : 8 'h00; //red 
    assign pixel [ 1 ] = (active) ? COLOR [ 15 : 8 ] : 8 'h00; //green 
    assign pixel [ 0 ] = (active) ? COLOR [ 7 : 0 ] : 8 'h00; //blue 
    
     
    
endmodule
