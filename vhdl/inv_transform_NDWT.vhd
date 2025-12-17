LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.ndwt_types.all;

entity inv_transform_NDWT is 
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

end inv_transform_NDWT;

architecture main of inv_transform_NDWT is
-- vector types
type vector_coef is array (0 to coefficient_size-1) of signed(W2-1 downto 0);
type vector_mult is array (0 to coefficient_size-1) of signed((W1+W2)-1 downto 0);
type vector_sum is array (0 to (coefficient_size)-1) of signed((W1+W2)-1 downto 0);

-- coefficients constants (db5)
constant ld:vector_coef:= (X"0E7E",X"36A7",X"418E",X"0C87",X"EA12",
                           X"FD15",X"0705",X"FF6F",X"FEDD",X"004D");

constant hd: vector_coef:=(X"004D",X"0123",X"FF6F",X"F8FB",X"FD15",
                           X"15EE",X"0C87",X"BE72",X"36A7",X"F182");

signal x,k: signed (W1-1 downto 0) :=( others=>'0');
signal a,b,conect_delay_a,conect_delay_b:vector_sum;
signal x_mult,k_mult:vector_mult;

component shift_register
	GENERIC (data_num_bits : INTEGER := 0; -- multiplication bit width (W1*2)
			  DELAY_W: INTEGER :=18 --15 ate 25 fs/2			
			 );
	port(
		x_in : IN signed(data_num_bits-1 DOWNTO 0);
		clock :  in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		x_out : out signed(data_num_bits-1 downto 0)
	);
end component;

component reg
	generic(W1: integer:=2);
	port (signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );
end component;

begin

init_transform : if transform_version = NDWT_V1 generate

    entrada_x: reg generic map(W1) 
                port map(reg_in=>rec_low_in,
                         load=>'1',
                         reset=>reset,
                         clk=>clk,
                         reg_out=>x);
    
    entrada_k: reg generic map(W1) 
                port map(reg_in=>rec_high_in,
                         load=>'1',
                         reset=>reset,
                         clk=>clk,
                         reg_out=>k);
    
	mult: for i in 0 to coefficient_size-1 generate --multiplicação
            x_mult(i)<=x*ld(coefficient_size-1-i);
            k_mult(i)<=k*hd(coefficient_size-1-i);
		end generate mult;
						
	a(coefficient_size-1)<=x_mult(coefficient_size-1) + k_mult(coefficient_size-1);		
		
	scs3 : for i in coefficient_size-1 downto 1 generate

                delay_a: shift_register generic map((W1+W2),n_delay) 
                    port map(x_in=>a(i), 
                            clock=>clk,
                            reset=>reset,
                            enable=>'1',
                            x_out=>conect_delay_a(i));
                    
                a(i-1)<=conect_delay_a(i)+x_mult(i-1) + k_mult(i-1);
						
		    end generate scs3;
				
	saida: reg generic map(W1) 
           port map(reg_in=>a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15), 
                    load=>'1',
                    reset=>reset,
                    clk=>clk, 
                    reg_out=>y_out);
		
end generate init_transform;

end main;