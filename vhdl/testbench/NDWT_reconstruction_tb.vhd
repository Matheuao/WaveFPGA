library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use std.textio.all;
use work.vector_types.all;
use work.NDWT_types.all;

entity NDWT_reconstruction_tb is
end entity NDWT_reconstruction_tb;

architecture TestB of NDWT_reconstruction_tb is

  constant ordem : natural := 3;

  signal Entrada   : signed(15 downto 0) := (others => '0');
  signal fs        : std_logic := '0';
  signal rst       : std_logic := '0';
  signal finished  : std_logic := '0';

  constant period  : time := 20 us;
  constant levels : integer := 5;
  signal Ca: signed_vector(levels-1 downto 0)(15 downto 0);
  signal Cd: signed_vector(levels-1 downto 0)(15 downto 0);
  signal out_intermediary: signed_vector(levels-2 downto 0)(15 downto 0);
  signal output : signed(15 downto 0);

begin

  DUT_decomposition: entity work.NDWT_decomposition
    generic map(W1=>16, W2=>16, level=>levels, align=>true, transform_version=>NDWT_V1)
    port map (
      in_x => Entrada,
      clock => fs,
      reset => rst,
      Ca => Ca,
      Cd => Cd
    );
  
  DUT_reconstruction: entity work.NDWT_reconstruction
    generic map(W1=>16, W2=>16, level=>levels, transform_version=>NDWT_V1)
    port map (
      Ca_in => Ca,
      Cd_in => Cd,
      clock => fs,
      reset => rst,
      out_intermediary => out_intermediary,
      rec_out => output
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
  output_process: process
    file outfile1 : text open write_mode is "stimulus/reconstruction_out.hex";
    variable out_line1 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
      hwrite(out_line1, std_logic_vector(output));
      writeline(outfile1, out_line1);
    end loop;
    wait;
  end process;

end architecture TestB;
