`timescale 1ns / 1ps

module FSM_game #( 
	parameter AW = 15, // Cantidad de bits  de la direccion 
	parameter DW = 3 // cantidad de Bits de los datos 
	)(
		//clk,reset
	 	input clk,
		input rst,
		
		//Botones de entrada RIGHT y LEFT
		input btn_rh_a,
      input btn_lf_a,

		//Variables de memoria de los dos puertos para las maquinas de estado
		output reg [AW-1: 0] mem_px_addr,
		output reg [DW-1: 0] mem_px_data,
		output reg px_wr,
		output reg [AW-1: 0] mem_px_addr2,
		output reg [DW-1: 0] mem_px_data2,
		output reg px_wr2
   );
 //parametros de la pantalla
	parameter COLOR_OBJECT=3'b111;//Color de la paleta y bola
	parameter COLOR_SCREEN=3'b101;//Color de fondo
	parameter bits_SCREEN176=8;
	parameter SCREEN176= 176; //Tamaño X pantalla de visualizacion
	parameter SCREEN120= 120; //Tamaño X pantalla de visualizacion

	parameter PALLET_W=46;// Tamaño horizontal de la paleta
	parameter PALLET_H=5;// Tamaño vertical de la paleta
	parameter POSX_PALLET=60; //Ubicacion inicial de la paleta en el eje x
	parameter POSY_PALLET=90; //Ubicacion inicial de la paleta en el eje y
	reg [AW-1:0] pos_init =0; //Registro donde se guardara la posicion de la paleta cuando se mueve
	reg [8:0]pos_line =0; //Registro guia para construir la paleta
	reg[5:0] count;

	//Estados de la maquina de estados de la paleta
	reg [2:0] status_pallet =0;
	parameter START_PALLET=0, DRAW_PALLET=1,  PLAY_GAME=2, PALLET_MOVE_RH=3, PALLET_MOVE_LF=4, END_GAME_PALLET=5;
	//Estados de la maquina de estados de la pelota
	reg [3:0] status_ball = 0;
	parameter START_BALL=0, PLAY_VERTICAL=1, RIGHT=2, LEFT=3, UP=4, DOWN=5, PLAY_HORIZONTAL=6, END_GAME_BALL=9;

	reg [7:0] POSX_BALL; //Registro de posicion de la pelota en el eje x
	reg [7:0] POSY_BALL; //Registro de posicion de la pelota en el eje y
	
	//dirección de la pelota
	reg dirX=0;
	reg dirY=0;
	reg [3:0] count_ball;
	reg done_ball=0;
	reg print_ball=0;
	

/* **************************************************
MAQUINA DE ESTADOS DE LA PALETA
*************************************************** */

always @(posedge clk) begin
		if (rst) begin
			pos_init =0;
			count <= 0;
			px_wr <=0;
			status_pallet <=START_PALLET;
		end 
    
	case (status_pallet)

	  START_PALLET:begin
			  pos_init=pos_init+1;
			  px_wr <=1;
			  mem_px_addr<= pos_init;
			  mem_px_data<=COLOR_SCREEN;
			 
			  if (pos_init>(SCREEN176*SCREEN120))begin
					pos_init=POSY_PALLET*SCREEN176+POSX_PALLET;
				   pos_line=0;
				 status_pallet <=DRAW_PALLET;
				 count<=0;
			  end
		  end
			
		//pinta la paleta 	
	  DRAW_PALLET:begin
				px_wr<=1;
				count<=count+1;
				if(count<PALLET_W)begin
						mem_px_addr <= pos_init+count;
						mem_px_data <= COLOR_OBJECT;
				end
				if(count==PALLET_W)begin
						mem_px_addr <= pos_init-1;
						mem_px_data <= COLOR_SCREEN;
				end
				if(count==PALLET_W+1)begin
						mem_px_addr <= pos_init+count-1;
						mem_px_data <= COLOR_SCREEN;
						status_pallet<=PLAY_GAME;
				end						
		end	 
			 
		PLAY_GAME: begin
			count<=0;
			px_wr<=0;
			if(btn_rh_a)begin
				if ((pos_init+PALLET_W) < SCREEN176*POSY_PALLET+SCREEN176)begin
					status_pallet <=PALLET_MOVE_RH;
				end
				else begin
				status_pallet<=PLAY_GAME;
				end
			end
			if(btn_lf_a)begin
				if(pos_init > POSY_PALLET*SCREEN176)begin
			  status_pallet <=PALLET_MOVE_LF;
			  end
			  else begin
				status_pallet<=PLAY_GAME;
				end
			end
		end

		PALLET_MOVE_RH:begin
	 
				pos_init=pos_init+1;
				status_pallet<=DRAW_PALLET;
		 
		end 
		PALLET_MOVE_LF:begin
				pos_init=pos_init-1;
				status_pallet<=DRAW_PALLET;
			 
		end

		END_GAME_PALLET:begin
		end	
		default:begin
		status_pallet <=START_PALLET;
		end
	endcase		
end
	
/* **************************************************
MAQUINA DE ESTADOS DE LA PELOTA
*************************************************** */

	always @(posedge clk)begin
		if (rst) begin
			count_ball<=0;
			px_wr2<=0;
		end
		
		if(print_ball)begin
			done_ball=0;
			px_wr2<=1;
			count_ball<=count_ball+1;
			case(count_ball)
				1:begin
					mem_px_addr2 <= ((POSX_BALL-1)+(POSY_BALL)*SCREEN176);
					mem_px_data2 <= COLOR_SCREEN;
				end
				2:begin
					mem_px_addr2 <= ((POSX_BALL)+(POSY_BALL)*SCREEN176);
					mem_px_data2 <= COLOR_OBJECT;
				end
				3:begin
					mem_px_addr2 <= ((POSX_BALL+1)+(POSY_BALL)*SCREEN176);
					mem_px_data2 <= COLOR_SCREEN;
				end
				4:begin
					mem_px_addr2 <= ((POSX_BALL)+(POSY_BALL-1)*SCREEN176);
					mem_px_data2 <= COLOR_SCREEN;
				end
				5:begin
					mem_px_addr2 <= ((POSX_BALL)+(POSY_BALL+1)*SCREEN176);
					mem_px_data2 <= COLOR_SCREEN;
					done_ball=1;
					count_ball<=0;
					print_ball=0;
				end
			endcase	
		end
		
		
		case(status_ball) 
		
				START_BALL: begin
					POSX_BALL=40;
					POSY_BALL=40;
					print_ball=1;
					if(done_ball)begin
						print_ball=0;
						status_ball=PLAY_VERTICAL;
					end
				end
				
				PLAY_VERTICAL: begin
					if(done_ball)begin
						print_ball=0;
						if(dirY)begin
							status_ball<=DOWN;
						end else begin
							status_ball<=UP;
						end
					end
				end
				
				UP: begin
					if(POSY_BALL>4)begin
						POSY_BALL = POSY_BALL-1;
					end else begin
						dirY=~dirY;
					end
					print_ball=1;
					status_ball<=PLAY_HORIZONTAL;
				end
				
				DOWN: begin
					if(done_ball)begin
						print_ball=0;
						if(POSY_BALL<POSY_PALLET-2)begin
							POSY_BALL = POSY_BALL+1;
						end else begin
							if(POSX_BALL<(mem_px_addr+PALLET_W) && POSX_BALL>mem_px_addr) begin
								dirY=~dirY;
							end else begin
								status_pallet<=START_BALL;
							end
						end
							print_ball=1;
						status_ball<=PLAY_HORIZONTAL;
					end
				end
				
				PLAY_HORIZONTAL: begin
					if(done_ball)begin
						print_ball=0;
						if(dirX)begin
							status_ball<=RIGHT;
						end else begin
							status_ball<=LEFT;
						end
					end
				end
				
				RIGHT:begin
					if(done_ball)begin
						print_ball=0;
						if(POSX_BALL<SCREEN176-3)begin
							POSX_BALL=POSX_BALL+1;
						end else begin
							dirX=~dirX;
						end
						print_ball=1;
						status_ball<=PLAY_VERTICAL;
					end
				end
				
				LEFT:begin
					if(done_ball)begin
						print_ball=0;
						if(POSX_BALL>4)begin
							POSX_BALL=POSX_BALL-1;
						end else begin
							dirX=~dirX;
						end
						print_ball=1;
						status_ball<=PLAY_VERTICAL;
					end
				end
				
		endcase
		
		
	end
	
	
	
	
	
	
	






endmodule 