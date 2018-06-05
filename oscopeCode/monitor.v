module monitor(
    input  CLK,             // board clock: 100 MHz on Arty & Basys 3
    input  RST_BTN,         // reset button
    output  VGA_HS_O,       // horizontal sync output
    output  VGA_VS_O,       // vertical sync output
    output  [7:0] VGA_R,    // 4-bit VGA red output
    output  [7:0] VGA_G,    // 4-bit VGA green output
    output  [7:0] VGA_B,     // 4-bit VGA blue output
	 output  vgaclock
    );

    wire rst = ~RST_BTN;  // reset is active low on Arty

    // generate a 25 MHz pixel strobe
    reg [15:0] cnt = 0;
    reg pix_stb = 0;
    always @(posedge CLK)
        {pix_stb, cnt} <= cnt + 16'h8000;  // divide clock by 4: (2^16)/4 = 0x4000

    wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
    wire [8:0] y;  // current pixel y position:  9-bit value: 0-511

    vga640x480 display (
        .i_clk(CLK),
        .i_pix_stb(pix_stb),
        .o_hs(VGA_HS_O), 
        .o_vs(VGA_VS_O), 
        .o_x(x), 
        .o_y(y)
    );

    // Four overlapping squares
    wire sq_a, sq_b, sq_c, sq_d;
    assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;
assign vgaclock=pix_stb;
    assign VGA_R[7] = sq_b;         // square b is red
    assign VGA_G[7] = sq_a | sq_d;  // squares a and d are green
    assign VGA_B[7] = sq_c;         // square c is blue
endmodule