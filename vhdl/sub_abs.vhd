-- ============================================================================
--  sub_abs.vhd
--
--  Absolute subtraction
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Computes the absolute subtraction operation
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