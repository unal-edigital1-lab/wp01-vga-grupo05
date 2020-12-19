# WP01

En el presente informe se mostrará la programación correspondiente en lenguaje Verilog para desarrollar el juego Pong
 
 Integrantes:
-------
* Johan Sebastian Molina
* Paula Sofía Medina
* Maria Alejandra Salgado

Pregunta 1:
---------------------------------

El tamaño máximo de buffer de memoria que se puede crear acorde a la FPGA ep4ce10e22c8 ciclobe IV es de 414 kb. 
Se escogió bajar la resolución de la imagen al formato DCIF el cual tiene un tamaño de 176 x 120, ya que el formato 640 X 480 ocupa más espacio en memoria del que tenemos. Finalmete también se escogió un formato RGB111 para dejar más memoria libre. 
En conclusión con la visualización en un pantalla VGA 176 x 120 de RGB111, tenemos un 85.05% de memoria libre, el cual lo ocuparemos con los drivers necesarios para realizar el juego.

Pregunta 2:
--

Para que el usuario pueda jugar, se usaran dos pulsadores para subir o bajar la barrita del Pong.

Pregunta 3:
--
Nuestra RAM tiene dos registros de posición y dos registros de datos de la memoria, ya que al tener dos maquinas de estado, una para la paleta y otra para la pelota, se tendra que actualizar datos en dos posiciones diferente de memoria y para evitar errores se usa esta técnica.


Código
--

Archivo TOP
----

A continuación se puede observar el modulo top del proyecto en donde se instanciaran los demas modulos que determinaran el funcionamiento de la VGA y de la logica del juego.

Primero que todo se encuentran las salidas que iran a la VGA: determinaran los colores y sincronizacion de la misma, entradas de cables como los botones, reloj proporcionado por la FPGA y reset de la misma tarjeta:

     module test_VGA(
    input wire clk,            
    input wire rst,         	// reset button

	// VGA input/output  
    output wire VGA_Hsync_n,  // horizontal sync output
    output wire VGA_Vsync_n,  // vertical sync output
    output wire VGA_R,	// 1-bit VGA red output
    output wire VGA_G,  // 1-bit VGA green output
    output wire VGA_B,  // 1-bit VGA blue output
    output wire clkout,  
 	
	// input: botones para manipular la paleta
		
	input wire bntra,
	input wire bntla
		
);

Teniendo en cuenta el tamaño de almacenamiento que la memoria de la FPGA nos puede proporcionar y la sugerencia de solo ocupar un 50% para visualización, diseñamos una ventana para visualizacion pequeña para después hacer un escalamiento de la misma y a continuación se encontrara el tamaño en X y Y y parametros que servieran para determinar la cantidad de bits de registros de memoria:

    parameter CAM_SCREEN_X = 176;
     parameter CAM_SCREEN_Y = 120;

    localparam AW = 15; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
    localparam DW = 3;

De acuerdo con la PGA, tiene una configuración de color de RGB 111, representada de la siguiente manera:

    localparam RED_VGA =   3'b100;
    localparam GREEN_VGA = 3'b010;
    localparam BLUE_VGA =  3'b001;
    
Tendremos dos cloks, uno que representara el que proporciona la FPGA de 50MHz y otro que sera la frecuencia de la pantalla que se esta utilizando, para este caso de 85MHz

    wire clk50M;
    wire clk85M;

Se hara conexion por ram de dos puertos de escritura y uno de lectura

    wire  [AW-1: 0] DP_RAM_addr_in;  
    wire  [DW-1: 0] DP_RAM_data_in;
    wire DP_RAM_regW;

    wire  [AW-1: 0] DP_RAM_addr_in2;  
    wire  [DW-1: 0] DP_RAM_data_in2;
    wire DP_RAM_regW2;

    reg  [AW-1: 0] DP_RAM_addr_out;  
	
Conexión VGA Driver

         wire [DW-1:0]data_mem;	  
         wire [DW-1:0]data_RGB444;  // salida del driver VGA al puerto
         wire [10:0]VGA_posX; // Determinar la pos de memoria que viene del VGA
         wire [10:0]VGA_posY;	// Determinar la pos de memoria que viene del VGA


La pantalla VGA es RGB 111 y el almacenamiento en memoria se hace 332, originalmente se tenia registros de 4 bits y por ello data_RGB444 se concontraba de 12 bits, para este caso solo sera de 3 bits

	assign VGA_R = data_RGB444[2];
	assign VGA_G = data_RGB444[1];
	assign VGA_B = data_RGB444[0];


Se realiza divisor de frecuencia de 50MHz a 5KHz (clk de FSM_game) esto con el fin de que el movimiento de las paletas y la pelota sea mas lento y visible para el ojo humano y asi proporcionar al usuario una mejor experiencia a la hora de jugar. Además, se realiza un multiplicador de frecuencia de 50MHz a 85MHz (clk para implementación en pantalla VGA) ya que esta necesita una frecuencia especifica para funcionar:

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
	


