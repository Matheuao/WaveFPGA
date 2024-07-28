LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity sub_abs is 
			GENERIC (
				W1 : INTEGER := 32;
				W2 : INTEGER := 32;
				W3 : INTEGER := 32
			);

			port(
				a : in signed (W1-1 downto 0);
				b : in signed (W2-1 downto 0);
				r : out signed (W3-1 downto 0)
			);

end sub_abs;

architecture main of sub_abs is

--signal comp_signal : signed(15 downto 0);
signal r1,r2:signed(W1-1 downto 0);


begin 



r1<=a-b;
r2<=b-a;
	
	
with r1(W1-1)	select 
	r<= r1 when '0',
		 r2 when others;	




end main;