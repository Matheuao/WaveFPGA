library IEEE;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;


ENTITY avg_estimator_test IS
END ENTITY avg_estimator_test;

ARCHITECTURE TestB OF avg_estimator_test IS
	


-------------------------------------------------------------------

CONSTANT ordem : NATURAL := 3; -- 38


	SIGNAL Entrada				: signed (15 DOWNTO 0) := (OTHERS => '0');

	SIGNAL Y1						: signed (29 DOWNTO 0) := (OTHERS => '0');
	SIGNAL RES1      : std_logic_vector(29 downto 0) := (OTHERS => '0');
	SIGNAL fs 					: STD_LOGIC := '0';
	signal alt_clk1        : std_logic := '1';
	signal rst: std_logic:='0';
	
	signal finished: std_logic := '0';
	
	
	CONSTANT period: TIME :=20 us;
	
BEGIN

DUT: entity work.avgestimator
PORT MAP (Entrada,Y1,fs,rst);
	--port map(iniciar_s,reset_s,clock_s,read_m_s,ende_m_s,in_mem_a_s,in_mem_b_s,pronto_s,res_sad_s);
---------------------------
--inst_selector : wavelet_main

---------------------------
	
	RES1<=std_logic_vector(Y1);
	
	
	
	fs <= not fs after period/2 when finished /= '1' else '0';
	
	PROCESS

		FILE infile2 : TEXT IS IN "E:\bolsa\fpga\modwt\DE2-115_ver2\arquivos_teste_bench\media_teste\voz1_refletida.hex";
		VARIABLE in_line2 : LINE;
		VARIABLE in_val2  : std_logic_vector(15 DOWNTO 0);
		VARIABLE ReadOK2  : boolean;
	BEGIN
	
		rst<='1'; 
		
	 wait for 80 ns;

		rst<='0';
	 
	 wait for 80 ns;
	
	
		WAIT UNTIL fs = '1' AND fs'EVENT;
		WHILE NOT(ENDFILE(infile2)) LOOP
			-- read a line from the input file
			READLINE(infile2, in_line2);
			-- read a value from the line
			HREAD(in_line2, in_val2, ReadOK2);
			
			WAIT FOR period ;  
					Entrada <= signed (in_val2);
		END LOOP;
		
	 finished <= '1';
	 
    assert false report "Test done." severity note;
	 
	 wait;
	 
	END PROCESS;
	
	
	PROCESS
		FILE outfile1 : TEXT IS OUT "E:\bolsa\fpga\modwt\DE2-115_ver2\arquivos_teste_bench\media_teste\saida.hex";
		VARIABLE out_line1 : LINE;
	BEGIN
	 
		WAIT UNTIL fs = '1' AND fs'EVENT;
		HWRITE(out_line1, RES1);
		WRITELINE(outfile1, out_line1);
	END PROCESS;
	
	


END ARCHITECTURE TestB;