`timescale 1ns / 1ps

module test_VGA(
    input wire clk,            
    input wire rst,         	// reset button

	// VGA input/output  
    output wire VGA_Hsync_n,  // horizontal sync output
    output wire VGA_Vsync_n,  // vertical sync output
    output wire VGA_R,	// 4-bit VGA red output
    output wire VGA_G,  // 4-bit VGA green output
    output wire VGA_B,  // 4-bit VGA blue output
    output wire clkout,  
 	
	// input: botones para manipular la paleta
		
	input wire bntra,
	input wire bntla
		
);

// TAMAÑO DE visualización 
parameter CAM_SCREEN_X = 176;
parameter CAM_SCREEN_Y = 120;

localparam AW = 15; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 3;

// El color es RGB 111
localparam RED_VGA =   3'b100;
localparam GREEN_VGA = 3'b010;
localparam BLUE_VGA =  3'b001;


// Clk 
wire clk50M;
wire clk85M;

// Conexion por ram de puerto de escritura y lectura

wire  [AW-1: 0] DP_RAM_addr_in;  
wire  [DW-1: 0] DP_RAM_data_in;
wire DP_RAM_regW;

wire  [AW-1: 0] DP_RAM_addr_in2;  
wire  [DW-1: 0] DP_RAM_data_in2;
wire DP_RAM_regW2;

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexión VGA Driver
wire [DW-1:0]data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0]data_RGB444;  // salida del driver VGA al puerto
wire [10:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [10:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA


/* ****************************************************************************
la pantalla VGA es RGB 111 y el almacenamiento en memoria se hace 332

**************************************************************************** */
	assign VGA_R = data_RGB444[2];
	assign VGA_G = data_RGB444[1];
	assign VGA_B = data_RGB444[0];

/* ****************************************************************************
Se realiza divisor de frecuencia de 50MHz a 5KHz (clk de FSM_game)
Se realiza multiplicador de frecuencia de 50MHz a 85MHz (clk para implementación en pantalla VGA)

************************************************************************** */
assign clk50M =clk;
assign clkout=clk85M;

reg clk5K = 0;
reg [13:0] count_ant=0;

always @(posedge clk50M)begin
	
		count_ant=count_ant+1;
		if (count_ant==10000) begin
				clk5K=~clk5K;
				count_ant=0;
	end
end

clk50to85M  clk85Meg(
	.inclk0(clk50M),
	.c0(clk85M));
	


/* ****************************************************************************
buffer_ram_dp buffer memoria dual port y reloj de lectura y escritura separados

**************************************************************************** */
wire [AW-1: 0] cablecito11;
assign cablecito11 = DP_RAM_addr_in;
wire [DW-1: 0]cablecito12;
assign cablecito12 = DP_RAM_data_in;
wire [AW-1: 0] cablecito21;
assign cablecito21 = DP_RAM_addr_in2;
wire [DW-1: 0]cablecito22;
assign cablecito22 = DP_RAM_data_in2;

buffer_ram_dp #( AW,DW,"G:/Github/wp01-vga-grupo05/hdl/quartus/scrimage.men")
	DP_RAM(  
	.clk_w(clk85M), 
	.addr_in(cablecito11), 
	.data_in(cablecito12),
	.regwrite(DP_RAM_regW),
	.addr_in2(cablecito21), 
	.data_in2(cablecito22),
	.regwrite2(DP_RAM_regW2),
	.clk_r(clk85M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	

/* ****************************************************************************
VGA_Driver 1368x768, No se modifica el nombre , pero si varian los valores en el driver de la VGA
**************************************************************************** */
VGA_Driver640x480 VGA640x480
(
	.rst(~rst),
	.clk(clk85M), 				// 25MHz  para 60 hz de 640x480
	.pixelIn(data_mem), 		// entrada del valor de color  pixel RGB 444 
	.pixelOut(data_RGB444), // salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	// señal de sincronizaciÓn en horizontal negada
	.Vsync_n(VGA_Vsync_n),	// señal de sincronizaciÓn en vertical negada 
	.posX(VGA_posX), 			// posición en horizontal del pixel siguiente
	.posY(VGA_posY) 			// posición en vertical  del pixel siguiente

);

/* ****************************************************************************
LÓgica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA. Se realiza escalamiento de 8 veces la imagen, para que ocupe toda la pantalla VGA
**************************************************************************** */
reg[10:0] tempx;
reg[10:0] tempy;
always @ (VGA_posX, VGA_posY) begin
		tempx=VGA_posX/8;
		tempy=VGA_posY/8;
		DP_RAM_addr_out=tempx+tempy*CAM_SCREEN_X;

end

/*****************************************************************************
Bloque de funcionamiento del juego, maquinas de estado de la paleta y de la bola y sus respectivos puertos de memoria
**************************************************************************** */
 FSM_game  juego(
	 	.clk(clk5K),
		.rst(~rst),
		.btn_rh_a(~bntra),
		.btn_lf_a(~bntla),
		.mem_px_addr(DP_RAM_addr_in),
		.mem_px_data(DP_RAM_data_in),
		.px_wr(DP_RAM_regW),
		.mem_px_addr2(DP_RAM_addr_in2),
		.mem_px_data2(DP_RAM_data_in2),
		.px_wr2(DP_RAM_regW2),
   );
	
	
endmodule
