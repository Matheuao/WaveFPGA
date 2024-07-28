Library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;


entity reg is

	generic(W1: integer);
	port ( signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );
end reg;
architecture behavior of reg is
 begin
	process(clk,reset) is
	begin
		
		if reset ='1' then
		
			reg_out<=(others=>'0');
		
		elsif rising_edge(clk) then
			if(load='1') then 
				reg_out<=reg_in;
			end if;
		end if;
	end process;
end behavior;