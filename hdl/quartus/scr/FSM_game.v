`timescale 1ns / 1ps
//dibujar y mover las paletas y pelota
//hacer que pelota se mueva de izquierda a derecha , que rebote a un angulo de 45°
module FSM_game (
	 	input clk,
		input rst,
		input in1,
		input in2,
		//input wire btn_up_a,
      //input wire [1:0] btn_dn_a,
		//input wire [1:0] btn_up_b,
      //input wire [1:0] btn_dn_b,
		//input start,
		output mem_px_addr,
		output mem_px_data,
		output px_wr
      //output DP_RAM_regW, //reset
		//output DP_RAM_addr_in, //num registros, direccion 
		//output DP_RAM_data_in  // informacion del registro 
   );
	
	/*parameter cols=528;
   parameter rows=320;
	parameter score_limit = 10;
	reg [3:0] a_score = 0;
   reg [3:0] b_score = 0;
	// la paleta se movera un pixel cada " " milisegundos cada vez que se mantenga presionado el boton
	parameter paddle_speed = 8;
	 
   // la pelora se movera un pixel cada " " milisegundos cada vez que se mantenga presionado el boton
	parameter ball_speed = 8;
	
	//crear paleta
   parameter paddle_height=9;
	wire[paddle_height-1:0] paddle_y_a, paddle_y_b;
	
	// crear pelota
	wire[5:0] ball_x, ball_y;
	reg [5:0] ball_X = 0;
   reg [5:0] ball_Y = 0;
	
	
	
   //la paleta se mueve solo cuado es presionada
    if (btn_up_a== 1'b1){
	 
	 }
	 
	//NO mover mas la paleta cuando llega al final
   
	if (btn_up_a== 1'b1 && paddle_y_a!== 0)
      paddle_y_a <= paddle_y_a - 1;
    else if (btn_dn_a == 1'b1 && paddle_y_a !== rows-paddle_height-1)
      addle_y_a <= paddle_y_a + 1;
		
	if (btn_up_b== 1'b1 && paddle_y_b!== 0)
      paddle_y_b <= paddle_y_b- 1;
    else if (btn_dn_b == 1'b1 && paddle_y_b !== rows-paddle_height-1)
      addle_y_b <= paddle_y_b+ 1;
	
//comenzar el juego	
	if (start == 1'b1)
	   ball_X <= rows/2;
      ball_Y <= cols/2;
	///////////// comience el juego
	end 
	
//un jugador anota punto	
   //jugador b anota punto
	if (ball_x == 0 && (ball_y < paddle_y_a || ball_y  > paddle_y_a + paddle_height))
	    //vuelva a comenzar
		 b_score = b_score+1;
	//jugador a anota punto	 
    else if (ball_x== cols-1 && (ball_y < paddle_y_b  || ball_y > paddle_y_b + paddle_height))
        //vuelva a comenzar
		  a_score = a_score+1;
		  
		  
//un jugador gana

    if (a_score == score_limit-1){
	     a_score <=0;
	     b_score <=0;	  
		  //terminar juego, vuelve a comenzar}
	 else if (b_score == score_limit-1){
	   //reiniciar marcador
	     a_score <=0;
	     b_score <=0;
		  //terminar juego, vuelve a comenzar
		  }
		  */
     
	
endmodule
