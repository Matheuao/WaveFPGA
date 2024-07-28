LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity desconstruction is 
	GENERIC (
					W1 : INTEGER := 16; -- Input and output bit width   
					W2 : INTEGER := 16;--32 -- coeficients width	
					num_coef: INTEGER:=10;
					n_delay:integer:=2
			);

			port(
			
			x_in : in signed(W1-1 DOWNTO 0):=(others=>'0');
			clk  : in std_logic;
			reset: in std_logic;
			output_low_des : out signed(W1-1 DOWNTO 0):=(others=>'0');
			output_high_des : out signed(W1-1 downto 0):=(others=>'0')
			);

end desconstruction;

architecture main of desconstruction is

type vector_coef is array (0 to num_coef-1) of signed(W2-1 downto 0);
type vector_mult is array (0 to num_coef-1) of signed((W1+W2)-1 downto 0);
type vector_sum is array (0 to (num_coef)-1) of signed((W1+W2)-1 downto 0);


constant ld:vector_coef:= (X"0E7E",X"36A7",X"418E",X"0C87",X"EA12",X"FD15",X"0705",X"FF6F",X"FEDD",X"004D");
constant hd: vector_coef:=(X"004D",X"0123",X"FF6F",X"F8FB",X"FD15",X"15EE",X"0C87",X"BE72",X"36A7",X"F182");


signal x,out_high,out_low: signed (W1-1 downto 0) :=( others=>'0');
signal a,b,conect_delay_a,conect_delay_b:vector_sum := (others=>x"00000000");
signal x_mult,k_mult:vector_mult:= (others=>x"00000000");


component shift_register
	 GENERIC (
				data_num_bits : INTEGER := 0; -- multiplication bit width (W1*2)
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
	

		entrada: reg generic map(W1=>16) port map(reg_in=>x_in,load=>'1',reset=>reset,clk=>clk,reg_out=>x);
		
		
	scs2:	for i in 0 to num_coef-1 generate --multiplicando
				x_mult(i)<=x*ld(i);
				k_mult(i)<=x*hd(i);
			end generate scs2;
						
			
		
		
		a(num_coef-1)<=x_mult(num_coef-1);
		b(num_coef-1)<=k_mult(num_coef-1);
		
		
		
	scs3 :  for i in num_coef-1 downto 1 generate -- somando

					delay_a: shift_register generic map((W1+W2),n_delay) port map(x_in=>a(i),clock=>clk,reset=>reset,enable=>'1',x_out=>conect_delay_a(i));
						
					a(i-1)<=conect_delay_a(i)+x_mult(i-1);
						
					delay_b: shift_register generic map((W1+W2),n_delay) port map(x_in=>b(i),clock=>clk,reset=>reset,enable=>'1',x_out=>conect_delay_b(i));
						
					b(i-1)<=conect_delay_b(i)+k_mult(i-1);
						
		
				end generate scs3;
		
		
		saida_low: reg generic map(W1=>16) port map(reg_in=>a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15),load=>'1',reset=>reset,clk=>clk,reg_out=>output_low_des);
		saida_high: reg generic map(W1=>16) port map(reg_in=>b(0)((W1+W2)-2 downto ((W1+W2)-2) - 15),load=>'1',reset=>reset,clk=>clk,reg_out=>output_high_des);
		
		--output_low_des<=a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15); --extraindo 16 bits mais significatiovos
		--output_high_des<=b(0)((W1+W2)-2 downto ((W1+W2)-2) - 15);

end main;