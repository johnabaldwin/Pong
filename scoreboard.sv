module digit_decoder
#(parameter int OFFSET[2][2] = '{'{30, 30}, '{1200, 600}})
  (
    input unsigned [1 : 0][3:0]  score,
    input signed [11:0] hpos, 
    input signed [11:0] vpos, 
    output logic       active
   );

   reg [1 : 0] actives;
   
   reg [1:0] within_print_range;

   always_comb begin
      
      for (int i = 0; i < $size(score); i++) begin
        within_print_range[i] = (hpos >= OFFSET[i][0] && hpos < OFFSET[i][0] + 60) && (vpos >= OFFSET[i][1] && vpos < OFFSET[i][1] + 100);
        case (score[i]) 
            4'h0    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 80);
            4'h1    : actives[i] = within_print_range[i] && hpos >= (OFFSET[i][0] + 40);
            4'h2    : actives[i] = within_print_range[i] 
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos >= OFFSET[i][0] + 20 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80);
            4'h3    : actives[i] = within_print_range[i] 
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80);
            4'h4    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos < OFFSET[i][1] + 40)
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60);
            4'h5    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80);
            4'h6    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80);
            4'h7    : actives[i] = within_print_range[i] 
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20);
            4'h8    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80);                               
            4'h9    : actives[i] = within_print_range[i] 
                && ~(hpos >= OFFSET[i][0] + 20 && hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 20 && vpos < OFFSET[i][1] + 40)
                && ~(hpos < OFFSET[i][0] + 40 && vpos >= OFFSET[i][1] + 60 && vpos < OFFSET[i][1] + 80); 
            default : actives[i] = (hpos < 500);
        endcase
      end
   end

   assign active = |actives;
endmodule // priority_encoder_4in_case3

module scoreboard #( 

parameter HRES = 1280,
parameter VRES = 720,

parameter COLOR = 24'h FFFFFF
)
    (
        input pixel_clk,
        input rst,
        input fsync, 
        
        input signed [11:0] hpos, 
        input signed [11:0] vpos, 
        
        input increment_score[1:0],
        output [7:0] pixel [0:2] , 
        
        output active 
        
        
    );

    // current scores  
    reg unsigned [1:0][ 3 : 0 ] score;
    
    
    always @(posedge pixel_clk) 
    
    begin 
        if(rst) begin 
            score <= '{default: 0};

        end else begin 
            if (fsync) begin 
                for (int i = 0; i < $size(increment_score); i++)
                begin
                    if(increment_score[i]) begin
                        if (score[i] < 9) 
                            score[i] ++;
                        else if(score[i] == 9) begin
                            score <= '{default: '0};
                        end
                    end
                end
           end 
       end        
end                     


    digit_decoder decoder(.score(score), .hpos(hpos), .vpos(vpos), .active(active));

    /* If active is high, set the RGB values for neon green */
    assign pixel [ 2 ] = (active) ? COLOR [ 23 : 16 ] : 8 'h00; //red 
    assign pixel [ 1 ] = (active) ? COLOR [ 15 : 8 ] : 8 'h00; //green 
    assign pixel [ 0 ] = (active) ? COLOR [ 7 : 0 ] : 8 'h00; //blue  
endmodule





