library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;

entity horizontal_sync is
    Port (
        clk : in STD_LOGIC;
        enable : in STD_LOGIC;
        reset : in STD_LOGIC;
        Tdisp : out STD_LOGIC;
        row : out STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
        op : out STD_LOGIC
    );
end horizontal_sync;

architecture Behavioral of horizontal_sync is
    signal output_signal : STD_LOGIC := '1';
    signal display_signal : STD_LOGIC := '1';
    signal vertical_signal : STD_LOGIC := '0';
    signal internal_count : integer range 0 to 799;
	 signal row_count      : integer range 0 to 639;
	
begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_count <= 0;
            display_signal <= '1';
            output_signal <= '1';
            vertical_signal <= '0'; -- Reset vertical signal
        elsif rising_edge(clk) then
            if enable = '1' then
                internal_count <= internal_count + 1;
                
                if internal_count < 48 then
                    display_signal <= '0';
                    output_signal <= '1';
                elsif internal_count < 688 then
						if row_count = 639 then
							row_count <= 0;
						else row_count <= row_count + 1;
						end if;
                    display_signal <= '1';						  
                    output_signal <= '1';
                elsif internal_count < 704 then
                    display_signal <= '0';
                    output_signal <= '1';
                elsif internal_count < 705 then
                    display_signal <= '0';
                    output_signal <= '1';
                elsif internal_count < 800 then
                    display_signal <= '0';
                    output_signal <= '0';
                end if;
                
                if internal_count = 799 then
                    internal_count <= 0;
                end if;
                
                if internal_count < 800 then
                    row <= std_logic_vector(to_unsigned(row_count, row'length));
                else
                    row <= (others => '0');
                end if;
            end if;
        end if;
    end process;
	 
    Tdisp <= display_signal;
    op <= output_signal;
end Behavioral;

