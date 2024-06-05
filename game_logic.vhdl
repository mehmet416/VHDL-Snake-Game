library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_logic is
    generic(
        -- Screen resolution for VGA
        screen_width        : integer := 640;  -- Screen width
        screen_height       : integer := 480;  -- Screen height
        food_width          : integer := 20;  -- Food width
        head_width          : integer := 20;  -- Snake head width
        initial_x           : integer := 100;  -- Initial X position of the snake
        initial_y           : integer := 240;  -- Initial Y position of the snake
        base_length         : integer := 2;  -- Initial length of the snake
        max_length          : integer := 45;  -- Maximum length of the snake
        food_initial_x      : integer := 320;  -- Initial X position of the food
        food_initial_y      : integer := 240;  -- Initial Y position of the food
        initial_speed       : integer := 5);  -- Initial speed of the snake
    port(
        clk_60hz            : in  std_logic;  -- 60 Hz clock signal
        direction           : in  std_logic_vector(1 downto 0);  -- Direction signal
        pause               : in  std_logic;  -- Pause signal
        reset               : in  std_logic;  -- Reset signal
        restart             : in  std_logic;  -- Restart signal
        clk_25mhz           : in  std_logic;  -- 25 MHz clock signal
        en                  : in  std_logic;  -- Enable signal
        row, col            : in  std_logic_vector(15 downto 0);  -- Row and column signals
        rout, gout          : out std_logic_vector(2 downto 0);  -- Red and green output signals
        score               : out std_logic_vector(7 downto 0);  -- Score output signal
        bout                : out std_logic_vector(1 downto 0));  -- Blue output signal
end entity;

architecture main of game_logic is   
 
    type pos_array is array (integer range <>) of std_logic_vector(31 downto 0);  -- Array of positions

    -- Assume the leftmost xy is the head position
    signal snake_length         : integer range 0 to max_length;  -- Snake length
    signal snake_parts          : pos_array(0 to max_length - 1);  -- Array of snake parts
    signal food_xy              : std_logic_vector(31 downto 0);  -- Food position
    signal random_food_pos      : unsigned(31 downto 0);  -- Random food position
    signal fail                 : std_logic := '0';  -- Fail signal
    signal inited               : std_logic := '0';  -- Initialization signal
	 
begin

snake_move:
    process(clk_60hz, reset, random_food_pos)
        constant snake_speed    : signed(15 downto 0) := to_signed(initial_speed, 16);  -- Speed in pixels

        variable next_snake_head       : std_logic_vector(31 downto 0) := (others => '0');  -- Next snake head position
        variable next_food_pos             : std_logic_vector(31 downto 0) := (others => '0');  -- Next food position
        variable next_snake_lenght        : integer := 0;  -- Next snake length
        variable dx, dy                     : signed(15 downto 0) := (others => '0');  -- Distance variables
        variable scorecount                 : integer range 0 to 127;  -- Score count
    begin
        if (reset = '1' or restart = '1' or (inited = '0' and fail = '0')) then
            scorecount := 0;  -- Reset score count
            next_snake_lenght := base_length;  -- Reset snake length

            next_food_pos(31 downto 16) := std_logic_vector(to_signed(food_initial_x, 16));  -- Set initial food X position
            next_food_pos(15 downto 0) := std_logic_vector(to_signed(food_initial_y, 16));  -- Set initial food Y position

            next_snake_head(31 downto 16)  := std_logic_vector(to_signed(initial_x , 16));  -- Set initial snake head X position
            next_snake_head(15 downto 0)   := std_logic_vector(to_signed(initial_y , 16));  -- Set initial snake head Y position

            for i in 0 to max_length - 1 loop
                snake_parts(i) <= next_snake_head;  -- Initialize snake parts
            end loop;
            
            inited <= '1';  -- Set initialized signal
            fail <= '0';  -- Reset fail signal
        elsif (rising_edge(clk_60hz)) then
            if (fail = '0' and pause = '0') then
                case direction is
                    when "00" =>  -- Up
                        next_snake_head(15 downto 0) := std_logic_vector(signed(snake_parts(0)(15 downto 0)) - snake_speed);  -- Move up
                    when "01" =>  -- Right
                        next_snake_head(31 downto 16) := std_logic_vector(signed(snake_parts(0)(31 downto 16)) + snake_speed);  -- Move right
                    when "10" =>  -- Down
                        next_snake_head(15 downto 0) := std_logic_vector(signed(snake_parts(0)(15 downto 0)) + snake_speed);  -- Move down
                    when "11" =>  -- Left
                        next_snake_head(31 downto 16) := std_logic_vector(signed(snake_parts(0)(31 downto 16)) - snake_speed);  -- Move left
                    when others =>  -- Default case
                        null; -- Do nothing
                end case;
                for i in max_length - 1 downto 1 loop
                    snake_parts(i) <= snake_parts(i - 1);  -- Shift snake parts
                end loop;
                snake_parts(0) <= next_snake_head;  -- Update snake head

                if (signed(next_snake_head(31 downto 16)) < 10 + head_width/2 or 
                    signed(next_snake_head(31 downto 16)) >= screen_width - (10 + head_width/2) or
                    signed(next_snake_head(15 downto 0)) < 10 + head_width/2 or
                    signed(next_snake_head(15 downto 0)) >= screen_height - (10 + head_width/2)) then
                    fail <= '1';  -- Boundary check
                end if;

                for i in 1 to max_length - 1 loop
                    if (snake_length > i) then
                        if (next_snake_head = snake_parts(i)) then
                            fail <= '1';  -- Self-collision check
                        end if;
                    end if;
                end loop;

                dx := abs(signed(next_snake_head(31 downto 16)) - signed(next_food_pos(31 downto 16)));  -- Calculate distance to food (X)
                dy := abs(signed(next_snake_head(15 downto 0))  - signed(next_food_pos(15 downto 0)));  -- Calculate distance to food (Y)
                if (dy < 3 *(food_width) / 5 and
                    dx < 3 * (food_width) / 5 ) then
                    next_snake_lenght := next_snake_lenght + 2;  -- Increase snake length
                    scorecount := scorecount + 1 ;  -- Increase score
                    next_food_pos := std_logic_vector(random_food_pos);  -- Change food position
                end if;
					 
            end if;
        end if;
        score           <= std_logic_vector(to_unsigned(scorecount , 8));  -- Update score
        food_xy         <= next_food_pos;  -- Update food position
        snake_length    <= next_snake_lenght;  -- Update snake length
    end process;

