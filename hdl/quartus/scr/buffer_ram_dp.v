`timescale 1ns / 1ps
module buffer_ram_dp#( 
	parameter AW = 15, // Cantidad de bits  de la direccion 
	parameter DW = 3, // cantidad de Bits de los datos 
	parameter   imageFILE= "image.men")
	(  
	input  clk_w, 
	input  [AW-1: 0] addr_in, 
	input  [DW-1: 0] data_in,
	input  regwrite, 
	input  [AW-1: 0] addr_in2, 
	input  [DW-1: 0] data_in2,
	input  regwrite2, 
	
	input  clk_r, 
	input [AW-1: 0] addr_out,
	output reg [DW-1: 0] data_out,
	input reset
	);

// Calcular el nmero de posiciones totales de memoria 
localparam NPOS = 2 ** AW; // Memoria

 reg [DW-1: 0] ram [0: NPOS-1]; 
 reg mux=0;
always @(posedge clk_w)begin
		mux=~mux;
		if(mux)begin
			if(regwrite == 1)begin
				ram[addr_in] <= data_in;
			end
			else if(regwrite2 == 1)begin
				ram[addr_in2] <= data_in2;
			end
		end
end

/*//	 escritura  de la memoria port 1 
always @(negedge clk_w) begin 
       if (regwrite == 1) 
             ram[addr_in] <= data_in;
end

//	 escritura  de la memoria port 1 
always @(negedge clk_w) begin 
       if (regwrite2 == 1) 
             ram[addr_in2] <= data_in2;
end*/

//	 Lectura  de la memoria port 2 
always @(posedge clk_r) begin 
		data_out <= ram[addr_out]; 
end




endmodule
