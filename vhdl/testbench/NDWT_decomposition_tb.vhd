library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use std.textio.all;
use work.vector_types.all;

entity NDWT_decomposition_tb is
end entity NDWT_decomposition_tb;

architecture TestB of NDWT_decomposition_tb is

  constant ordem : natural := 3;

  signal Entrada   : signed(15 downto 0) := (others => '0');
  signal fs        : std_logic := '0';
  signal rst       : std_logic := '0';
  signal finished  : std_logic := '0';

  constant period  : time := 20 us;
  constant levels : integer := 5;
  signal Ca: signed_vector(levels-1 downto 0)(15 downto 0);
  signal Cd: signed_vector(levels-1 downto 0)(15 downto 0);

begin

  DUT: entity work.NDWT_decomposition
    generic map(W1=>16, W2=>16, level=>levels, align=>true)
    port map (
      in_x    => Entrada,
      clock   => fs,
      reset   => rst,
      Ca => Ca,
      Cd => Cd
    );


  -- Clock signal generation
  fs <= not fs after period/2 when finished /= '1' else '0';

  -- Reading stimulus
  stimulus_process: process
    file infile2 : text open read_mode is "stimulus/sweep_20_4k_fs8k.hex";
    variable in_line2 : line;
    variable in_val2  : std_logic_vector(15 downto 0);
    variable ReadOK2  : boolean;
  begin
    rst <= '1';
    wait for 80 ns;
    rst <= '0';
    wait for 80 ns;

    wait until fs = '1' and fs'event;

    while not endfile(infile2) loop
      readline(infile2, in_line2);
      hread(in_line2, in_val2, ReadOK2);
      
      wait for period;
      Entrada <= signed(in_val2);
      
    end loop;

    finished <= '1';
    assert false report "Test done." severity note;
    wait;
  end process;

  -- Writing output
  Ca_Cd_1_output: process
    file outfile_Ca1 : text open write_mode is "stimulus/Ca_1.hex";
    variable outline_Ca1 : line;
    file outfile_Cd1 : text open write_mode is "stimulus/Cd_1.hex";
    variable outline_Cd1 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca1, std_logic_vector(Ca(0)));
      writeline(outfile_Ca1, outline_Ca1);
     
      hwrite(outline_Cd1, std_logic_vector(Cd(0)));
      writeline(outfile_Cd1, outline_Cd1);
    end loop;
    wait;
  end process;

  Ca_Cd_2_output: process
    file outfile_Ca2 : text open write_mode is "stimulus/Ca_2.hex";
    variable outline_Ca2 : line;
    file outfile_Cd2 : text open write_mode is "stimulus/Cd_2.hex";
    variable outline_Cd2 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca2, std_logic_vector(Ca(1)));
      writeline(outfile_Ca2, outline_Ca2);
     
      hwrite(outline_Cd2, std_logic_vector(Cd(1)));
      writeline(outfile_Cd2, outline_Cd2);
    end loop;
    wait;
  end process;

Ca_Cd_3_output: process
    file outfile_Ca3 : text open write_mode is "stimulus/Ca_3.hex";
    variable outline_Ca3 : line;
    file outfile_Cd3 : text open write_mode is "stimulus/Cd_3.hex";
    variable outline_Cd3 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca3, std_logic_vector(Ca(2)));
      writeline(outfile_Ca3, outline_Ca3);
     
      hwrite(outline_Cd3, std_logic_vector(Cd(2)));
      writeline(outfile_Cd3, outline_Cd3);
    end loop;
    wait;
  end process;

Ca_Cd_4_output: process
    file outfile_Ca4 : text open write_mode is "stimulus/Ca_4.hex";
    variable outline_Ca4 : line;
    file outfile_Cd4 : text open write_mode is "stimulus/Cd_4.hex";
    variable outline_Cd4 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca4, std_logic_vector(Ca(3)));
      writeline(outfile_Ca4, outline_Ca4);
     
      hwrite(outline_Cd4, std_logic_vector(Cd(3)));
      writeline(outfile_Cd4, outline_Cd4);
    end loop;
    wait;
  end process;

Ca_Cd_5_output: process
    file outfile_Ca5 : text open write_mode is "stimulus/Ca_5.hex";
    variable outline_Ca5 : line;
    file outfile_Cd5 : text open write_mode is "stimulus/Cd_5.hex";
    variable outline_Cd5 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
       
      hwrite(outline_Ca5, std_logic_vector(Ca(4)));
      writeline(outfile_Ca5, outline_Ca5);
     
      hwrite(outline_Cd5, std_logic_vector(Cd(4)));
      writeline(outfile_Cd5, outline_Cd5);
    end loop;
    wait;
  end process;

end architecture TestB;
