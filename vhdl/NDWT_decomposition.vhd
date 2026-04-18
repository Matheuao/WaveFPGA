-- ============================================================================
--  NDWT_decomposition.vhd
--
--  NDWT decomposition
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Computes de n level NDWT decomposition
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;
USE work.vector_types.all;
use work.transform_types.all;

entity NDWT_decomposition is 
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width 
		W2 : INTEGER := 16; -- multiplication tap bit width
		level:integer:= 5; -- number of levels in de transform
		align:boolean := true; -- True/false for alignment of Ca and Cd in each level
		optimization:ndwt_transform_optimization := None;
		pipeline_stages: integer := 1;
		economy: ndwt_transform_economy := Register_economy
	);
	port(	
		in_x : in signed(w1-1 DOWNTO 0);
		clk: in std_logic;
		reset: in std_logic;
		load: in std_logic;
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
		if ((optimization = None AND pipeline_stages = 0) AND economy = Register_economy) then	
			for i in level_n downto level_n - (stage - 1) loop
				d_count := 2 * (2 + ((2 **(i - 2)) * 9)) + d_previous;
				d_previous := d_count;
			end loop;
		
		elsif((optimization = None AND pipeline_stages = 1) AND economy = Register_economy) then
			for i in level_n downto level_n - (stage - 1) loop
				d_count := 2 * (3 + ((2 **(i - 2)) * 9)) + d_previous;
				d_previous := d_count;
			end loop;
		
		elsif((optimization = None AND pipeline_stages = 0) AND economy = Adder_economy) then
			for i in level_n downto level_n - (stage - 1) loop
				d_count := 1+(2 * (2 + ((2 **(i - 2)) * 9))) + d_previous;
				d_previous := d_count;
			end loop;
		
		elsif((optimization = None AND pipeline_stages = 1) AND economy = Adder_economy) then
			for i in level_n downto level_n - (stage - 1) loop
				d_count := 1+(2 * (3 + ((2 **(i - 2)) * 9))) + d_previous;
				d_previous := d_count;
			end loop;
		
		elsif(optimization = Shared_multipliers AND pipeline_stages = 0) then
			if level_n = 1 then
				--d_count:=1;
			else
				for i in level_n downto level_n - (stage - 1) loop
					d_count := (2 * (2 + ((2 **(i - 2)) * 9))) + d_previous;
					d_previous := d_count;
				end loop;
			end if;
		end if;

	return d_count;
end function;

component transform_NDWT
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width   
		W2 : INTEGER := 16;--32 -- coeficients width	
		coefficient_size: INTEGER:=10;
		n_delay:integer:=1; -- only necessary for the NDWT
		pipeline_stages: integer := 0;
		optimization:ndwt_transform_optimization := Shared_multipliers
		);
	port(
		input_x : in signed(W1-1 DOWNTO 0):=(others=>'0');
		clk  : in std_logic;
		reset: in std_logic;
		load: in std_logic;
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
		shared_multipliers_exception: if optimization = Shared_multipliers generate
			ndwt_n: for i in 0 to level-1 generate
				edge_condition: if i = 0 generate
					decomposition_0: transform_NDWT generic map(W1,W2,10,1,pipeline_stages,optimization) 
						port map(input_x=>in_x,
								clk=>clk ,
								reset=>reset,
								load=> load,
								output_low=>low_des(0),
								output_high=>high_des(0));
				else generate
					decomposition_n: transform_NDWT generic map(W1,W2,10,2**i,pipeline_stages,optimization)
						port map(input_x=>low_des(i-1),
								clk=>clk,
								reset=>reset,
								load=> load,
								output_low=>low_des(i),
								output_high=>high_des(i));
				end generate edge_condition;	
			end generate ndwt_n;

			condition_true: if align = true generate
			-- shifter registers
				
					shift_reg: shift_register generic map(W1,1)
						port map(x_in=>low_des(0),
								clock=>clk,
								reset=>reset,
								enable=>load,
								x_out=>Ca(0));
					Cd(0)<=high_des(0);
					--Cd(0)<=high_des(0);

				
			end generate condition_true;		
			
		else generate
			ndwt_n: for i in 0 to level-1 generate
				edge_condition: if i = 0 generate
					decomposition_0: transform_NDWT generic map(W1,W2,10,1,pipeline_stages,optimization) 
						port map(input_x=>in_x,
								clk=>clk ,
								reset=>reset,
								load=> load,
								output_low=>low_des(0),
								output_high=>high_des(0));
				else generate
					decomposition_n: transform_NDWT generic map(W1,W2,10,2**i,pipeline_stages,optimization)
						port map(input_x=>low_des(i-1),
								clk=>clk,
								reset=>reset,
								load=> load,
								output_low=>low_des(i),
								output_high=>high_des(i));
				end generate edge_condition;
				
			end generate ndwt_n;

			condition_true: if align = true generate
			-- shifter registers
				delay_stage: for i in 0 to level-2 generate
					shift_reg: shift_register generic map(W1,delay(level_n =>level, stage => (level-1-i)))
						port map(x_in=>high_des(i),
								clock=>clk,
								reset=>reset,
								enable=>load,
								x_out=>Cd(i));
					end generate delay_stage;
				
				output_assignment_TRUE: for i in 0 to level-1 generate
					Ca(i)<= low_des(i);
					sub_condition:if i > level-2 generate
						Cd(i)<= high_des(i);
					end generate;
				end generate output_assignment_TRUE; 
			end generate condition_true;		
			condition_false:if align = false generate
				output_assignment_FALSE:for i in 0 to level-1 generate
					Ca(i) <= low_des(i);
					Cd(i) <= high_des(i);
				end generate output_assignment_FALSE;
				
			end generate condition_false;	
		end generate shared_multipliers_exception;	

end main;