Se instancia el modulo de buffer_ram_dp o buffer memoria dual port y reloj de lectura, teniendo dos puertos de escritura separados:

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
	


Se instancia el modVGA_Driver 1368x768, No se modifica el nombre , pero si varian los valores en el driver de la VGA
 
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


Lógica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA. Se realiza escalamiento de 8 veces la imagen, para que ocupe toda la pantalla VGA

    reg[10:0] tempx;
    reg[10:0] tempy;
    always @ (VGA_posX, VGA_posY) begin
		tempx=VGA_posX/8;
		tempy=VGA_posY/8;
		DP_RAM_addr_out=tempx+tempy*CAM_SCREEN_X;

    end


Bloque de funcionamiento del juego, maquinas de estado de la paleta y de la bola y sus respectivos puertos de memoria

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



GAME
----
A continuación se presenta el modulo del juego PONG, empezando por las entradas y salidas del mismo que corresponden a las conexiones con la memoria, el reloj para el funcionamiento de los estados gracias a los flancos de subida y los botones que determinaran los movimientos:

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
 De igual modo, se presentan los parametros que se utilizaran con respecto a mediciones de la pantalla, colores para la pantalla y los objetos, dimensiones con las que se dibuja la paleta y la pelota y posiciones X y Y de las msimas para poder hacer comparaciones y establecer movimientos especificos, además de los parametros para cada una de las maquinas de estado, contadores y verificadores de cumplimiento de funciones:
 
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
	
Máquina de estados
--

Se hizo uso de dos maquinas de estados en el modulo FMS_game.v ya que se tienen dos objetos en patalla, que son la pelota y la paleta.