random_number_gen:
    process(clk_25mhz)
        variable random_food_x : unsigned(15 downto 0) := (others => '0');  -- Random X position for food
        variable random_food_y : unsigned(15 downto 0) := (others => '0');  -- Random Y position for food
    begin
        if (rising_edge(clk_25mhz)) then
            if (random_food_x > to_unsigned(screen_width - (14 + food_width/2), 16)) then 
                random_food_x := to_unsigned((14 + food_width/2), 16);  -- Ensure food X position is within bounds
            end if;
            if (random_food_y = to_unsigned(screen_height - (14 + food_width/2), 16)) then
                random_food_y := to_unsigned((14 + food_width/2), 16);  -- Ensure food Y position is within bounds
            end if;
            random_food_x := random_food_x + 1;  -- Increment X position
            random_food_y := random_food_y + 1;  -- Increment Y position
            random_food_pos(31 downto 16) <= random_food_x + 7;  -- Update random food X position
            random_food_pos(15 downto 0) <= random_food_y + 7;  -- Update random food Y position
        end if;
    end process;

draw:
    process(snake_length, snake_parts, food_xy, row, col, en)
        variable dx, dy             : signed(15 downto 0) := (others => '0');  -- Distance variables
        variable body_check, food_check, border_check : std_logic := '0';  -- Check variables
    begin
        if (en = '1') then 
            if (to_integer(unsigned(col)) < 10 or 
                to_integer(unsigned(col)) >= screen_height - 10 or 
                to_integer(unsigned(row)) < 10 or 
                to_integer(unsigned(row)) >= screen_width - 10) then
                border_check := '1';  -- Draw border
            else
                border_check := '0';  -- No border
            end if;
            body_check := '0';
            for i in 0 to max_length - 1 loop
                dx := abs(signed(row) - signed(snake_parts(i)(31 downto 16)));  -- Calculate X distance from body part
                dy := abs(signed(col) - signed(snake_parts(i)(15 downto 0)));  -- Calculate Y distance from body part
                if (i < snake_length) then
                    if (dx < head_width / 2 and dy < head_width / 2) then
                        body_check := '1';  -- Check if current pixel belongs to body
                    end if;
                end if;
            end loop;
            dx := abs(signed(row) - signed(food_xy(31 downto 16)));  -- Calculate X distance from food
            dy := abs(signed(col) - signed(food_xy(15 downto 0)));  -- Calculate Y distance from food
            if (dx < food_width / 2 and dy < food_width / 2) then
                food_check := '1';  -- Check if current pixel belongs to food
            else 
                food_check := '0';  -- No food
            end if;
            if (border_check = '1') then
                rout <= "000";  -- Red border
                gout <= "001";  -- Green border
                bout <= "00";  -- No blue border
            elsif (body_check = '1') then
                rout <= "000";  -- Red body
                gout <= "001";  -- Green body
                bout <= "10";  -- Blue body
            elsif (food_check = '1') then
                rout <= "100";  -- Red food
                gout <= "000";  -- No green food
                bout <= "00";  -- No blue food
            else 
                rout <= "000";  -- Default red
                gout <= "110";  -- Default green
                bout <= "00";  -- Default blue
            end if;
        else 
            rout <= "000";  -- No red
            gout <= "000";  -- No green
            bout <= "00";  -- No blue
        end if;
    end process;
end main;
