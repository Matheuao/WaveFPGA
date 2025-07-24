LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;

entity modwt is 
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

end modwt;

architecture main of modwt is

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
signal low_des,high_des,out_delay,out_threshold,out_s:vector_2:= (others=>X"0000"); 

	begin
        -- descontruction
        descontruction_0: desconstruction generic map(16,16,10,1) 
        
        port map(x_in=>in_x,
                 clk=>clock ,
                 reset=>reset_m,
                 output_low_des=>low_des(0),
                 output_high_des=>high_des(0));
		modwt_dir:
            for i in 1 to level-1 generate
                desconstruction_i: desconstruction generic map(16,16,10,2**i)
                port map(x_in=>low_des(i-1),
                         clk=>clock,
                         reset=>reset_m,
                         output_low_des=>low_des(i),
                         output_high_des=>high_des(i));
            
            end generate;

        -- shifter registers
        delay_stage:
            for i in 0 to level-2 generate
                shift_reg: shift_register generic map(16,delay(level =>level, stage => (level-1-i)))
                port map(x_in=>high_des(i),
                         clock=>clock,
                         reset=>reset_m,
                         enable=>'1',
                         x_out=>out_delay(i));
            end generate;

        -- reconstruction
        reconstruction_0: reconstruction generic map (16,16,10,2**(level-1))
        port map(rec_low_in=>low_des(level-1),
                 rec_high_in=>high_des(level-1),
                 reset=>reset_m,
                 clk=>clock,
                 y_out=>out_s(0));

        modwt_inv:
            for i in 1 to level-1 generate
                reconstruction_i: reconstruction generic map (16,16,10,2**(level-1-i))
                port map(rec_low_in=>out_s(i-1),
                         rec_high_in=>out_delay(level-1-i),
                         reset=>reset_m,
                         clk=>clock,
                         y_out=>out_s(i));
            
            end generate;

	out_y<=out_s(level-1);		

end main;