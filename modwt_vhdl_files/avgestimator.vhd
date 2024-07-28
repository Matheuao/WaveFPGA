library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avgestimator is
generic( WSIZE: integer;
         K: integer );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
port(
	  x: in signed((WSIZE-1) downto 0):=(others=>'0');
	  y: out signed((WSIZE-1) downto 0):=(others=>'0');
	  clock,reset: in std_logic);
	  
end avgestimator;

architecture rtl of avgestimator is

signal z: signed((WSIZE+K-1) downto 0):=(others=>'0'); -- WSIZE+K para evitar perda de precisao.
    
	 
begin

    
    process(clock,reset)
    begin
        if (reset = '1') then
            z <= (others => '0');
				
        elsif (clock'event and clock = '1') then
            
				z <= z - z((WSIZE+K-1) downto K) + x;
             y <= z((WSIZE+K-1) downto K); --M.A     y <= z((WSIZE+K-4) downto K-3);
				 
        end if;
		  
    end process;

end rtl;