library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.std_logic_signed.all;

entity absavgestimator is
generic( WSIZE: integer ;
         K: integer );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
			
port( x: in signed((WSIZE-1) downto 0):=(others=>'0');
	  y: out signed((WSIZE-1) downto 0):=(others=>'0');
	  clock,reset: in std_logic);
end absavgestimator;

architecture rtl of absavgestimator is
    signal z: signed((WSIZE+K-1) downto 0):=(others=>'0'); -- WSIZE+K para evitar perda de precisao.
    signal absx: signed((WSIZE-1) downto 0):=(others=>'0');
begin

    absx <= x when (x(WSIZE-1) = '0') else (not x) + to_signed(1,x'length);
    
    process(clock,reset)
    begin
        if (reset = '1') then
            z <= (others => '0');
				
        elsif (clock'event and clock = '1') then
            
				z <= z - z((WSIZE+K-1) downto K) + absx;
             y <= z((WSIZE+K-1) downto K); --M.A     y <= z((WSIZE+K-4) downto K-3);
				 
        end if;
    end process;

end rtl;