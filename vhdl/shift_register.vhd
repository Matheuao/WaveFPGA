LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity shift_register is 

		  GENERIC (
				data_num_bits : INTEGER := 32; -- multiplication bit width (W1*2)
				DELAY_W: INTEGER :=1 --15 ate 25 fs/2			
			);

			port(
				x_in : IN signed(data_num_bits-1 DOWNTO 0);
				clock :  in std_logic;
				reset: in std_logic;
				enable: in std_logic;
				x_out : out signed(data_num_bits-1 downto 0)
			);


end shift_register;

architecture main of shift_register is

type vector_delay is array(DELAY_W-1 downto 0) of signed(data_num_bits-1 downto 0);

signal delay :vector_delay ;

	
	begin
	
		process (clock,reset)
		
		--variable i:integer:=1;
		
		begin
			
		
			if reset = '1' then
			
				for i in 0 to DELAY_W-1 loop 
					
					delay(i)<=(others=>'0');
					
				end loop;
			
			elsif rising_edge(clock) then
			
				if enable = '1' then 
			
					delay(0)<=x_in;
					
				else 
				
					delay(0)<=(others=>'0');
					
				end if;
			
				
				for i in 1 to DELAY_W-1 loop 
					
					delay(i)<=delay(i-1);
					
				end loop;
				
			
			end if;
			

		end process;
	
		x_out<=delay(DELAY_W-1);

		
	

end main;