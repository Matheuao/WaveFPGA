LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;

entity wavelet_main is 
	GENERIC (
					W1 : INTEGER := 16; -- Input and output bit width 
					W2 : INTEGER := 16; -- multiplication bit width
					w3 : INTEGER := 64; --multiplication bit width
					level:integer:= 5;
					s_h : integer := 2;-- 1 para soft 2 para hard
					k   : integer :=16

			);

			port(
			
			in_x : IN signed(w1-1 DOWNTO 0);
			clock			: in std_logic;
			out_y :out signed(W1-1 downto 0);
			reset_m: in std_logic	
			);

end wavelet_main;

architecture main of wavelet_main is

function delay(level : integer := 0; stage : integer :=1) return integer is variable d_count : integer;
	variable d_previous : integer := 0;
	begin 
		
	for i in level downto level - (stage - 1) loop
		d_count := 2 * (2 + ((2 **(i - 2)) * 9)) + d_previous;
		d_previous := d_count;
	end loop;

	return d_count;
end function;

component desconstruction

GENERIC (
					W1 : INTEGER := 16; -- Input and output bit width   
					W2 : INTEGER := 16;--32 -- coeficients width	
					num_coef: INTEGER:=10;
					n_delay:integer:=1
			);

			port(
			
			x_in : in signed(W1-1 DOWNTO 0):=(others=>'0');
			clk  : in std_logic;
			reset: in std_logic;
			output_low_des : out signed(W1-1 DOWNTO 0):=(others=>'0');
			output_high_des : out signed(W1-1 downto 0):=(others=>'0')
			);

end component;


component reconstruction 
	GENERIC (
					W1 : INTEGER := 16; -- Input and output bit width   
					W2 : INTEGER := 16;--32 -- coeficients width	
					num_coef: INTEGER:=10;
					n_delay:integer:=1
					
			);

			port(
			
			rec_low_in : IN signed(w2-1 DOWNTO 0):=(others=>'0');
			rec_high_in : IN signed(W2-1 downto 0):=(others=>'0');
			reset: in std_logic;
			clk			: in std_logic;
			y_out: out signed(W2-1 downto 0):=(others=>'0'));
			
end component;
			

component shift_register
			GENERIC (
				data_num_bits : INTEGER := 32; -- multiplication bit width (W1*2)
				DELAY_W: INTEGER :=1 --15 ate 25 fs/2			
			);
			

			port(
				x_in : IN signed(w1-1 DOWNTO 0);
				clock :  in std_logic;
				reset: in std_logic;
				enable: in std_logic;
				x_out : out signed(w1-1 downto 0)
			);
end component;

component threshold_hard

		GENERIC (
				W2 : INTEGER := 16
			);

			port(
				cd_ent : in signed (W2-1 downto 0);
				clk:in std_logic;
				rst:in std_logic;
				cd_out : out signed (W2-1 downto 0)
			);


end component;

component threshold

		GENERIC (
				W2 : INTEGER;
				level:integer;
				K :integer ; -- abs_avg_estimator
				s_h:integer -- 1 para soft 2 para hard
			);

			port(
				cd_ent : in signed (W2-1 downto 0);
				clk:in std_logic;
				rst:in std_logic;
				cd_out : out signed (W2-1 downto 0)
			);

end component;

