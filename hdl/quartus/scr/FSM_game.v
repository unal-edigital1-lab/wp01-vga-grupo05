`timescale 1ns / 1ps
//arreglar parte cuando la pelota choca en la paleta rd, ld
//borrar estado anterior de la pelota
//cuadrar si es la paleta de abajo o la de arriba en ball
module FSM_game #( 
	parameter AW = 15, // Cantidad de bits  de la direccion 
	parameter DW = 3 // cantidad de Bits de los datos 
	)(
	 	input clk,
		input rst,
		input btn_rh_a,
      input btn_lf_a,
		input btn_rh_b,
      input btn_lf_b,
		//input btn_start,
		output reg [AW-1: 0] mem_px_addr,
		output reg [DW-1: 0] mem_px_data,
		output reg px_wr,
		output reg [AW-1: 0] mem_px_addr2,
		output reg [DW-1: 0] mem_px_data2,
		output reg px_wr2,
		output reg led
   );
 //parametros
	parameter COLOR_OBJECT=3'b111;
	parameter COLOR_SCREEN=3'b101;
	parameter bits_SCREEN176=8;
	parameter SCREEN176= 176;
	parameter SCREEN120= 120;

	parameter score_limit = 10;
	parameter PALLET_W=46;
	parameter PALLET_H=5;
	parameter POSX_PALLET=60;
	parameter POSY_PALLET=90;

	reg [3:0] a_score = 0;
	reg [3:0] b_score = 0;
	

	localparam tamano_X = 176;
	localparam tamano_Y = 120;
	
	reg [3:0] status_bola = 0;
	
	//dirección de la pelota
	reg dirX=0;
	reg dirY=0;
	
	reg [7:0] posX_bola;
	reg [7:0] posY_bola;
	
	//Estados de la pelota 
	parameter START_BALL=0, MOVE_V=1, RIGHT=2, LEFT=3, UP=4, DOWN=5, MOVE_H=6, FIN=9;
	
	reg [3:0] count_Tam_ball;
	reg done_ball=0;
	reg ball_draw=0;
	reg [AW-1]pos_init2=0;
	assign pos_init2=mem_px_addr;
	
	always @(posedge clk)begin
		if (rst) begin
			count_Tam_ball<=0;
			px_wr2<=0;
		end
		
		if(ball_draw)begin
			done_ball=0;
			px_wr2<=1;
			count_Tam_ball<=count_Tam_ball+1;
			case(count_Tam_ball)
				1:begin
					mem_px_addr2 <= ((posX_bola-1)+(posY_bola)*tamano_X);
					mem_px_data2 <= COLOR_SCREEN;
				end
				2:begin
					mem_px_addr2 <= ((posX_bola)+(posY_bola)*tamano_X);
					mem_px_data2 <= 7;
				end
				3:begin
					mem_px_addr2 <= ((posX_bola+1)+(posY_bola)*tamano_X);
					mem_px_data2 <= COLOR_SCREEN;
				end
				4:begin
					mem_px_addr2 <= ((posX_bola)+(posY_bola-1)*tamano_X);
					mem_px_data2 <= COLOR_SCREEN;
				end
				5:begin
					mem_px_addr2 <= ((posX_bola)+(posY_bola+1)*tamano_X);
					mem_px_data2 <= COLOR_SCREEN;
					done_ball=1;
					count_Tam_ball<=0;
					ball_draw=0;
				end
			endcase	
		end
		
		
		case(status_bola) 
		
				START_BALL: begin
					posX_bola=20;
					posY_bola=20;
					ball_draw=1;
					if(done_ball)begin
						ball_draw=0;
						status_bola=MOVE_V;
					end
				end
				
				MOVE_V: begin
					if(done_ball)begin
						ball_draw=0;
						if(dirY)begin
							status_bola<=DOWN;
						end else begin
							status_bola<=UP;
						end
					end
				end
				
				UP: begin
					if(posY_bola>4)begin
						posY_bola = posY_bola-1;
					end else begin
						dirY=~dirY;
					end
					ball_draw=1;
					status_bola<=MOVE_H;
				end
				
				DOWN: begin
					if(done_ball)begin
						ball_draw=0;
						if(posY_bola<POSY_PALLET-2)begin
							posY_bola = posY_bola+1;
						end else begin
							if(posX_bola<(pos_init2+PALLET_W) && posX_bola>pos_init2) begin
								dirY=~dirY;
							end else begin
								status<=START_BALL;
							end
						end
							ball_draw=1;
						status_bola<=MOVE_H;
					end
				end
				
				MOVE_H: begin
					if(done_ball)begin
						ball_draw=0;
						if(dirX)begin
							status_bola<=RIGHT;
						end else begin
							status_bola<=LEFT;
						end
					end
				end
				
				RIGHT:begin
					if(done_ball)begin
						ball_draw=0;
						if(posX_bola<tamano_X-3)begin
							posX_bola=posX_bola+1;
						end else begin
							dirX=~dirX;
						end
						ball_draw=1;
						status_bola<=MOVE_V;
					end
				end
				
				LEFT:begin
					if(done_ball)begin
						ball_draw=0;
						if(posX_bola>4)begin
							posX_bola=posX_bola-1;
						end else begin
							dirX=~dirX;
						end
						ball_draw=1;
						status_bola<=MOVE_V;
					end
				end
				
		endcase
		
		
	end
	
	
	
	
	
	
	/*
	
	
	
	
/*
//este bloque pinta la pantalla de azul
reg [14:0] count=0;	
always @( posedge clk) begin

if (rst) begin
	count <=count +1;
	px_wr <=1;
	mem_px_addr<=count;
	mem_px_data<=COLOR_SCREEN;

end	
end*/





//	maquina de estado PALETA 
reg [AW-1:0] pos_init =0;
reg [2:0] status =0;
parameter start=0, pallet_a=1,  play_game=2, pallet_moves_rh=3, pallet_moves_lf=4, end_game=5;


reg [8:0]pos_line =0;
reg[5:0] count;

//Bloque para imprimir la barra y puntos extremos

always @(posedge clk) begin
		if (rst) begin
			pos_init =0;
			count <= 0;
			px_wr <=0;
			status <=start;
			led=0;
		end 
    
	case (status)

	  start:begin
			  pos_init=pos_init+1;
			  px_wr <=1;
			  mem_px_addr<= pos_init;
			  mem_px_data<=COLOR_SCREEN;
			 
			  if (pos_init>(SCREEN176*SCREEN120))begin
					pos_init=POSY_PALLET*SCREEN176+POSX_PALLET;
				   pos_line=0;
				 status <=pallet_a;
				 count<=0;
			  end
		  end
			
		//pinta la paleta 	
	  pallet_a:begin
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

//						count<=0;
//						px_wr<=0;
						status<=play_game;
				end						
		end	 
			 
		play_game: begin
			count<=0;
			px_wr<=0;
		//	if(a_score >= score_limit || b_score >=score_limit)begin
			//status<=end_game;
			//end
			if(btn_rh_a)begin
				if ((pos_init+PALLET_W) < SCREEN176*POSY_PALLET+SCREEN176)begin
					status <=pallet_moves_rh;
				end
				else begin
				status<=play_game;
				end
			end
			if(btn_lf_a)begin
				if(pos_init > POSY_PALLET*SCREEN176)begin
			  status <=pallet_moves_lf;
			  end
			  else begin
				status<=play_game;
				end
			end
		end

		pallet_moves_rh:begin
			 //mirar si pega en la pared y si no se puede mover
			 
				pos_init=pos_init+1;
				status<=pallet_a;
				led=~led;
		 
		end 
		pallet_moves_lf:begin
				pos_init=pos_init-1;
				status<=pallet_a;
			 
		end

		end_game:begin
		end	
		default:begin
		status <=start;
		end
	endcase		
end


//maquina de estados pelota	
/*reg [2:0] status_ball =0;
reg [AW:0] ball_init=0;
reg [8:0] ball_line=0;
parameter start_ball=0, moves_rd=1, moves_ru=2, moves_ld=3, moves_lu=4;
parameter BALL_W=10;
parameter BALL_H=10;
	
	
always @(posedge clk) begin
case (status_ball)

  start_ball:begin
		ball_init=(SCREEN176-1)*(SCREEN120/2-1)+(SCREEN176/2);
		count<=count+1;
		if(count<BALL_W)begin
			mem_px_addr <= (ball_init+ball_line*(SCREEN176))+count;
			mem_px_data <= COLOR_OBJECT;
			if (ball_init>BALL_W)begin
				ball_init=0;
				ball_line = ball_line +1;
			end 
			if (pos_line>BALL_H)begin
				 ball_init=BALL_W;
				 ball_line=0; 
			end
		end
		status<=play_game
		
	end
		
							ball_init=(SCREEN176-1)*(SCREEN120/2-1)+(SCREEN176/2);
							mem_px_addr=ball_init;
							mem_px_data=COLOR_OBJECT;
							ball_init=ball_init+1;
							mem_px_addr=1;
							mem_px_data=COLOR_OBJECT;
							ball_init=ball_init+639;
							mem_px_addr=ball_init;
							mem_px_data=COLOR_OBJECT;
							ball_init=ball_init+1;
							mem_px_addr=ball_init;
							mem_px_data=COLOR_OBJECT;

							if (start=1)begin
							 status = moves_rd;
						  end
  
  moves_rd:begin
  
  //mover pelota
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;

  
  
  //choca contra la pared?
  if(ball_init%(SCREEN176-1)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta abajo?
	    if(pos_init>(ball_init+SCREEN176-2))begin
		    status_ball = moves_lu;
		 end
		 
		 else begin
		    if(a_score==10)begin 
			   a_score=0;
				//ganador a
				status_ball=start_ball;
			 end
			 else begin
		       a_score = a_score+1;
			    status_ball=start_ball;
			 end 
		 end
	 end
	 
	 else begin
	    status_ball= moves_ld;
	 end
  end
  
  else begin
     //esta en la antepenultima fila?
     if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta abajo?
	    if(pos_init>(ball_init+SCREEN176-2))begin
		    status_ball =moves_ru;
		 end
		 else begin 
		    if(a_score==10)begin 
			   a_score=0;
				//ganador a
				status_ball=start_ball;
			 end
			 else begin
		       a_score = a_score+1;
			    status_ball=start_ball;
			 end 
		 end
	   end
		
		else begin
		  status_ball=moves_rd;
		end
  
  end
   
  end
    

  
  moves_ru:begin
     //borrar estado anterior

  
  //mover pelota
  ball_init=ball_init-(SCREEN176*2);
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;

  
  
  //choca contra la pared?
  if(ball_init%(SCREEN176-1)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(SCREEN176*2)-2))begin
		    status_ball =moves_rd;
		 end
		 
		 else begin
		    if(b_score==10)begin 
			   b_score=0;
				//ganador b
				status_ball=start_ball;
			 end
			 else begin
		       b_score = b_score+1;
			    status_ball=start_ball;
			 end 
		 end
	 end
	 
	 else begin
	    status_ball= moves_lu;
	 end
  end
  
  else begin
     //esta en la antepenultima fila?
     if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(SCREEN176*2)-2) & pos_init<=(ball_init-(SCREEN176*2)+2))begin
		    status_ball = moves_rd;
		 end
		 else begin 
		    if(b_score==10)begin 
			   b_score=0;
				//ganador b
				status_ball=start_ball;
			 end
			 else begin
		       b_score = b_score+1;
			    status_ball=start_ball;
			 end 
		 end
	   end
		
		else begin
		  status_ball =moves_ru;
		end
  
  end
    
  end
 
 
 
 
 
 
  moves_ld:begin
  //mover pelota
  ball_init=ball_init-2;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  
  //choca contra la pared?
  if((ball_init-1)%(SCREEN176)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta abajo?
	    if(pos_init<=(ball_init+SCREEN176+2))begin
		    status_ball = moves_ru;
		 end
		 
		 else begin
		    if(a_score==10)begin 
			   a_score=0;
				//ganador a
				status_ball=start_ball;
			 end
			 else begin
		       a_score = a_score+1;
			    status_ball=start_ball;
			 end 
		 end
	 end
	 
	 else begin
	    status_ball=moves_rd;
	 end
  end
  
  else begin
     //esta en la antepenultima fila?
     if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta abajo?
	    if(pos_init<=(ball_init+SCREEN176+2))begin
		    status_ball = moves_lu;
		 end
		 else begin 
		    if(a_score==10)begin 
			   a_score=0;
				//ganador a
				status_ball=start_ball;
			 end
			 else begin
		       a_score = a_score+1;
			    status_ball=start_ball;
			 end 
		 end
	   end
		
		else begin
		  status_ball = moves_ld;
		end
  
  end
    
 
  end
  
  
  
  
  
  
  moves_lu:begin
   
  //mover pelota
  ball_init=ball_init-(SCREEN176*2)-2;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=COLOR_OBJECT;

  
  
  //choca contra la pared?
  if((ball_init-1)%(SCREEN176)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(SCREEN176*2)-2))begin
		    status_ball= moves_rd;
		 end
		 
		 else begin
		    if(b_score==10)begin 
			   b_score=0;
				//ganador b
				status_ball=start_ball;
			 end
			 else begin
		       b_score = b_score+1;
			    status_ball=start_ball;
			 end 
		 end
	 end
	 
	 else begin
	    status_ball= moves_ru;
	 end
  end
  
  else begin
     //esta en la antepenultima fila?
     if(ball_init<(SCREEN176*(SCREEN120-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(SCREEN176*2)-2) & pos_init<=(ball_init-(SCREEN176*2)+2))begin
		    status_ball =moves_ld;
		 end
		 else begin 
		    if(b_score==10)begin 
			   b_score=0;
				//ganador b
				status_ball=start_ball;
			 end
			 else begin
		       b_score = b_score+1;
			    status_ball=start_ball;
			 end 
		 end
	   end
		
		else begin
		  status_ball =moves_lu;
		end
  
  end
end


  default:
		status_ball =start_ball;	
endcase		
end*/	 
     
/*if(ball_init%640==638)begin
    if(ball_init>=305920 & ball_init<306560)begin
       if(pos_init>=307195)begin
		  status= moves_lu;
       end
     end
  else begin
     status=  moves_ld;
  end
  else begin
 if()begin end 
  end
  end
  
*/ 	




endmodule