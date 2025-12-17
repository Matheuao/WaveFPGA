LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.dwt_types.all;

entity transform_DWT is 
	GENERIC (
		W1 : INTEGER := 16; -- Input and output bit width   
		W2 : INTEGER := 16;--32 -- coeficients width	
		coefficient_size: INTEGER:=8;
        transform_version:dwt_transform_version := DWT_V1
		);

    port(
        input_x : in signed(W1-1 DOWNTO 0):=(others=>'0');
        clk  : in std_logic;
        enable: in std_logic;
        reset: in std_logic;
        output_low : out signed(W1-1 DOWNTO 0):=(others=>'0');
        output_high : out signed(W1-1 downto 0):=(others=>'0')
    );

end transform_DWT;

architecture main of transform_DWT is
-- vector types
type vector_coef is array (0 to coefficient_size-1) of signed(W2-1 downto 0);
type vector_mult is array (0 to coefficient_size-1) of signed((W1+W2)-1 downto 0);
type vector_sum is array (0 to (coefficient_size)-1) of signed((W1+W2)-1 downto 0);

-- coefficients constants db4
constant ld:vector_coef:= (X"FEA5",X"0435",X"03F3",X"E80F",
                           X"FC6B",X"50C0",X"5B7F",X"1D7D");

constant hd: vector_coef:=(X"E283",X"5B7F",X"AF40",X"FC6B",
                           X"17F1",X"03F3",X"FBCB",X"FEA5");

-- variables
signal x,out_high,out_low: signed (W1-1 downto 0) :=( others=>'0');
signal a,b,conect_delay_a,conect_delay_b:vector_sum;
signal x_mult,k_mult:vector_mult;

component reg

	generic(W1: integer:=0);
	port (
			signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );

end component;
	
	begin
	
init_transform : if transform_version = DWT_V1 generate

	input: reg generic map(W1=>16) 
		   port map(reg_in=>input_x,
		   			load=> enable,
					reset=>reset,
					clk=>clk,
					reg_out=>x);
		
	mult: for i in 0 to coefficient_size-1 generate --multiplication
			x_mult(i)<=x*ld(i);
			k_mult(i)<=x*hd(i);
		end generate mult;
						
	a(coefficient_size-1)<=x_mult(coefficient_size-1);
	b(coefficient_size-1)<=k_mult(coefficient_size-1);
		
	sum :for i in coefficient_size-1 downto 1 generate -- FIR transposed form

			delay_a: reg generic map((W1+W2)) 
					port map(reg_in=>a(i),
                             load =>enable,
                             reset =>reset,
							 clk=>clk,
							 reg_out=>conect_delay_a(i));
				
			a(i-1)<=conect_delay_a(i)+x_mult(i-1);
				
			delay_b: reg generic map((W1+W2)) 
					port map(reg_in=>b(i), 
							 load =>enable,
                             reset => reset, 
							 clk => clk,
							 reg_out=>conect_delay_b(i));
				
			b(i-1)<=conect_delay_b(i)+k_mult(i-1);
	
		end generate sum;
		
    output_lowpass_coefficients: reg generic map(W1=>16) 
        port map(reg_in=>a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15),
                load=>enable,
                reset=>reset,
                clk=>clk,
                reg_out=>output_low);
    output_highpass_coefficients: reg generic map(W1=>16) 
        port map(reg_in=>b(0)((W1+W2)-2 downto ((W1+W2)-2) - 15),
                load=>enable,
                reset=>reset,
                clk=>clk,
                reg_out=>output_high);

end generate init_transform;

end main;