LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;
use work.ndwt_types.all;

entity NDWT_denoising is 
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width 
		W2 : INTEGER := 16; -- multiplication tap bit width
		level:integer:= 5; -- number of levels in de transform
		s_h : integer := 2; -- tresholding rule, 1 for 'soft' 2 for 'hard' 
		k   : integer :=16; -- Window of the avareging estimation 2^k.
        transform_version:ndwt_transform_version:=NDWT_V1
		);
	port(	
		in_x : IN signed(w1-1 DOWNTO 0);
		clock			: in std_logic;
		out_y :out signed(W1-1 downto 0);
		reset: in std_logic	
	);

end NDWT_denoising;

architecture main of NDWT_denoising is

function delay(level_n : integer := 0; stage : integer :=1)
return integer is variable d_count : integer;
-- Returns the number of shift registers in each stage of the transform.
-- This is necessary solely to ensure proper data alignment between 
-- the different levels of the transform.
variable d_previous : integer := 0;
	
	begin 
		
	for i in level_n downto level_n - (stage - 1) loop
		d_count := 2 * (2 + ((2 **(i - 2)) * 9)) + d_previous;
		d_previous := d_count;
	end loop;

	return d_count;
end function;

component transform_NDWT
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width   
		W2 : INTEGER := 16;--32 -- coeficients width	
		coefficient_size: INTEGER:=10;
		n_delay:integer:=1; -- only necessary for the NDWT
		transform_version:ndwt_transform_version := NDWT_V1
		);
	port(
		input_x : in signed(W1-1 DOWNTO 0):=(others=>'0');
		clk  : in std_logic;
		reset: in std_logic;
		output_low : out signed(W1-1 DOWNTO 0):=(others=>'0');
		output_high : out signed(W1-1 downto 0):=(others=>'0')
	);
end component;

component inv_transform_NDWT 
GENERIC (
	W1 : INTEGER := 16; -- Input and output bit width   
	W2 : INTEGER := 16;--32 -- coeficients width	
	coefficient_size: INTEGER:=10;
	n_delay:integer:=2;
    transform_version:ndwt_transform_version := NDWT_V1
	);
    port(
        rec_low_in : IN signed(w2-1 DOWNTO 0):=(others=>'0');
        rec_high_in : IN signed(W2-1 downto 0):=(others=>'0');
        reset: in std_logic;
        clk	: in std_logic;
        y_out: out signed(W2-1 downto 0):=(others=>'0')
    );		
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
        -- decomposition
		ndwt_n: for i in 0 to level-1 generate
			edge_condition: if i = 0 generate
				decomposition_0: transform_NDWT generic map(W1,W2,10,1,transform_version) 
					port map(input_x=>in_x,
							clk=>clock ,
							reset=>reset
				,
							output_low=>low_des(0),
							output_high=>high_des(0));
			else generate
                decomposition_n: transform_NDWT generic map(W1,W2,10,2**i,transform_version)
					port map(input_x=>low_des(i-1),
							clk=>clock,
							reset=>reset
				,
							output_low=>low_des(i),
							output_high=>high_des(i));
			end generate edge_condition;
            
        end generate ndwt_n;

        -- shifter registers
        delay_stage:
            for i in 0 to level-2 generate
                shift_reg: shift_register generic map(W1,delay(level_n =>level, stage => (level-1-i)))
					port map(x_in=>high_des(i),
							clock=>clock,
							reset=>reset
				,
							enable=>'1',
							x_out=>out_delay(i));
            end generate;

        -- reconstruction

        indwt_n: for i in 0 to level-1 generate
			edge_condition: if i = 0 generate
				reconstruction_0: inv_transform_NDWT generic map (W1,W2,10,2**(level-1),transform_version)
					port map(rec_low_in=>low_des(level-1),
							rec_high_in=>high_des(level-1),
							reset=>reset,
							clk=>clock,
							y_out=>out_s(0));
			else generate
                reconstruction_n: inv_transform_NDWT generic map (W1,W2,10,2**(level-1-i),transform_version)
					port map(rec_low_in=>out_s(i-1),
							rec_high_in=>out_delay(level-1-i),
							reset=>reset,
							clk=>clock,
							y_out=>out_s(i));
            end generate edge_condition;
		end generate indwt_n;

	out_y<=out_s(level-1);		

end main;