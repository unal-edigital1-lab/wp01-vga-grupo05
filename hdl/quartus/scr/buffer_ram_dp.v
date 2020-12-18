`timescale 1ns / 1ps
module buffer_ram_dp#( 
	parameter AW = 15, // Cantidad de bits  de la direccion de memoria
	parameter DW = 3 // Cantidad de Bits de los datos de memoria
	)(  
	//Reloj de escritura de datos
	input  clk_w, 
	//Variables para puerto 1 de escritura en la memoria
	input  [AW-1: 0] addr_in, 
	input  [DW-1: 0] data_in,
	input  regwrite, 
	
	//Variables para puerto 2 de escritura en la memoria
	input  [AW-1: 0] addr_in2, 
	input  [DW-1: 0] data_in2,
	input  regwrite2, 
	
	//Reloj de electura de datos 
	input  clk_r, 
	//Variables de lectura de datos de la memoria
	input [AW-1: 0] addr_out,
	output reg [DW-1: 0] data_out,
	input reset
	);

// Numero de posiciones totales de memoria y construccion de la matriz para la misma
localparam NPOS = 2 ** AW; 
 reg [DW-1: 0] ram [0: NPOS-1]; 
 
//Bloque que alterna la escritura de los datos de la memoria entre las dos maquinas de estado del juego(dos puertos)
 reg selector=0;
always @(posedge clk_w)begin
		selector=~selector;
		if(selector)begin
			if(regwrite == 1)begin
				ram[addr_in] <= data_in;
			end
			else if(regwrite2 == 1)begin
				ram[addr_in2] <= data_in2;
			end
		end
end

//	 Lectura  de la memoria 
always @(posedge clk_r) begin 
		data_out <= ram[addr_out]; 
end


endmodule