type vector_2 is array(level-1 downto 0) of signed(W1-1 downto 0);
signal low_des,high_des,out_delay,out_threshold:vector_2:= (others=>X"0000"); 
signal out_t1,out_t2,out_t3,out_t4,out_delay1,out_delay2,out_delay3:signed(W1-1 downto 0):=(others=>'0');
signal in_des,debugger_inv_1,debugger_high_0,debbuger_low_0,debugger_high_delay:signed (W1-1 downto 0):= (others=>'0');
signal clk_div_2,clk_div_4,clk_div_8,clk_div_16,e_shift: std_logic:='0';
signal out_s:vector_2:= (others=>X"0000"); 


	begin
		comp_nivel_1:
		
			if level = 1 generate
			
				descontruction_0: desconstruction generic map (16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
				reconstruction_0: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>low_des(0),rec_high_in=>high_des(0),reset=>reset_m,clk=>clock,y_out=>out_s(0));
			
			end generate;
			
		comp_nivel_2:
		
			if level = 2 generate
			
			
				descontruction_0: desconstruction generic map(16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
				descontruction_1: desconstruction generic map(16,16,10,2) port map(x_in=>low_des(0),clk=>clock ,reset=>reset_m,output_low_des=>low_des(1),output_high_des=>high_des(1));
				
				shift_reg1: shift_register generic map(16, delay(level =>2, stage => 1)) port map(x_in=>high_des(0),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(0));
				
				reconstruction_0: reconstruction generic map (16,16,10,2)  port map(rec_low_in=>low_des(1),rec_high_in=>high_des(1),reset=>reset_m,clk=>clock,y_out=>out_s(0));
				reconstruction_1: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>out_s(0),rec_high_in=>out_delay(0),reset=>reset_m,clk=>clock,y_out=>out_s(1));
			
			end generate;
			
		 comp_nivel_3:
		
			if level = 3 generate
			
			
				descontruction_0: desconstruction generic map(16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
				descontruction_1: desconstruction generic map(16,16,10,2) port map(x_in=>low_des(0),clk=>clock ,reset=>reset_m,output_low_des=>low_des(1),output_high_des=>high_des(1));
				descontruction_2: desconstruction generic map(16,16,10,4) port map(x_in=>low_des(1),clk=>clock ,reset=>reset_m,output_low_des=>low_des(2),output_high_des=>high_des(2));
				--38,58
				shift_reg1: shift_register generic map(16,delay(level =>3, stage => 2)) port map(x_in=>high_des(0),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(0));
				shift_reg2: shift_register generic map(16,delay(level =>3, stage => 1)) port map(x_in=>high_des(1),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(1));
				
				reconstruction_0: reconstruction generic map (16,16,10,4)  port map(rec_low_in=>low_des(2),rec_high_in=>high_des(2),reset=>reset_m,clk=>clock,y_out=>out_s(0));
				reconstruction_1: reconstruction generic map (16,16,10,2)  port map(rec_low_in=>out_s(0),rec_high_in=>out_delay(1),reset=>reset_m,clk=>clock,y_out=>out_s(1));
				reconstruction_2: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>out_s(1),rec_high_in=>out_delay(0),reset=>reset_m,clk=>clock,y_out=>out_s(2));
				
			end generate;
			
			comp_nivel_4:
			
			if level = 4 generate
			
			
				descontruction_0: desconstruction generic map(16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
				descontruction_1: desconstruction generic map(16,16,10,2) port map(x_in=>low_des(0),clk=>clock ,reset=>reset_m,output_low_des=>low_des(1),output_high_des=>high_des(1));
				descontruction_2: desconstruction generic map(16,16,10,4) port map(x_in=>low_des(1),clk=>clock ,reset=>reset_m,output_low_des=>low_des(2),output_high_des=>high_des(2));
				descontruction_3: desconstruction generic map(16,16,10,8) port map(x_in=>low_des(2),clk=>clock ,reset=>reset_m,output_low_des=>low_des(3),output_high_des=>high_des(3));
				--132,112,74
				shift_reg1: shift_register generic map(16,delay(level =>4, stage => 3)) port map(x_in=>high_des(0),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(0));
				shift_reg2: shift_register generic map(16,delay(level =>4, stage => 2)) port map(x_in=>high_des(1),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(1));
				shift_reg3: shift_register generic map(16,delay(level =>4, stage => 1)) port map(x_in=>high_des(2),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(2));
				
				reconstruction_0: reconstruction generic map (16,16,10,8)  port map(rec_low_in=>low_des(3),rec_high_in=>high_des(3),reset=>reset_m,clk=>clock,y_out=>out_s(0));
				reconstruction_1: reconstruction generic map (16,16,10,4)  port map(rec_low_in=>out_s(0),rec_high_in=>out_delay(2),reset=>reset_m,clk=>clock,y_out=>out_s(1));
				reconstruction_2: reconstruction generic map (16,16,10,2)  port map(rec_low_in=>out_s(1),rec_high_in=>out_delay(1),reset=>reset_m,clk=>clock,y_out=>out_s(2));
				reconstruction_3: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>out_s(2),rec_high_in=>out_delay(0),reset=>reset_m,clk=>clock,y_out=>out_s(3));
			
			end generate;
			
			comp_nivel_5:
			
			if level = 5 generate
			
				descontruction_0: desconstruction generic map(16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
				descontruction_1: desconstruction generic map(16,16,10,2) port map(x_in=>low_des(0),clk=>clock ,reset=>reset_m,output_low_des=>low_des(1),output_high_des=>high_des(1));
				descontruction_2: desconstruction generic map(16,16,10,4) port map(x_in=>low_des(1),clk=>clock ,reset=>reset_m,output_low_des=>low_des(2),output_high_des=>high_des(2));
				descontruction_3: desconstruction generic map(16,16,10,8) port map(x_in=>low_des(2),clk=>clock ,reset=>reset_m,output_low_des=>low_des(3),output_high_des=>high_des(3));
				descontruction_4: desconstruction generic map(16,16,10,16) port map(x_in=>low_des(3),clk=>clock ,reset=>reset_m,output_low_des=>low_des(4),output_high_des=>high_des(4));
--				--147,223,263,285
				shift_reg1: shift_register generic map(16,delay(level =>5, stage => 4)) port map(x_in=>high_des(0),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(0));
				shift_reg2: shift_register generic map(16,delay(level =>5, stage => 3)) port map(x_in=>high_des(1),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(1));
				shift_reg3: shift_register generic map(16,delay(level =>5, stage => 2)) port map(x_in=>high_des(2),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(2));
				shift_reg4: shift_register generic map(16,delay(level =>5, stage => 1)) port map(x_in=>high_des(3),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(3));
				
				reconstruction_0: reconstruction generic map (16,16,10,16)  port map(rec_low_in=>low_des(4),rec_high_in=>high_des(4),reset=>reset_m,clk=>clock,y_out=>out_s(0));
				reconstruction_1: reconstruction generic map (16,16,10,8)  port map(rec_low_in=>out_s(0),rec_high_in=>out_delay(3),reset=>reset_m,clk=>clock,y_out=>out_s(1));
				reconstruction_2: reconstruction generic map (16,16,10,4)  port map(rec_low_in=>out_s(1),rec_high_in=>out_delay(2),reset=>reset_m,clk=>clock,y_out=>out_s(2));
				reconstruction_3: reconstruction generic map (16,16,10,2)  port map(rec_low_in=>out_s(2),rec_high_in=>out_delay(1),reset=>reset_m,clk=>clock,y_out=>out_s(3));
				reconstruction_4: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>out_s(3),rec_high_in=>out_delay(0),reset=>reset_m,clk=>clock,y_out=>out_s(4));
				
			
			end generate;
			
			
