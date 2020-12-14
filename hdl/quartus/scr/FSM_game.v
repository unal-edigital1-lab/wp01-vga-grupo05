`timescale 1ns / 1ps
//arreglar parte cuando la pelota choca en la paleta rd, ld
//borrar estado anterior de la pelota
//cuadrar si es la paleta de abajo o la de arriba en ball
module FSM_game #( 
	parameter AW = 19, // Cantidad de bits  de la direccion 
	parameter DW = 12 // cantidad de Bits de los datos 
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
		output reg px_wr
   );
 //parametros
 parameter color_object=12'b111111111111;
 parameter color_screen=12'b111100000000;
 parameter bits_screen640= 9;
 parameter screen640= 640;
 parameter screen480= 480;

/*
//este bloque pinta la pantalla de azul
reg [14:0] count=0;	
always @( posedge clk) begin

if (rst) begin
	count =count +1;
	px_wr =1;
	mem_px_data=15;
	mem_px_addr=count;
	#5;
end	
end*/

parameter score_limit = 10;
parameter PALLET_W=64;
parameter PALLET_H=20;

reg [3:0] a_score = 0;
reg [3:0] b_score = 0;


//	maquina de estado PALETA A
reg [18:0] pos_init =0;
reg [2:0] status =0;
parameter start=0, pallet_a=1,  play_game=2, pallet_moves_rh=3, pallet_moves_lf=4, end_game=5;


reg [9:0]pos_line =0;
parameter DELAY_ERROR =0 ;

always @(posedge clk) begin
if (rst) begin
pos_init =0;
status <=start;
end 
    
case (status)

  start:begin
       pos_init=pos_init+1;
		  px_wr <=1;
		  mem_px_addr<= pos_init;
		  if (pos_init<(screen640*100))
			mem_px_data<=12'b111111111111;
		  else if (pos_init<(screen640*200))
			mem_px_data<=12'b000011110000;
		  else if (pos_init<(screen640*300))
			mem_px_data<=12'b000000001111;
		  else 
			mem_px_data<=color_screen;
		 
		  
		  if (pos_init>(screen640*screen480))begin
		    pos_init=0;
			 pos_line =0;
			 status <=pallet_a;
		  end
	  end
		
	//pinta la paleta 	
  pallet_a:begin
	   mem_px_addr <= pos_init+pos_line*(screen640 +DELAY_ERROR);
		mem_px_data <= color_object;
		mem_px_data <= 3<<pos_line;

		pos_init=pos_init+1;
		if (pos_init>PALLET_W)begin
			pos_init=0;
			pos_line = pos_line +1;
		end 
		if (pos_line>PALLET_H)begin
		    pos_init=PALLET_W;
			 pos_line=0;
			 status <= play_game;
			 px_wr <=0; 
		 end

		 end	 
		 
	play_game: begin
	   if(a_score >= score_limit || b_score >=score_limit)begin
		status<=end_game;
		end
		if(btn_rh_a)begin
		  status <=pallet_moves_rh;
		  
		end
		if(btn_lf_a)begin
		  status <=pallet_moves_lf;
		end
	end

		
pallet_moves_rh:begin
    //mirar si pega en la pared y si no se puede mover
    if (pos_init < screen640)begin
      mem_px_addr<= pos_init-PALLET_W;
		mem_px_data <= color_screen;

		pos_init=pos_init+1;
		mem_px_addr <= pos_init;
		mem_px_data <= color_object;
	 end
	 status<=play_game;
end 
pallet_moves_lf:begin

    if (pos_init > PALLET_W)begin
      mem_px_addr<= pos_init;
		mem_px_data <= color_screen;
		
		pos_init=pos_init-PALLET_W-1;
		mem_px_addr<= pos_init;
		mem_px_data <= color_object;
	 end
	 status<=play_game;
end

end_game:begin
  
end		
	default:
		status <=start;	
endcase		
end	


//maquina de estados pelota	
reg [2:0] status_ball =0;
reg [14:0] ball_init=0;
parameter start_ball=0, moves_rd=1, moves_ru=2, moves_ld=3, moves_lu=4;
	
	/*
	
always @(posedge clk) begin
case (status_ball)

  start_ball:begin
  
  ball_init=(screen640-1)*(screen480/2-1)+(screen640/2);
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=color_object;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=color_object;

		 // if (start=1)begin
		    status = moves_rd;
		  //end
  end
  
  moves_rd:begin
   //borrar estado anterior

  
  //mover pelota
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=color_object;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=color_object;

  
  
  //choca contra la pared?
  if(ball_init%(screen640-1)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta abajo?
	    if(pos_init>(ball_init+screen640-2))begin
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
     if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta abajo?
	    if(pos_init>(ball_init+screen640-2))begin
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
  ball_init=ball_init-(screen640*2);
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=color_object;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=color_object;

  
  
  //choca contra la pared?
  if(ball_init%(screen640-1)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(screen640*2)-2))begin
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
     if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(screen640*2)-2) & pos_init<=(ball_init-(screen640*2)+2))begin
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
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=color_object;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  
  //choca contra la pared?
  if((ball_init-1)%(screen640)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta abajo?
	    if(pos_init<=(ball_init+screen640+2))begin
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
     if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta abajo?
	    if(pos_init<=(ball_init+screen640+2))begin
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
  ball_init=ball_init-(screen640*2)-2;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=1;
  mem_px_data=color_object;
  ball_init=ball_init+639;
  mem_px_addr=ball_init;
  mem_px_data=color_object;
  ball_init=ball_init+1;
  mem_px_addr=ball_init;
  mem_px_data=color_object;

  
  
  //choca contra la pared?
  if((ball_init-1)%(screen640)==0)begin
    //esta en la antepenultima fila?
    if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(screen640*2)-2))begin
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
     if(ball_init<(screen640*(screen480-2)))begin
	    //la paleta esta arriba?
	    if(pos_init>(ball_init-(screen640*2)-2) & pos_init<=(ball_init-(screen640*2)+2))begin
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
