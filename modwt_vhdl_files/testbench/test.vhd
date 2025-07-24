library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use std.textio.all;

entity test is
end entity test;

architecture TestB of test is

  constant ordem : natural := 3;

  signal Entrada   : signed(15 downto 0) := (others => '0');
  signal Y1        : signed(15 downto 0) := (others => '0');
  signal RES1      : std_logic_vector(15 downto 0) := (others => '0');
  signal fs        : std_logic := '0';
  signal rst       : std_logic := '0';
  signal finished  : std_logic := '0';

  constant period  : time := 20 us;

begin

  DUT: entity work.modwt
    port map (
      in_x    => Entrada,
      clock   => fs,
      out_y   => Y1,
      reset_m => rst
    );

  RES1 <= std_logic_vector(Y1);

  -- Clock signal generation
  fs <= not fs after period/2 when finished /= '1' else '0';

  -- Reading stimulus
  stimulus_process: process
    file infile2 : text open read_mode is "sweep_20_4k_fs8k.hex";
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
    file outfile1 : text open write_mode is "saida.hex";
    variable out_line1 : line;
  begin
    while finished = '0' loop
      wait until fs = '1' and fs'event;
      hwrite(out_line1, RES1);
      writeline(outfile1, out_line1);
    end loop;
    wait;
  end process;

end architecture TestB;
