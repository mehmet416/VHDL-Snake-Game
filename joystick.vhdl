library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk_60hz    : in std_logic;  -- 60 Hz clock input
        button      : in std_logic_vector(4 downto 0);  -- Button input
        switch_stop : in std_logic;  -- Stop switch input
        pause       : out std_logic;  -- Pause output
        restart     : out std_logic;  -- Restart output
        direction   : out std_logic_vector(1 downto 0)  -- Direction output
    );
end entity;

architecture main of controller is
    signal current_direction : std_logic_vector(1 downto 0) := "00";  -- Default direction is up
begin
    process(clk_60hz)
        -- Button in "up right down left stop" direction
        variable previous_button_state : std_logic_vector(4 downto 0) := (others => '0');  -- Previous button state
        variable stop_next : std_logic := '0';  -- Stop state variable
        variable direction_next : std_logic_vector(1 downto 0) := (others => '0');  -- Next direction variable
    begin
        if (rising_edge(clk_60hz)) then
            direction_next := current_direction;  -- Maintain current direction unless changed
            
            -- Check for button presses and update direction accordingly
            if (previous_button_state(0) = '0' and button(0) = '1' and current_direction /= "10") then
                direction_next := "00";  -- Up
            end if;
            if (previous_button_state(1) = '0' and button(1) = '1' and current_direction /= "11") then
                direction_next := "01";  -- Right
            end if;
            if (previous_button_state(2) = '0' and button(2) = '1' and current_direction /= "00") then
                direction_next := "10";  -- Down
            end if;
            if (previous_button_state(3) = '0' and button(3) = '1' and current_direction /= "01") then
                direction_next := "11";  -- Left
            end if;

            previous_button_state := button;  -- Update previous button state
            current_direction <= direction_next;  -- Update current direction
        end if;
        
        restart <= button(4);  -- Assign restart output to button(4) state
        pause <= switch_stop;  -- Assign pause output to stop switch state
        direction <= direction_next;  -- Assign direction output to next direction
    end process;
end architecture;
