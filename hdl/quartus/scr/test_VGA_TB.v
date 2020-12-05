`timescale 10ns / 1ns

module test_VGA_TB;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire VGA_Hsync_n;
	wire VGA_Vsync_n;
	wire VGA_R;
	wire VGA_G;
	wire VGA_B;
   wire bntr;
	wire bntl;
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
		.bntr(bntr),
		.bntl(bntr),
		.clkout(clkout)
	
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		#200;
		rst = 0;
	end

	//always #2 clk  = ~clk; //para 25 megas
	always #4 clk  = ~clk; // para 12 megas
	
	reg [9:0]line_cnt=0;
	reg [9:0]row_cnt=0;
	
	
	
	/*************************
			INICIO DE  GENERACION DE ARCHIVO test_vga	
	**************************/

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
   end
	
	reg clk_w =0;
	always #1 clk_w  = ~clk_w;
	
	/* ecsritura de log para cargar se cargados en https://ericeastwood.com/lab/vga-simulator/*/
	initial forever begin
	@(posedge clk_w)
		$fwrite(f,"%0t ps: %b %b %b00 %b00 %b0\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R,VGA_G,VGA_B);
		$display("%0t ps: %b %b %b00 %b00 %b0\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R,VGA_G,VGA_B);
		
	end
	
endmodule