-- ============================================================================
--  inv_transform_NDWT.vhd
--
--  Inverse trasform of the NDWT 
--
--  Author       : Matheus Araújo de Oliveira
--  Organization : Federal University of Santa Catarina (UFSC)
--  Email        : matheusaop09@gmail.com
--  Last modified: 2026-02-25
--  Version      : 1.0
--  Description:
--  Computes the inverse transform of the NDWT
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
use work.transform_types.all;

entity inv_transform_NDWT is 
	GENERIC (
        W1 : INTEGER := 16; -- Input and output bit width   
        W2 : INTEGER := 16;--32 -- coeficients width	
        coefficient_size: INTEGER:=10;
        n_delay:integer:=16;
        pipeline_stages: integer := 1;
		optimization:ndwt_transform_optimization := None;
        economy: ndwt_transform_economy := Adder_economy
    );
    port(
        rec_low_in : IN signed(w2-1 DOWNTO 0):=(others=>'0');
        rec_high_in : IN signed(W2-1 downto 0):=(others=>'0');
        reset: in std_logic;
        load: in std_logic;
        clk	: in std_logic;
        y_out: out signed(W2-1 downto 0):=(others=>'0')
    );

end inv_transform_NDWT;

architecture main of inv_transform_NDWT is
-- vector types
type vector_coef is array (0 to coefficient_size-1) of signed(W2-1 downto 0);
type vector_input is array (0 to coefficient_size-1) of signed(W1-1 downto 0);
type vector_mult is array (0 to coefficient_size-1) of signed((W1+W2)-1 downto 0);
type vector_sum is array (0 to (coefficient_size)-1) of signed((W1+W2)-1 downto 0);

-- coefficients constants (db5)
constant ld:vector_coef:= (X"0E7E",X"36A7",X"418E",X"0C87",X"EA12",
                           X"FD15",X"0705",X"FF6F",X"FEDD",X"004D");

constant hd: vector_coef:=(X"004D",X"0123",X"FF6F",X"F8FB",X"FD15",
                           X"15EE",X"0C87",X"BE72",X"36A7",X"F182");

signal x,k,temp_a0,temp_b0,temp_c0,pipe_c0,pipe_b0,pipe_a0: signed (W1-1 downto 0) :=( others=>'0');
signal a,b,c,conect_delay_a,conect_delay_b,conect_delay_c:vector_sum;
signal k_x_sum,k_x_sum_temp,a_delay_line, b_delay_line:vector_input;
signal x_mult,k_mult,c_mult:vector_mult;

component shift_register
	GENERIC (data_num_bits : INTEGER := 0; -- multiplication bit width (W1*2)
			  DELAY_W: INTEGER :=18 --15 ate 25 fs/2			
			 );
	port(
		x_in : IN signed(data_num_bits-1 DOWNTO 0);
		clock :  in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		x_out : out signed(data_num_bits-1 downto 0)
	);
end component;

component reg
	generic(W1: integer:=2);
	port (signal reg_in :in  signed(W1-1 downto 0):=(others=>'0') ;
			signal load: in std_logic;
			signal reset: in std_logic;
			signal clk: in std_logic;
			signal reg_out: out signed(W1-1 downto 0)
	 );
end component;

