-- ============================================================================
--  threshold_function.vhd
--
--  Threshold function
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Compute the threshold function. One step into the universal threshold algorithm.
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

entity threshold_function is 
			GENERIC (
				W2 : INTEGER ;
				s_h: integer  --1 para soft, 2 para hard
			);

			port(
				cd_ent : in signed (W2-1 downto 0);
				clk : in std_logic;
				reset : in std_logic;
				threshold: in signed(W2-1 downto 0);
				cd_out : out signed (W2-1 downto 0)
			);

end threshold_function;

architecture main of threshold_function is

signal tmp,tmp2,tmp3,tmp3_out,ent_buf: signed(W2-1 downto 0);

signal comp_2 : signed(W2-1 downto 0);

component reg

generic(W1: integer);
	port ( signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );
	 
end component;
	
begin
	
scs1: if s_h = 1 generate

			tmp <=abs(cd_ent)-threshold;
			tmp2<= tmp +abs(tmp);
			tmp3<=shift_right(tmp2,1);
			
			buffer_1: reg generic map(W2) port map(reg_in=>tmp3,load=>'1',reset=>reset,clk=>clk,reg_out=>tmp3_out);	
		
			comp_2<=(not tmp3_out) + to_signed(1,comp_2'length);
			
			with cd_ent(W2-1) select cd_out <=
				tmp3_out when '0',
				comp_2 when others;
			
		end generate;
		
		
scs2: if s_h = 2 generate 
			
		 process(cd_ent)
			
			begin
				
				if abs(cd_ent)<threshold then
					
					ent_buf<=(others=>'0');
					
				else
				
					ent_buf<=cd_ent;
				end if;
			
			end process;
			
			buffer_1: reg generic map(W2) port map(reg_in=>ent_buf,load=>'1',reset=>reset,clk=>clk,reg_out=>cd_out);	
			
		end generate;
		
	

end main;