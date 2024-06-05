library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity vertical_sync is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           reset : in STD_LOGIC;           
           op : out STD_LOGIC;
			  col: out STD_LOGIC_VECTOR(15 downto 0)
    );
end vertical_sync;

architecture Behavioral of vertical_sync is

signal output_signal : STD_LOGIC  := '1' ;
signal internal_count : integer range 0 to 520 := 0 ;
signal enable_edge : std_logic := '0' ;
signal col_count      : integer range 0 to 479;
begin

--Bakmam için lab6 dan örnek 
--elsif rising_edge(clk) then
--            if load = '1' then
--				loadedge <= '1'; 
--				elsif load = '0' and loadedge = '1' then
--               counter <= load_value;
--               loadedge <= '0'; -- load durumunda edge sıfırlanır
--				elsif up_count = '1' then
--				upedge <= '1'; 
--
-- if load = '1' then
--				loadedge <= '1'; 
----				elsif load = '0' and loadedge = '1' then
--  process(clk, reset)
--    begin
--        if reset = '1' then
--            internal_count <= 0;
--            display_signal <= '1';
--            output_signal <= '1';
--            vertical_signal <= '0'; -- Reset vertical signal
--        elsif rising_edge(clk) then
--            if enable = '1' then
--                internal_count <= internal_count + 1;
--                
--                if internal_count < 48 then
--                    display_signal <= '0';
--                    output_signal <= '1';
--                elsif internal_count < 688 then
--						if row_count = 639 then
--							row_count <= 0;
--						else row_count <= row_count + 1;
--						end if;
--                    display_signal <= '1';						  
--                    output_signal <= '1';
--                elsif internal_count < 704 then
--                    display_signal <= '0';
--                    output_signal <= '1';
--                elsif internal_count < 705 then
--                    display_signal <= '0';
--                    output_signal <= '1';
--                elsif internal_count < 800 then
--                    display_signal <= '0';
--                    output_signal <= '0';
--                end if;
				
    process(clk, reset)
    begin
      
        if reset = '1' then
            internal_count <= 0 ;
            output_signal <= '0';
        elsif rising_edge(clk) then
            if enable = '1' and enable_edge = '0' then 
					 enable_edge <= '1'; 
					 if internal_count < 29 then
						  output_signal <= '1';
					 elsif internal_count < 509 then
							output_signal <= '1';
						if col_count = 479 then
						col_count <= 0;
						else col_count <= col_count + 1;
						end if; 
						
						
                elsif internal_count < 519 then
                    output_signal <= '1';
                elsif internal_count < 521 then
                    output_signal <= '0';
                end if;
                
                if internal_count = 520 then
                    internal_count <= 0 ;
					 else internal_count <= internal_count + 1 ;   
                end if;
				elsif enable = '0' then
					enable_edge <= '0' ;
					end if;
					
			  -- Ensure row and col are assigned within range
				if (internal_count < 640) then
				col <= std_logic_vector(to_unsigned(col_count, col'length)); 
				else
				col <= (others => '0');
				end if;
                
				
					 
					 
            				
        end if;      
    end process;
    
    op <= output_signal;
    
end Behavioral;
