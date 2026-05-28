LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE std.textio.all;
USE ieee.std_logic_textio.all;
use ieee.numeric_std.all; 

ENTITY aes128_top_test IS
END aes128_top_test;

ARCHITECTURE behavior OF aes128_top_test IS

    COMPONENT tt_AES128
    PORT(
		 ui_in    : IN  std_logic_vector(7 downto 0);
		 uo_out   : OUT std_logic_vector(7 downto 0);
		 uio_in   : IN  std_logic_vector(7 downto 0);
		 uio_out  : OUT std_logic_vector(7 downto 0);
		 uio_oe   : OUT std_logic_vector(7 downto 0);
		 ena      : IN  std_logic;
		 clk      : IN  std_logic;
		 rst_n    : IN  std_logic
    );
    END COMPONENT;

	 -- input/output
	 signal ui_in   : std_logic_vector(7 downto 0);
	 signal uo_out  : std_logic_vector(7 downto 0);
	 signal uio_in  : std_logic_vector(7 downto 0);
    signal uio_out : std_logic_vector(7 downto 0);
	 signal uio_oe  : std_logic_vector(7 downto 0);
	 signal ena     : std_logic := '1';
	 signal clk     : std_logic := '0';
	 signal rst_n   : std_logic := '0';	 

    constant clk_period : time := 10 ns;
	 signal sim_done : boolean := false;

    -- files	 
	 file data_in_file : text;
	 file key_file : text;
	 file expected_out_file : text;

BEGIN	
    -- instantiate tt_AES128
    uut: tt_AES128
    PORT MAP (
		 ui_in => ui_in,
		 uo_out => uo_out,
		 uio_in => uio_in,
		 uio_out => uio_out,
		 uio_oe => uio_oe,
		 ena => ena,
		 clk => clk,
		 rst_n => rst_n
    );

    -- clock system
    clk_process : process
    begin
	     if sim_done then
        wait;
    end if;
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

--    tb_enc_ored <= or_reduce(encrypted);

    -- assestions to check flags
--    assert_proc : process
--    begin
--        wait for clk_period;
--       
--        assert not(done = 'X') report "done is X" severity failure;
--        assert not(busy = 'X') report "busy is X" severity failure;
--        assert not((done = '1') and (tb_enc_ored = 'X')) 
--            report "encrypted output contains X when done=1" severity failure;
--    end process;

   -- starting test process
	test_process : process
		 variable data_in_line      : line;
		 variable key_line          : line;
		 variable expected_out_line : line;
		 variable data_in_vec       : std_logic_vector(127 downto 0);
		 variable key_vec           : std_logic_vector(127 downto 0);
		 variable expected_out_vec  : std_logic_vector(127 downto 0);
		 variable vec_count         : integer := 0;
	begin
		 -- initialise with 0
		 uio_in <= (others => '0');
		 ui_in  <= (others => '0');

		 -- reset pulse
		 rst_n <= '0';
		 wait for clk_period * 2;
		 rst_n <= '1';
		 wait for clk_period;

		 file_open(data_in_file, "vectors/data_in.txt", read_mode);
		 file_open(key_file, "vectors/key_in.txt", read_mode);
		 file_open(expected_out_file, "vectors/data_out.txt", read_mode);

		 while not endfile(data_in_file) loop
			  readline(data_in_file, data_in_line);
			  readline(key_file, key_line);
			  readline(expected_out_file, expected_out_line);
			  hread(data_in_line, data_in_vec);
			  hread(key_line, key_vec);
			  hread(expected_out_line, expected_out_vec);

			  -- load key bytes
			  for i in 0 to 15 loop
					uio_in <= (others => '0');
					uio_in(5) <= '1';
					uio_in(4 downto 0) <= std_logic_vector(to_unsigned(i, 5));
					ui_in <= key_vec(127 - i*8 downto 120 - i*8);
					wait for clk_period;
			  end loop;
			  uio_in <= (others => '0');
			  wait for clk_period;

			  -- load plaintext bytes
			  for i in 0 to 15 loop
					uio_in <= (others => '0');
					uio_in(5) <= '1';
					uio_in(4 downto 0) <= std_logic_vector(to_unsigned(16 + i, 5));
					ui_in <= data_in_vec(127 - i*8 downto 120 - i*8);
					wait for clk_period;
			  end loop;
			  uio_in <= (others => '0');
			  wait for clk_period;

			  -- pulse start
			  uio_in(6) <= '1';
			  wait for clk_period;
			  uio_in(6) <= '0';
			  wait for clk_period;

			  -- wait for done flag (output_sel=0 so uo_out(0) = done bit)
			  wait until uo_out(0) = '1';
			  wait for clk_period;

			  -- read and verify cipher bytes (MSB first)
			  for i in 0 to 15 loop
					uio_in <= (others => '0');
					uio_in(7) <= '1';
					uio_in(4 downto 0) <= std_logic_vector(to_unsigned(i, 5));
					wait for clk_period;

					if uo_out /= expected_out_vec(127 - i*8 downto 120 - i*8) then
						 report "MISMATCH byte " & integer'image(i) &
								  " expected " & to_hstring(expected_out_vec(127 - i*8 downto 120 - i*8)) &
								  " got " & to_hstring(uo_out)
								  severity error;
					else
						 report "MATCHED byte " & integer'image(i) &
								  " expected " & to_hstring(expected_out_vec(127 - i*8 downto 120 - i*8)) &
								  " got " & to_hstring(uo_out)
								  severity note;
					end if;
			  end loop;
			
			  -- testing next vector
			  uio_in <= (others => '0');
			  wait for clk_period;

			  vec_count := vec_count + 1;
		 end loop;

		 report "Done: " & integer'image(vec_count) & " vectors tested" severity note;
		 sim_done <= true;
		 wait;
	end process;
END;