--			comp_nivel_5:
			
--			if level = 5 generate
			
--				threshold_1: threshold generic map(W1,5,K,s_h) port map(cd_ent=>high_des(4), clk=>clock, rst=>reset_m, cd_out=>out_threshold(0));
--				threshold_2: threshold generic map(W1,4,K,s_h) port map(cd_ent=>out_delay(3), clk=>clock, rst=>reset_m, cd_out=>out_threshold(1));
--				threshold_3: threshold generic map(W1,3,K,s_h) port map(cd_ent=>out_delay(2), clk=>clock, rst=>reset_m, cd_out=>out_threshold(2));
--				threshold_4: threshold generic map(W1,2,K,s_h) port map(cd_ent=>out_delay(1), clk=>clock, rst=>reset_m, cd_out=>out_threshold(3));
--				threshold_5: threshold generic map(W1,1,K,s_h) port map(cd_ent=>out_delay(0), clk=>clock, rst=>reset_m, cd_out=>out_threshold(4));
			
--				descontruction_0: desconstruction generic map(16,16,10,1) port map(x_in=>in_x,clk=>clock ,reset=>reset_m,output_low_des=>low_des(0),output_high_des=>high_des(0));
--				descontruction_1: desconstruction generic map(16,16,10,2) port map(x_in=>low_des(0),clk=>clock ,reset=>reset_m,output_low_des=>low_des(1),output_high_des=>high_des(1));
--				descontruction_2: desconstruction generic map(16,16,10,4) port map(x_in=>low_des(1),clk=>clock ,reset=>reset_m,output_low_des=>low_des(2),output_high_des=>high_des(2));
--				descontruction_3: desconstruction generic map(16,16,10,8) port map(x_in=>low_des(2),clk=>clock ,reset=>reset_m,output_low_des=>low_des(3),output_high_des=>high_des(3));
--				descontruction_4: desconstruction generic map(16,16,10,16) port map(x_in=>low_des(3),clk=>clock ,reset=>reset_m,output_low_des=>low_des(4),output_high_des=>high_des(4));
				
--				shift_reg1: shift_register generic map(16,282) port map(x_in=>high_des(0),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(0));
--				shift_reg2: shift_register generic map(16,260) port map(x_in=>high_des(1),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(1));
--				shift_reg3: shift_register generic map(16,220) port map(x_in=>high_des(2),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(2));
--				shift_reg4: shift_register generic map(16,144) port map(x_in=>high_des(3),clock=>clock,reset=>reset_m,enable=>'1',x_out=>out_delay(3));
				
--				reconstruction_0: reconstruction generic map (16,16,10,16)  port map(rec_low_in=>low_des(4),rec_high_in=>out_threshold(0),reset=>reset_m,clk=>clock,y_out=>out_s(0));
--				reconstruction_1: reconstruction generic map (16,16,10,8)  port map(rec_low_in=>out_s(0),rec_high_in=>out_threshold(1),reset=>reset_m,clk=>clock,y_out=>out_s(1));
--				reconstruction_2: reconstruction generic map (16,16,10,4)  port map(rec_low_in=>out_s(1),rec_high_in=>out_threshold(2),reset=>reset_m,clk=>clock,y_out=>out_s(2));
--				reconstruction_3: reconstruction generic map (16,16,10,2)  port map(rec_low_in=>out_s(2),rec_high_in=>out_threshold(3),reset=>reset_m,clk=>clock,y_out=>out_s(3));
--				reconstruction_4: reconstruction generic map (16,16,10,1)  port map(rec_low_in=>out_s(3),rec_high_in=>out_threshold(4),reset=>reset_m,clk=>clock,y_out=>out_s(4));
				
				
--			end generate;
			
	

	

	out_y<=out_s(level-1);	
	
	
	
	

	
				

end main;