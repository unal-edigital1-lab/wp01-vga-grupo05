//Modulo VGA
module VGA_Driver640x480 (
	input rst,
	input clk, 				// 85MHz  para 60 hz de 1368x768
	input  [2:0] pixelIn, 	// entrada del valor de color  pixel 
	output  [2:0] pixelOut, // salida del valor pixel a la VGA 
	output  Hsync_n,		// senal de sincronizacion en horizontal negada
	output  Vsync_n,		// senal de sincronizacion en vertical negada 
	output  [10:0] posX, 	// posicion en horizontal del pixel siguiente
	output  [10:0] posY 		// posicion en vertical  del pixel siguiente
);

//Tamaño de la pantalla en horizontal y vertical, asi como las margenes de la pantalla
localparam SCREEN_X = 1368;  // tamaño de la pantalla visible en horizontal 1368
localparam FRONT_PORCH_X =72;  
localparam SYNC_PULSE_X = 144;
localparam BACK_PORCH_X = 216;  
localparam TOTAL_SCREEN_X = SCREEN_X+FRONT_PORCH_X+SYNC_PULSE_X+BACK_PORCH_X; 	// total pixel pantalla en horizontal 


localparam SCREEN_Y = 768; 	// tamaño de la pantalla visible en Vertical 768
localparam FRONT_PORCH_Y =1;  
localparam SYNC_PULSE_Y = 3;
localparam BACK_PORCH_Y = 23;
localparam TOTAL_SCREEN_Y = SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y+BACK_PORCH_Y; 	// total pixel pantalla en Vertical 


reg  [10:0] countX;
reg  [10:0] countY;

assign posX    = countX;
assign posY    = countY;

assign pixelOut = (countX<SCREEN_X) ? (pixelIn) : (3'b000);

assign Hsync_n = ~((countX>=SCREEN_X+FRONT_PORCH_X) && (countX<SCREEN_X+SYNC_PULSE_X+FRONT_PORCH_X)); 
assign Vsync_n = ~((countY>=SCREEN_Y+FRONT_PORCH_Y) && (countY<SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y));


always @(posedge clk) begin
	if (rst) begin
		countX <= SCREEN_X-10; /*para la simulación sea mas rapido*/
		countY <= SCREEN_Y-4;/*para la simulación sea mas rapido*/
	end
	else begin 
		if (countX >(TOTAL_SCREEN_X-1)) begin
			countX <= 0;
			if (countY > (TOTAL_SCREEN_Y-1)) begin
				countY <= 0;
			end 
			else begin
				countY <= countY + 1;
			end
		end 
		else begin
			countX <= countX + 1;
			countY <= countY;
		end
	end
end

endmodule
