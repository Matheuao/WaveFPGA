library IEEE;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;


ENTITY test_square_root IS
END ENTITY test_square_root;

ARCHITECTURE TestB OF test_square_root IS
	


-------------------------------------------------------------------



	signal numero:std_logic_vector(31 downto 0):=(others=>'0');
	
	signal resultado: std_logic_vector(15 downto 0):=(others=>'0');
	
	signal finished: std_logic := '0';
	
	
	CONSTANT period: TIME :=20 us;
	
component SQRT

Generic ( b  : natural range 4 to 32 := 32 ); 
    Port ( number  : in   STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (15 downto 0)
			  );
	
	
end component;
	
BEGIN

DUT: SQRT port map(numero,resultado);
	
---------------------------



	
	PROCESS

	
	BEGIN
	
		
		numero<=std_logic_vector(to_unsigned(4, numero'length));

		
	 wait for period ;

		numero<=std_logic_vector(to_unsigned(16, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(64, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(25, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(2500, numero'length));
		
	
	 wait for period ;
	 
	 
	 numero<=std_logic_vector(to_unsigned(13000, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(15000, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(3000, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(131072, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(141072, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(1310720, numero'length));
		
	
	 wait for period ;
	 
	 numero<=std_logic_vector(to_unsigned(10072, numero'length));
		
	
	 wait for period ;
	
		
	 finished <= '1';
	 
    assert false report "Test done." severity note;
	 
	 wait;
	 
	END PROCESS;
	


END ARCHITECTURE TestB;