`timescale 1ns / 1ps

module test_VGA(
    input wire clk,           // board clock: 32 MHz quacho 100 MHz nexys4 
    input wire rst,         	// reset button

	// VGA input/output  
    output wire VGA_Hsync_n,  // horizontal sync output
    output wire VGA_Vsync_n,  // vertical sync output
    output wire [3:0] VGA_R,	// 4-bit VGA red output
    output wire [3:0] VGA_G,  // 4-bit VGA green output
    output wire [3:0] VGA_B,  // 4-bit VGA blue output
    output wire clkout,  
 	
	// input/output
	
	
	input wire bntra,
	input wire bntla,
	input wire bntrb,
	input wire bntlb
		
);

// TAMAÑO DE visualización 
parameter CAM_SCREEN_X = 640;
parameter CAM_SCREEN_Y = 480;

localparam AW = 19; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 12;

// El color es RGB 444
localparam RED_VGA =   12'b111100000000;
localparam GREEN_VGA = 12'b000011110000;
localparam BLUE_VGA =  12'b000000001111;


// Clk 
wire clk12M;
wire clk25M;

// Conexión dual por ram

wire  [AW-1: 0] DP_RAM_addr_in;  
wire  [DW-1: 0] DP_RAM_data_in;
wire DP_RAM_regW;

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexión VGA Driver
wire [DW-1:0]data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0]data_RGB444;  // salida del driver VGA al puerto
wire [9:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [8:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA


/* ****************************************************************************
la pantalla VGA es RGB 444, pero el almacenamiento en memoria se hace 332
por lo tanto, los bits menos significactivos deben ser cero
**************************************************************************** */
	assign VGA_R = data_RGB444[11:8];
	assign VGA_G = data_RGB444[7:4];
	assign VGA_B = data_RGB444[3:0];





/* ****************************************************************************
  Este bloque se debe modificar según sea le caso. El ejemplo esta dado para
  fpga Spartan6 lx9 a 32MHz.
  usar "tools -> IP Generator ..."  y general el ip con Clocking Wizard
  el bloque genera un reloj de 25Mhz usado para el VGA , a partir de una frecuencia de 12 Mhz
**************************************************************************** */
assign clk12M =clk;

/*
cl_25_24_quartus clk25(
	.areset(rst),
	.inclk0(clk12M),
	.c0(clk25M)
	
);
*/
/*

clk50to85M  clk85(
	.inclk0(clk12M),
	.c0(clk25M));
	
	*/
assign clk25M=clk;
assign clkout=clk25M;

/* ****************************************************************************
buffer_ram_dp buffer memoria dual port y reloj de lectura y escritura separados
Se debe configurar AW  según los calculos realizados en el Wp01
se recomiendia dejar DW a 8, con el fin de optimizar recursos  y hacer RGB 332
**************************************************************************** */
wire [AW-1: 0] cablecito1;
assign cablecito1 = DP_RAM_addr_in;
wire [DW-1: 0]cablecito2;
assign cablecito2 = DP_RAM_data_in;

buffer_ram_dp #( AW,DW,"/home/paula/Descargas/wp01-vga-grupo01/hdl/quartus/scr/image.men")
	DP_RAM(  
	.clk_w(clk25M), 
	.addr_in(cablecito1), 
	.data_in(cablecito2),
	.regwrite(DP_RAM_regW),
	.clk_r(clk25M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	
	
	
	

/* ****************************************************************************
VGA_Driver640x480
**************************************************************************** */
VGA_Driver640x480 VGA640x480
(
	.rst(rst),
	.clk(clk25M), 				// 25MHz  para 60 hz de 640x480
	.pixelIn(data_mem), 		// entrada del valor de color  pixel RGB 444 
//	.pixelIn(RED_VGA), 		// entrada del valor de color  pixel RGB 444 
	.pixelOut(data_RGB444), // salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	// señal de sincronizaciÓn en horizontal negada
	.Vsync_n(VGA_Vsync_n),	// señal de sincronizaciÓn en vertical negada 
	.posX(VGA_posX), 			// posición en horizontal del pixel siguiente
	.posY(VGA_posY) 			// posición en vertical  del pixel siguiente

);

 
/* ****************************************************************************
LÓgica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA si la imagen de la camara es menor que el display  VGA, los pixeles 
adicionales seran iguales al color del último pixel de memoria 
**************************************************************************** */

always @ (VGA_posX, VGA_posY) begin
		if ((VGA_posX>CAM_SCREEN_X) || (VGA_posY>CAM_SCREEN_Y))
			DP_RAM_addr_out=19212;
		else
			DP_RAM_addr_out=VGA_posX+VGA_posY*CAM_SCREEN_Y;
end


//assign DP_RAM_addr_out=10000;

/*****************************************************************************

este bloque debe crear un nuevo archivo 
**************************************************************************** */
 FSM_game  juego(
	 	.clk(clk25M),
		.rst(rst),
		.btn_rh_a(btnra),
		.btn_lf_a(btnla),
		.btn_rh_b(btnrb),
		.btn_lf_b(btnlb),
		.mem_px_addr(DP_RAM_addr_in),
		.mem_px_data(DP_RAM_data_in),
		.px_wr(DP_RAM_regW)
   );
	
	
endmodule
