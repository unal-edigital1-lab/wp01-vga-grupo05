`timescale 10ns / 1ns

module test_VGA_TB;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire VGA_Hsync_n;
	wire VGA_Vsync_n;
	wire [3:0] VGA_R;
	wire [3:0] VGA_G;
	wire [3:0] VGA_B;
   reg bntra;
	reg bntla;
	reg bntrb;
	reg bntlb;
	wire clkout;

	// Instantiate the Unit Under Test (UUT)
	test_VGA uut (
		.clk(clk), 
		.rst(rst), 
		.VGA_Hsync_n(VGA_Hsync_n), 
		.VGA_Vsync_n(VGA_Vsync_n), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.bntra(bntra),
		.bntla(bntla),
		.bntrb(bntrb),
		.bntlb(bntlb),
		.clkout(clkout)
	
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		#614400;
		rst = 0;
		
		bntra=0;
		bntla=0;
		bntrb=0;
		bntlb=0;
	/*	bntra=1;
		#5
		bntra=0;
		bntla=1;
		#5000
		bntla=0;
		bntrb=1;
		#5000
		bntrb=0;
		bntlb=1;
		#5000
		bntlb=0;*/
	end

	always #2 clk  = ~clk;
	
	
	reg [9:0]line_cnt=0;
	reg [9:0]row_cnt=0;
	
	
	
	/*************************************************************************
			INICIO DE  GENERACION DE ARCHIVO test_vga	
	**************************************************************************/

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
   end
	
	reg clk_wf =0;
	always #2 clk_wf  = ~clk_wf;
	
	/* ecsritura de log para cargar se cargados en https://ericeastwood.com/lab/vga-simulator/*/
	initial forever begin
	@(posedge clk_wf)
		$fwrite(f,"%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R[3:1],VGA_G[3:1],VGA_B[3:2]);
//		$display("%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R[3:1],VGA_G[3:1],VGA_B[3:2]);
		
	end
	
endmodule