begin

    gen_inv_None : if optimization = None generate
        gen_register_economy: if economy = Register_economy generate
        
            entrada_x: reg generic map(W1) 
                        port map(reg_in=>rec_low_in,
                                load=>load,
                                reset=>reset,
                                clk=>clk,
                                reg_out=>x);
            
            entrada_k: reg generic map(W1) 
                        port map(reg_in=>rec_high_in,
                                load=>load,
                                reset=>reset,
                                clk=>clk,
                                reg_out=>k);
            pipeline_0: if pipeline_stages = 0 generate
                
                mult: for i in 0 to coefficient_size-1 generate 
                    x_mult(i)<=x*ld(coefficient_size-1-i);
                    k_mult(i)<=k*hd(coefficient_size-1-i);
                end generate mult;
            end generate pipeline_0;
            
            pipeline_1: if pipeline_stages = 1 generate
                
                process(clk,reset)
                begin
                    if reset = '1' then
                        for i in 0 to coefficient_size-1 loop 
                            x_mult(i)<=(others => '0');
                            k_mult(i)<=(others => '0');
                        end loop;
                    elsif rising_edge(clk) then
                        if load = '1' then
                            for i in 0 to coefficient_size-1 loop 
                                x_mult(i)<=x*ld(coefficient_size-1-i);
                                k_mult(i)<=k*hd(coefficient_size-1-i);
                            end loop;
                        end if;
                    end if;
                end process;
            end generate pipeline_1;
            
            a(coefficient_size-1)<=x_mult(coefficient_size-1) + k_mult(coefficient_size-1);		
                
            scs3 : for i in coefficient_size-1 downto 1 generate

                        delay_a: shift_register generic map((W1+W2),n_delay) 
                            port map(x_in=>a(i), 
                                    clock=>clk,
                                    reset=>reset,
                                    enable=>load,
                                    x_out=>conect_delay_a(i));
                            
                        a(i-1)<=conect_delay_a(i)+x_mult(i-1) + k_mult(i-1);
            end generate scs3;
                        
            output: reg generic map(W1) 
                port map(reg_in=>a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15), 
                            load=>load,
                            reset=>reset,
                            clk=>clk, 
                            reg_out=>y_out);
        end generate gen_register_economy;

        gen_adder_economy: if economy = Adder_economy generate
            
            entrada_x: reg generic map(W1) 
                        port map(reg_in=>rec_low_in,
                                load=>load,
                                reset=>reset,
                                clk=>clk,
                                reg_out=>x);
            
            entrada_k: reg generic map(W1) 
                        port map(reg_in=>rec_high_in,
                                load=>load,
                                reset=>reset,
                                clk=>clk,
                                reg_out=>k);
            
            pipeline_0: if pipeline_stages = 0 generate
            
                mult: for i in 0 to coefficient_size-1 generate 
                        x_mult(i)<=x*ld(coefficient_size-1-i);
                        k_mult(i)<=k*hd(coefficient_size-1-i);
                end generate mult;
            end generate pipeline_0;

            pipeline_1: if pipeline_stages = 1 generate
                
                process(clk,reset)
                    begin
                        if reset = '1' then
                            for i in 0 to coefficient_size-1 loop 
                                x_mult(i)<=(others => '0');
                                k_mult(i)<=(others => '0');
                            end loop;
                        elsif rising_edge(clk) then
                            if load = '1' then
                                for i in 0 to coefficient_size-1 loop 
                                    x_mult(i)<=x*ld(coefficient_size-1-i);
                                    k_mult(i)<=k*hd(coefficient_size-1-i);
                                end loop;
                            end if;
                        end if;
                    end process;
            end generate pipeline_1;
                                
            a(coefficient_size-1)<=x_mult(coefficient_size-1);	
            b(coefficient_size-1)<=k_mult(coefficient_size-1);	
            
            scs3 : for i in coefficient_size-1 downto 1 generate

                delay_a: shift_register generic map((W1+W2),n_delay) 
                    port map(x_in=>a(i), 
                            clock=>clk,
                            reset=>reset,
                            enable=>load,
                            x_out=>conect_delay_a(i));
                a(i-1)<= conect_delay_a(i) +x_mult(i-1);

                delay_b: shift_register generic map((W1+W2),n_delay) 
                    port map(x_in=>b(i), 
                            clock=>clk,
                            reset=>reset,
                            enable=>load,
                            x_out=>conect_delay_b(i));
                    
                b(i-1)<=conect_delay_b(i) + k_mult(i-1);
                                
            end generate scs3;
            temp_a0_reg: reg generic map(W1) 
                port map(reg_in=>a(0)((W1+W2)-2 downto ((W1+W2)-2) - 15), 
                            load=>load,
                            reset=>reset,
                            clk=>clk, 
                            reg_out=>temp_a0);
            temp_b0_reg: reg generic map(W1) 
                port map(reg_in=>b(0)((W1+W2)-2 downto ((W1+W2)-2) - 15), 
                            load=>load,
                            reset=>reset,
                            clk=>clk, 
                            reg_out=>temp_b0);
                        
                        
            output: reg generic map(W1) 
                port map(reg_in=>temp_a0+temp_b0, 
                            load=>load,
                            reset=>reset,
                            clk=>clk, 
                            reg_out=>y_out);
        end generate gen_adder_economy;
    end generate gen_inv_None;

    gen_inv_Shared_multipliers : if optimization = Shared_multipliers generate
        
        entrada_x: reg generic map(W1) 
                        port map(reg_in=>rec_low_in,
                                load=>load,
                                reset=>reset,
                                clk=>clk,
                                reg_out=>x);
            
        entrada_k: reg generic map(W1) 
                    port map(reg_in=>rec_high_in,
                            load=>load,
                            reset=>reset,
                            clk=>clk,
                            reg_out=>k);
        -- delay line
        process (clk,reset)
        begin

            if reset = '1' then
        
                for i in 0 to coefficient_size-1 loop 	
                    a_delay_line(i)<=(others=>'0');
                    b_delay_line(i)<=(others=>'0');	
                end loop;
            elsif rising_edge(clk) then
                
                if load = '1' then 
                    a_delay_line(0)<=x;
                    b_delay_line(0)<=k;	
                end if;
            
                for i in 1 to coefficient_size-1 loop 
                    a_delay_line(i)<=a_delay_line(i-1);
                    b_delay_line(i)<=b_delay_line(i-1);
                end loop;
                
            end if;
        end process;

        delay_line_sum:for i in 0 to coefficient_size-1 generate
            even_gen: if ((i+1) mod 2 = 0) generate 
                 k_x_sum(i)<= a_delay_line(i)-b_delay_line(coefficient_size-1-i);

            else generate
                k_x_sum(i)<=a_delay_line(i)+b_delay_line(coefficient_size-1-i);

            end generate even_gen;
        end generate delay_line_sum;
    


        --delay line convolution multiplication
        pipeline_0: if pipeline_stages = 0 generate
    
            mult: for i in 0 to coefficient_size-1 generate 
                c_mult(i)<=k_x_sum(i)*ld(coefficient_size-1-i);
            end generate mult;
        end generate pipeline_0;

        pipeline_1: if pipeline_stages = 1 generate
            
            process(clk,reset)
            begin
                if reset = '1' then
                    for i in 0 to coefficient_size-1 loop 
                        k_x_sum_temp(i)<=(others => '0');
                        c_mult(i)<=(others => '0');
                    end loop;
                elsif rising_edge(clk) then
                    if load = '1' then
                        for i in 0 to coefficient_size-1 loop 
                            k_x_sum_temp(i)<=k_x_sum(i);
                            c_mult(i) <= k_x_sum_temp(i) * ld(coefficient_size-1-i);
                        end loop;
                    end if;
                end if;
            end process;
        end generate pipeline_1;
                            
        c(0)<=c_mult(0)+c_mult(1)+c_mult(2)+c_mult(3)+c_mult(4)+c_mult(5)+c_mult(6)+c_mult(7)+c_mult(8)+c_mult(9);

        pipeline_reg: reg generic map(W1=>W1) 
            port map(reg_in=>c(0)((W1+W2)-2 downto ((W1+W2)-2) - 15),
                    load=>load,
                    reset=>reset,
                    clk=>clk,
                    reg_out=>pipe_c0);

        --temp_c0<= pipe_c0 + to_signed(coefficient_size/2,W1);
        temp_c0<= pipe_c0;

        output: reg generic map(W1=>W1) 
            port map(reg_in=>temp_c0,
                    load=>load,
                    reset=>reset,
                    clk=>clk,
                    reg_out=>y_out);
    end generate gen_inv_Shared_multipliers;
end main;