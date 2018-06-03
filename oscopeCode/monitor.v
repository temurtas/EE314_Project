// video module for the DE1-SoC board
// Jan 2016
// by Fred Aulich
// capture frame from video in and save in low and high memory

module monitor (
// video out chip

vid_clk		, // 25 Mhz clock to video chip
clk			, // 50 Mhz clock 
vsync			, // video vertical sync
hsync			, // video horizontal sync
vid_blank	, // video blank 
gpio			  // 40 pin header
		
);

// signal directions

input 		clk;

inout 		vsync;
inout 		hsync; 
inout			vid_blank;

output[15:0]		gpio;
output 		vid_clk;

// external module registers

reg[7:0]		video_mot;
reg[15:0]	address_mot;
reg[15:0]	data_motl;
reg[15:0]	data_moth;
reg[15:0]	gpio;
reg[4:0]	   clkcount; // clock divider

// internal registers

reg[16:0]	ramaddressl_odd;  // address read from memory odd lines
reg[16:0]	ramaddressl_even; // address read from memory even lines
reg[10:0]	contvidv; // vertical counter
reg[10:0]	contvidh; // horizontal counter
reg			oddeven;// odd even line counter 
reg			vid_clk;
////////////////////////////////////////
/// general clock divider 
/////////////////////////////////////////

 
 always @ (posedge clk )

begin 
		
		clkcount <= clkcount + 1;
		
end

///////////////////////////
///  25 Mhz clock    //////
///////////////////////////

always vid_clk <= clkcount[0]; 

/////////////////////////////////
//// control values 				///
/////////////////////////////////

wire			vsync = ((contvidv >= 491) & (contvidv < 493))? 1'b0 : 1'b1;
wire			hsync = ((contvidh >= 664) & (contvidh < 760))? 1'b0 : 1'b1;
wire			vid_blank = ((contvidv >= 8) & (contvidv <  420) &(contvidh >= 20) & (contvidh < 624))? 1'b1 : 1'b0;
wire			clrvidh = (contvidh <= 800) ? 1'b0 : 1'b1;
wire  		clrvidv = (contvidv <= 525) ? 1'b0 : 1'b1;
wire  		ramvidv = ( ( (contvidv <= 420) ) ? 1'b0 : 1'b1); 

///////////////////////////////////////////
//////// memory enables						////
///////////////////////////////////////////

wire			adden = ( (( contvidh < 624) & (contvidv <= 420) ) ? 1'b1 : 1'b0); // address enable

wire			read = (vid_clk & adden) ? 1'b1 : 1'b0; // oe to memory enable
wire 			read_ll = ( adden & !ramaddressl_odd[0] & vid_clk & !oddeven ) ? 1'b0 : 1'b1; // low odd address enable
wire			read_hl = (adden & ramaddressl_odd[0] & vid_clk & !oddeven ) ? 1'b0 : 1'b1; // low even address enable
wire			read_lh = ( adden & !ramaddressl_even[0] & vid_clk & oddeven ) ? 1'b0 : 1'b1; // high odd address enable
wire			read_hh = ( adden & ramaddressl_even[0] & vid_clk & oddeven ) ? 1'b0 : 1'b1; // high even address enable

parameter address_low = 19'h00000;  // lower address start at 0 meg

//////////////////////////////
/// assignment pins        ///
//////////////////////////////

always oddeven <= contvidv[0]; // odd line and even line counter

/////////////////////////////////
// horizontal counter        ////
/////////////////////////////////

always @ (posedge vid_clk )

begin 

		if(clrvidh)
		begin
		contvidh <= 0;
		end
		
		else
		begin
		contvidh <= contvidh + 1;
		end
end

/////////////////////////////////////////
//vertical counter when clrvidv is low //
/////////////////////////////////////////

always @ (posedge vid_clk)

begin 

		if (clrvidv)
		begin
		contvidv <= 0;
		end
		
		else
		begin
			if
			(contvidh == 798)
			begin
			contvidv <= contvidv + 1; // 798 horizontal pixels
			end
		end
end

/////////////////////////////////////////////////////////
// address counter out to monitor odd lines low memory //
/////////////////////////////////////////////////////////

always @ (posedge vid_clk )

begin 

		if(ramvidv)
		begin
		ramaddressl_odd <= address_low;// memory reset to "0"
		end
		
		else
		begin
		if (adden & !oddeven )
			begin
			ramaddressl_odd <= ramaddressl_odd + 1;
			end 
		end
end

///////////////////////////////////////////////////////////
// address counter out to monitor even lines low memory  //
///////////////////////////////////////////////////////////

always @ (posedge vid_clk)

begin 

		if (ramvidv)
		begin
		ramaddressl_even <= address_low; // memory reset to "0"
		end
		
		else
		begin
			if
			(adden & oddeven )
			begin
			ramaddressl_even <= ramaddressl_even + 1; // 798 horizontal pixels
			end
		end
end


//////////////////////////////////////////////////////////////////
//////// latch address and data from memory							///
//////////////////////////////////////////////////////////////////

always @ (negedge vid_clk)

begin
		if (!read_ll )
		begin

		video_mot <= data_motl[7:0];
		address_mot <= ramaddressl_odd[16:1]; // memory odd byte low 
		end
		
		else 
		
		
		if (!read_hl )
		begin

		video_mot <= data_motl[15:8];
		address_mot <= ramaddressl_odd[16:1]; // memory odd byte high
		end
		
		else
		
		
		if (!read_lh )
		begin

		video_mot <= data_moth[7:0];
		address_mot <= ramaddressl_even[16:1]; // memory even byte low
		end
		
		else
		
		
		if (!read_hh )
		begin

		video_mot <= data_moth[15:8];
		address_mot <= ramaddressl_even[16:1]; // memory even byte high
		end
		
end		

////////////////////////////////////////////////
/// test pins 40 pin header to logic analyzer///
////////////////////////////////////////////////

always gpio[0] <= vid_clk;
always gpio[1] <= read;
always gpio[2] <= adden;
always gpio[3] <= oddeven;
always gpio[4] <= read_ll;
always gpio[5] <= read_hl;
always gpio[6] <= read_lh;
always gpio[7] <= read_hh;
always gpio[15:8] <= address_mot[7:0];


endmodule
	