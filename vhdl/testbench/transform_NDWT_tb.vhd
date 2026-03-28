-- ============================================================================
--  NDWT_decomposition_tb.vhd
--
--  NDWT decomposition Testench
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Verification Testench for the NDWT decomposition component.
--  Use the visualizer.py script.
--  TODO:Compare the component with a goldem model.
--
--  License:
--    Free for academic and non-commercial research use.
--    Commercial use requires a separate commercial license agreement.
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
--
--  Copyright (c) 2026 Matheus Araújo de Oliveira
-- ============================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use std.textio.all;
use work.vector_types.all;
use work.NDWT_types.all;


entity transform_NDWT_tb is
end entity transform_NDWT_tb;

architecture Test of transform_NDWT_tb is
  constant TB_TRANSFORM_VERSION : ndwt_transform_version := NDWT_V3;

  constant ordem : natural := 3;

  signal Entrada   : signed(15 downto 0) := (others => '0');
  signal fs        : std_logic := '0';
  signal rst       : std_logic := '0';
  signal finished  : std_logic := '0';

  constant period  : time := 20 us;
  constant levels : integer := 5;
  signal Ca: signed(15 DOWNTO 0);
  signal Cd: signed(15 DOWNTO 0);

begin

  DUT: entity work.transform_NDWT
    generic map(W1=>16, 
                W2=>16, 
                coefficient_size=>10, 
                n_delay=>1, 
                transform_version=>TB_TRANSFORM_VERSION)
    port map (
      input_x => Entrada,
      clk => fs,
      reset => rst,
      load =>'1',
      output_low => Ca,
      output_high => Cd
    );


  -- Clock signal generation
  fs <= not fs after period/2 when finished /= '1' else '0';

report_process :process
begin
    report "transform_version = " &
           ndwt_transform_version'image(TB_TRANSFORM_VERSION);
    wait;
end process;

  -- Reading stimulus
  stimulus_process: process
    file infile : text open read_mode is "stimulus/sweep_20_4k_fs8k.hex";
    variable in_line : line;
    variable in_val  : std_logic_vector(15 downto 0);
    variable ReadOK  : boolean;
  begin
    rst <= '1';
    wait for 80 ns;
    rst <= '0';
    wait for 80 ns;

    wait until fs = '1' and fs'event;

    while not endfile(infile) loop
      readline(infile, in_line);
      hread(in_line, in_val, ReadOK);
      
      wait for period;
      Entrada <= signed(in_val);
      
    end loop;

    finished <= '1';
    assert false report "Test done." severity note;
    wait;
  end process;

  -- Writing output
  Ca_Cd_1_output: process
    file outfile_Ca : text open write_mode is "stimulus/Ca_1.hex";
    variable outline_Ca : line;
    file outfile_Cd : text open write_mode is "stimulus/Cd_1.hex";
    variable outline_Cd : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca, std_logic_vector(Ca));
      writeline(outfile_Ca, outline_Ca);
     
      hwrite(outline_Cd, std_logic_vector(Cd));
      writeline(outfile_Cd, outline_Cd);
    end loop;
    wait;
  end process;

 
end architecture Test;