MAQUINA DE ESTADOS DE LA PALETA
A continución se muestra el diagrama para la máquina de estados de la paleta:
![image1](https://github.com/unal-edigital1-lab/wp01-vga-grupo05/blob/main/pallet(1).png)

CODIGO DE LA MAQUINA DE ESTADOS PARA LA PALETA

Se tiene en cuenta que todo el proceso de la paquina de estado estara determinada por el rst, asi inicializando los registros que posteriormente se utilizaran:


    always @(posedge clk) begin
		if (rst) begin
			pos_init =0;
			count <= 0;
			px_wr <=0;
			status_pallet <=START_PALLET;
		end 
    
	case (status_pallet)

El primer estado para la paleta es "START_PALLET", en el se toma una posicion inicial que ira aumentando gracias a la recurrencia del bloque y que poco a poco cuando va abarcando todas las posiciones de la pantalla, las va pintando de un color hasta abarcar toda la pantalla, después de esto se dara una posicion inicial para la paleta y se continuara al siguiente estado:

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
			
En el siguiente estado se dibuja la paleta ademas de dos puntos que se encontraran al lado derecho e izquierda que facilitaran pintar la barra cuando esta se mueva, se tendra un contador que aumentara hasta cuando se cumpla la dimension en el eje X de la paleta y pintara esas posiciones con el color designado para la misma, mientras que las dos siguientes posiciones que aumentan con el count seran para pintar los extremos

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

A continuación se muestra el estado de juego que tiene como condiciones cuando se oprime el boton de la derecha o el de la izquierda y permite el movimiento de la posicion, en el caso de que se llegue a un extremo, se volvera a entrar a este bloque esperando que el usuario oprime el otro boton para asi poder mover la barra

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

Por otro lado, tendremos los estados de movimiento donde se aumenta o disminuye la posicion inicial y se vuelve al estado de dibujar la paleta, ademas se encuentra el estado para finalizar el juego y volver a empezar

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
 
MAQUINA DE ESTADOS DE LA PELOTA
A continuación se muestra la máquina de estados de la pelota
![image1](https://github.com/unal-edigital1-lab/wp01-vga-grupo05/blob/main/Ball.png)

CODIGO DE LA MAQUINA DE ESTADOS PARA LA  PELOTA

Se da inicio igual que cuando se hizo con la paleta a darle un valor inicial a las variables de contador y de escritura, en este caso no se realizo un estado para imprimir solo la bolita porque otros estados necesitaban acceso remoto al mismo bloque, entonces se hizo el bloque al principio y tiene una logica parecida a la que hizo con la paleta, se crea la pelota en si que en este caso es de un pixel y se dibujan otras parte a su alrededor, arriba, abajo, al lado derecho e izquierdo, para facilitar el movimiento

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
		
Se inicia la mauina de estados para la pelota designando un valor para la posicion de la pelota en el eje X y Y, asi como pintando la pelota al tener un registro que puede ser 1 o 0 para acceder al bloque que se explico anteriormente, después de pintarla se procede a hacer un primer movimiento de la pelta, que se considera aleatorio	
	
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

A continuación se encontrara con dos secciones generales y cuatro expecificas, las secciones generales seran para el movimiento horizontal o vertical, solo que cada una de estas presenta dos variaciones Arriba-Abajo, Lado derecho-Lado izquierdo y asi mismo cambiara la direccion de la pelota ante el movimiento.

Cabe resaltar que en dos de los estados se deben establecer las condiciones para cuando la pelota choca contra la paleta y cambia su direccion arbitrariamente y estas estan dadas por la comparacion de la direccion en memoria de donde se esta moviendo ambos objetos:

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

MODULO DE MEMORIA RAM
---
A continuación se describe el modulo "buffer_ram_dp" que se encarga de todo el manejo de la memoria, puertos de escritura y lectura, asi que asi mismo son designadas sus entradas y salidas que tienen con ellas una direccion en la memoria y el dato o información que se escribira o leera en la misma

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
 
Numero de posiciones totales de memoria y construccion de la matriz para la misma

      localparam NPOS = 2 ** AW; 
      reg [DW-1: 0] ram [0: NPOS-1]; 
 
Este puede considerarse un bloque esencial ya que permite el funcionamiento de las dos maquinas de estado que se realizaron, de otra forma no se podria hacer, ya que la memoria tendria solo un puerto de escritura y no sabria exactamente que leer, entonces este bloque alterna la escritura de los datos de la memoria entre las dos maquinas de estado del juego(dos puertos), teniendo en cuenta sus regwrites
 
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

Mientras que anteriormente se hablaba de los dos puertos para la escritura, en el siguiente bloque se hace la lectura  de la memoria 

    always @(posedge clk_r) begin 
 		data_out <= ram[addr_out]; 
    end

    endmodule

Driver VGA
----
Por ultimo, nos encontramos con el modulo de Driver de la VGA, en este se tienen todos los paremetros para imprimir los pixele, la sincronizacion de manera vertial u horizontal, ademas de posiciones de los pixeles

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

Se identifica como parametros el tamaño de la pantalla en horizontal y vertical, asi como las margenes de la pantalla

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

Se establece el proceso de imprimir en la VGA con contadores para el eje X y el eje Y

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


Modulo Testbench
----
Esta modulo ue utilizado unicamente para el primer proceso de simulacion para verificar el funcionamiento y llenado de memoria, impresion de la pantalla con el simulador virtual y tiene las mismas salidas que se utilizan para la implementacion, aqui se instancia el modulo top del proyecto para su funcionamiento

    module test_VGA_TB;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire VGA_Hsync_n;
	wire VGA_Vsync_n;
	wire VGA_R;
	wire VGA_G;
	wire VGA_B;
     reg bntra;
	reg bntla;
	reg bntrb;
	reg bntlb;
	wire clkout;

	// Instantiate the Unit Under Test (UUT)
	test_VGA uut (
		.clk(clk), 
		.rst(rst), 
		.VGA_Hsync_n(VGA_Hsync_n), 
		.VGA_Vsync_n(VGA_Vsync_n), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.bntra(bntra),
		.bntla(bntla),
		.bntrb(bntrb),
		.bntlb(bntlb),
		.clkout(clkout)
	
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		#614400;
		rst = 1;
		
		bntra=0;
		bntla=0;

	end

	always #2 clk  = ~clk;
	
	
	reg [9:0]line_cnt=0;
	reg [9:0]row_cnt=0;
	
INICIO DE  GENERACION DE ARCHIVO test_vga	
En estos dos bloques se produce un archivo.txt que sera el utilizado por el simulador virtual utilizado para imprimir la pantalla

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
    end
	
	reg clk_wf =0;
	always #2 clk_wf  = ~clk_wf;
	
	
A continuación se realizo la siguiente línea de código para porder realizar la simulación en la VGA en la pagina  https://ericeastwood.com/lab/vga-simulator/*/

	initial forever begin
	@(posedge clk_wf)
		$fwrite(f,"%0t ps: %b %b %b00 %b00 %b0\n",$time,VGA_Hsync_n, VGA_Vsync_n, VGA_R,VGA_G,VGA_B);

	end
    endmodule

PROCESO
--

En esta sección se presentan los resultados parciales del proyecto, es decir, todo el proceso que se tuvo que dar de implementación :

Para crear el juego final primero se creo la barra, se puso en funcionamiento la maquina de estado de la paleta, teniendo en cuenta que solo se tenia un puerto de escritura y se obtuvo lo siguiente, considerando que la paleta tenia cierta dimension, que se dio un escalamiento de la pantalla para que se mostrara en toda, además de posicionar la pantalla abajo para que tuviera una mayor aproximacion al juego, aunque en el PONG se maneje dos paletas, consideramos solo realizar una:
![image1](https://github.com/unal-edigital1-lab/wp01-vga-grupo05/blob/main/WhatsApp%20Image%202020-12-18%20at%2013.48.57.jpeg)

Luego se procedio a crear la pelota
![image1](https://github.com/unal-edigital1-lab/wp01-vga-grupo05/blob/main/WhatsApp%20Image%202020-12-18%20at%2013.48.24.jpeg)

finalmente se juntaron las dos cosas como producto final 


RESULTADOS
--

A continuacion se presenta el video de la implementación.
https://drive.google.com/file/d/1d2US2RaaHcAs3Chz77WddsDbuIWiTE4V/view?usp=sharing
