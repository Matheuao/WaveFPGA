library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SQRT is
    Generic ( b  : natural range 4 to 32 := 32 ); 
    Port ( number  : in   STD_LOGIC_VECTOR (31 downto 0);
           result : out  STD_LOGIC_VECTOR (15 downto 0)
			  );
end SQRT;

architecture Behave of SQRT is

begin
   process (number)
   variable vop  : unsigned(b-1 downto 0);  
   variable vres : unsigned(b-1 downto 0);  
   variable vone : unsigned(b-1 downto 0);  
   begin
      vone := to_unsigned(2**(b-2),b);
      vop  := unsigned(number);
      vres := (others=>'0'); 
      while (vone /= 0) loop
         if (vop >= vres+vone) then
            vop   := vop - (vres+vone);
            vres  := vres/2 + vone;
         else
            vres  := vres/2;
         end if;
         vone := vone/4;
      end loop;
      result <= std_logic_vector(vres(result'range));
   end process;
end;