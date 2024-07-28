LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity threshold_soft is 
			GENERIC (
				n_shift: integer:=1;
				W2 : INTEGER := 32
	
			);

			port(
				clk : in std_logic;
				rst : in std_logic;
				cd_ent : in signed (W2-1 downto 0);
				cd_out : out signed (W2-1 downto 0):=X"00000000"
			);

end threshold_soft;

architecture main of threshold_soft is

signal res_med1,res_med2:std_logic_vector(W2-1 downto 0):=(others=>'0');
signal t_val,sub_med:signed(W2-1 downto 0):=(others=>'0');



signal debug: std_logic:='0'; --apagar depois



component absavgestimator

	generic( WSIZE: integer := 32;
				K: integer := 10 );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
	port( x: in std_logic_vector((WSIZE-1) downto 0);
		  y: out std_logic_vector((WSIZE-1) downto 0);
		  clock,reset: in std_logic);
		  
		  
end component;



	begin
	
	abs_med1: absavgestimator generic map (WSIZE=>32,K=>9) port map (x=>std_logic_vector(cd_ent),y=>res_med1,clock=>clk,reset=>rst);
	
	abs_med2: absavgestimator generic map (WSIZE=>32,K=>9) port map (x=>std_logic_vector(sub_med),y=>res_med2,clock=>clk,reset=>rst);
	
--process(cd_ent)

--begin

	sub_med<=cd_ent - signed(res_med1);
	
	
--end process;

	t_val<=shift_right(signed(res_med2),3);
	
	
	process(cd_ent)
	
	begin
	
		if abs(cd_ent)< t_val then 
		
			cd_out<= X"00000000";
			debug<='1';
		
		else 
			debug<='0';
			
			if cd_ent((W2-n_shift-1)) = '1' then -- talves tenha que mudar isso
				
				cd_out<=not(abs(cd_ent-t_val))  + X"00000001";
				
			else 
	
				cd_out<= abs(cd_ent - t_val);
				
			end if;
		
		end if;
	
	
	end process;
		

end main;