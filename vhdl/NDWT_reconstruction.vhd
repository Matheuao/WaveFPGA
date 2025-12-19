LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.all;
USE work.vector_types.all;
use work.ndwt_types.all;

entity NDWT_reconstruction is 
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width 
		W2 : INTEGER := 16; -- multiplication tap bit width
		level:integer:= 5 -- number of levels in de transform
		);
	port(	
		Ca_in :in signed_vector(level-1 downto 0)(W1-1 downto 0);
        Cd_in: in signed_vector(level-1 downto 0)(W1-1 downto 0);
		clock: in std_logic;
		reset: in std_logic;
		out_intermediary: out signed_vector(level-2 downto 0)(W1-1 downto 0);
        rec_out: out signed(W1-1 downto 0)
	);

end NDWT_reconstruction;
architecture main of NDWT_reconstruction is

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

signal solution:signed_vector(level-1 downto 0)(W1-1 downto 0);

	begin
        indwt_n: for i in level-1 downto 0 generate
			edge_condition: if i = level-1 generate
				reconstruction_0: inv_transform_NDWT generic map (W1,W2,10,2**(level-1),NDWT_V1)
					port map(rec_low_in=>Ca_in(i),
							rec_high_in=>Cd_in(i),
							reset=>reset,
							clk=>clock,
							y_out=>solution(i));
			else generate
                reconstruction_n: inv_transform_NDWT generic map (W1,W1,10,2**(level-1-i),NDWT_V1)
					port map(rec_low_in=>solution(i-1),
							rec_high_in=>Cd_in(i),
							reset=>reset,
							clk=>clock,
							y_out=>solution(i));
            end generate edge_condition;
		end generate indwt_n;

    output_assigment:for i in level-1 downto 1 generate
        out_intermediary(i)<= solution(i);
    end generate output_assigment;
    
    rec_out<= solution(0);
end main;