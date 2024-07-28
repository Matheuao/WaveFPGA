LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity threshold_hard is 
			GENERIC (
				W2 : INTEGER := 16
			);

			port(
				cd_ent : in signed (W2-1 downto 0);
				clk:in std_logic;
				rst:in std_logic;
				cd_out : out signed (W2-1 downto 0)
			);

end threshold_hard;

architecture main of threshold_hard is




component absavgestimator

	generic( WSIZE: integer := 16;
				K: integer := 10 );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
	port( x: in std_logic_vector((WSIZE-1) downto 0):=(others=>'0');
	  y: out std_logic_vector((WSIZE-1) downto 0):=(others=>'0');
	  clock,reset: in std_logic);
		  
		  
end component;

signal res_med1:std_logic_vector(W2-1 downto 0):=(others=>'0');
signal res_med1_aux: signed(W2-1 downto 0) := (others=>'0');

signal res_med2:std_logic_vector(W2 downto 0):=(others=>'0');
signal sub_med:signed(W2 downto 0):=(others=>'0');

signal t_val,t_val_aux,t_val_shift:signed(W2+2 downto 0) := (others=>'0');



	
	begin
	
	abs_med1: absavgestimator generic map (WSIZE=>W2,K=>14) port map (x=>std_logic_vector(cd_ent),y=>res_med1,clock=>clk,reset=>rst);
	
	abs_med2: absavgestimator generic map (WSIZE=>W2+1,K=>14) port map (x=>std_logic_vector(sub_med),y=>res_med2,clock=>clk,reset=>rst);
	
	res_med1_aux<=signed(res_med1);
	
	sub_med<= (('0'&(abs(cd_ent))) - ('0' & res_med1_aux));
	


	t_val_aux(W2-1 downto 0)<=signed(res_med2(W2-1 downto 0));
	
	t_val_shift <= shift_left(t_val_aux,3);
	
	t_val(W2+1 downto 0)<=t_val_shift(W2+1 downto 0);
	t_val(0)<='0';
	
	
	process(cd_ent)
	
	begin
	
		if (abs(cd_ent) <  t_val) then --talvez seja possivel simplificar essa comparacao comparando apenas o bit mais significativo do sinal cd_ent
		
			cd_out<= (others=>'0');
		
		else 
			
			cd_out<=cd_ent;
		
		end if;
	
	
	end process;
		

end main;