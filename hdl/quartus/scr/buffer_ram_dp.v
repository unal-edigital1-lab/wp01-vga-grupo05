`timescale 1ns / 1ps
module buffer_ram_dp#( 
	parameter AW = 19, // Cantidad de bits  de la direccion 
	parameter DW = 12, // cantidad de Bits de los datos 
	parameter   imageFILE= "image.men")
	(  
	input  clk_w, 
	input  [AW-1: 0] addr_in, 
	input  [DW-1: 0] data_in,
	input  regwrite, 
	
	input  clk_r, 
	input [AW-1: 0] addr_out,
	output reg [DW-1: 0] data_out,
	input reset
	);

// Calcular el nmero de posiciones totales de memoria 
localparam NPOS = 2 ** AW; // Memoria

 reg [DW-1: 0] ram [0: NPOS-1]; 
 

//	 escritura  de la memoria port 1 
always @(negedge clk_w) begin 
       if (regwrite == 1) 
             ram[addr_in] <= data_in;
end

//	 Lectura  de la memoria port 2 
always @(posedge clk_r) begin 
		data_out <= ram[addr_out]; 
end


initial begin
	//$readmemh(imageFILE, ram);
	//ram[0] = 12'b111111111111;
	//ram[1] = 12'b111111111111;
	//ram[2] = 12'b000000001111;
	//ram[3] = 12'b000000001111;
end


endmodule
