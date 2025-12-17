LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity threshold is 
			GENERIC (
				W2 : INTEGER;
				level:integer;
				K :integer ; -- abs_avg_estimator
				s_h:integer  -- 1 para soft 2 para hard
			);

			port(
				cd_ent : in signed (W2-1 downto 0);
				clk:in std_logic;
				rst:in std_logic;
				cd_out : out signed (W2-1 downto 0)
			);

end threshold;

architecture main of threshold is

component shift_register
			GENERIC (
				data_num_bits : INTEGER;
				DELAY_W: INTEGER 	
			);
			

			port(
				x_in : IN signed(w2-1 DOWNTO 0);
				clock :  in std_logic;
				reset: in std_logic;
				enable: in std_logic;
				x_out : out signed(w2-1 downto 0)
			);
end component;

component threshold_function

	GENERIC (
				W2 : INTEGER ;
				s_h: integer  --1 para soft, 2 para hard
			);
		port(
			   cd_ent : in signed (W2-1 downto 0);
				clk : in std_logic;
				reset : in std_logic;
				threshold: in signed(W2-1 downto 0);
				cd_out : out signed (W2-1 downto 0));

end component;

component reg

	generic(W1: integer);
	port ( signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );

end component;

component absavgestimator

	generic( WSIZE: integer ;
				K: integer  );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
	port( x: in signed((WSIZE-1) downto 0):=(others=>'0');
	  y: out signed((WSIZE-1) downto 0):=(others=>'0');
	  clock,reset: in std_logic);
		  
end component;

component avgestimator

	generic( WSIZE: integer ;
				K: integer  );  -- Define o tamanho da janela, sendo que tau = 2^K. Para K = 10, tem-se tau = 1024.
	port( x: in signed((WSIZE-1) downto 0):=(others=>'0');
	  y: out signed((WSIZE-1) downto 0):=(others=>'0');
	  clock,reset: in std_logic);
		  
end component;

signal res_med1:signed(W2-1 downto 0):=(others=>'0');

signal med2:signed(W2-1 downto 0):=(others=>'0');

signal res_med2:signed(W2-1 downto 0):=(others=>'0');

signal sub_med:signed(W2-1 downto 0):=(others=>'0');
signal const:signed(W2-1 downto 0):=(others=>'0');

signal threshold: signed(W2-1 downto 0):=(others=>'0');

signal t_val:signed((W2*2)-1 downto 0) := (others=>'0');
signal t_val_teste:signed((W2)-1 downto 0) := (others=>'0');

signal ent: signed(W2-1 downto 0):=(others => '0');



	
	begin
	
	med1: avgestimator generic map (W2,K) port map (x=>(cd_ent),y=>res_med1,clock=>clk,reset=>rst);
	
	abs_med2: absavgestimator generic map (W2,K) port map (x=>sub_med,y=>res_med2,clock=>clk,reset=>rst);
	
	
	
	sub_med<= cd_ent-res_med1;

	
	------------------------------------------------------------

	scs1:if level = 1 generate
			const<=X"0007";--6,98
			
		  end generate;
			
	scs2:if level = 2 generate
			const<=X"0004";--4,93
			
		 end generate;
			
	scs3:if level = 3 generate
			const<=X"0003"; --3,49
			
		 end generate;
			
	scs4:if level = 4 generate
			const<=X"0002"; --2,46
			
		 end generate;
			
	scs5:if level = 5 generate
			const<=X"0001"; --1,74
			
		 end generate;
		 

	med2<=signed(res_med2);
	
	t_val<=med2 * const;
	t_val_teste<=t_val(W2-1 downto 0);
	
	threshold_buffer: reg generic map(W2) port map(reg_in=>t_val(W2-1 downto 0),load=>'1',reset=>rst,clk=>clk,reg_out=>threshold); 
	input_buffer: shift_register generic map(W2,3) port map(x_in=>cd_ent,clock=>clk,reset=>rst,enable=>'1',x_out=>ent);--a entrada é atrasada três vezes a mais pois o threhsold é atrasado três vezes.
	
	--threshold<=t_val(W2-1 downto 0);
	t_function : threshold_function generic map(W2,s_h) port map(ent,clk,rst,threshold,cd_out);
	
	

end main;