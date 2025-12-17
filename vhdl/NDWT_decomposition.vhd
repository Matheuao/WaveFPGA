LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;
USE work.vector_types.all;
use work.ndwt_types.all;

entity NDWT_decomposition is 
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width 
		W2 : INTEGER := 16; -- multiplication tap bit width
		level:integer:= 5; -- number of levels in de transform
		align:boolean := true -- True/false for alignment of Ca and Cd in each level
		);
	port(	
		in_x : IN signed(w1-1 DOWNTO 0);
		clock: in std_logic;
		reset: in std_logic;
		Ca :out signed_vector(level-1 downto 0)(W1-1 downto 0);
		Cd: out signed_vector(level-1 downto 0)(W1-1 downto 0)
	);

end NDWT_decomposition;

architecture main of NDWT_decomposition is

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

signal low_des,high_des:signed_vector(level-1 downto 0)(W1-1 downto 0);
signal out_delay:signed_vector(level-1 downto 0)(W1-1 downto 0);

	begin
        -- decomposition
		ndwt_n: for i in 0 to level-1 generate
			edge_condition: if i = 0 generate
				decomposition_0: transform_NDWT generic map(16,16,10,1,NDWT_V1) 
					port map(input_x=>in_x,
							clk=>clock ,
							reset=>reset,
							output_low=>low_des(0),
							output_high=>high_des(0));
			else generate
                decomposition_n: transform_NDWT generic map(16,16,10,2**i,NDWT_V1)
					port map(input_x=>low_des(i-1),
							clk=>clock,
							reset=>reset,
							output_low=>low_des(i),
							output_high=>high_des(i));
			end generate edge_condition;
            
        end generate ndwt_n;

		condition: if align = true generate
        -- shifter registers
			delay_stage: for i in 0 to level-2 generate
				shift_reg: shift_register generic map(16,delay(level_n =>level, stage => (level-1-i)))
					port map(x_in=>high_des(i),
							clock=>clock,
							reset=>reset,
							enable=>'1',
							x_out=>Cd(i));
				end generate delay_stage;
			
			output_assignment_TRUE: for i in 0 to level-1 generate
				Ca(i)<= low_des(i);
				sub_condition:if i > level-2 generate
					Cd(i)<= high_des(i);
				end generate;
			end generate output_assignment_TRUE; 
				
		elsif align = false generate
			output_assignment_FALSE:for i in 0 to level-1 generate
				Ca(i) <= low_des(i);
				Cd(i) <= high_des(i);
			end generate output_assignment_FALSE;
			
		end generate condition;		

end main;