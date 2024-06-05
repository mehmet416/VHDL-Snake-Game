library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game is
    port(
        clk_100mhz          : in  std_logic;  -- 100 MHz clock input
        reset               : in  std_logic;  -- Reset signal
        button              : in  std_logic_vector(4 downto 0);  -- Button input
        hout, vout          : out std_logic;  -- Horizontal and vertical sync outputs
        restart_sw          : in  std_logic;  -- Restart switch input
        
        rout, gout          : out std_logic_vector(2 downto 0);  -- Red and green output signals
        bout                : out std_logic_vector(1 downto 0);  -- Blue output signal
        row                 : out std_logic_vector(15 downto 0);  -- Row output
        SSEG_CA             : out std_logic_vector (7 downto 0);  -- 7-segment display cathode output
        SSEG_AN             : out std_logic_vector (3 downto 0);  -- 7-segment display anode output
        col                 : out std_logic_vector(15 downto 0)  -- Column output
    );
end entity;

architecture arch of game is
    component game_logic
        port(
            clk_60hz            : in  std_logic;  -- 60 Hz clock input
            direction           : in  std_logic_vector(1 downto 0);  -- Direction input
            pause               : in  std_logic;  -- Pause signal
            reset               : in  std_logic;  -- Reset signal
            restart             : in  std_logic;  -- Restart signal
            clk_25mhz           : in  std_logic;  -- 25 MHz clock input
            en                  : in  std_logic;  -- Enable signal
            row, col            : in  std_logic_vector(15 downto 0);  -- Row and column inputs
            score               : out std_logic_vector(7 downto 0);  -- Score output
            rout, gout          : out std_logic_vector(2 downto 0);  -- Red and green output signals
            bout                : out std_logic_vector(1 downto 0)  -- Blue output signal
        );
    end component;

    component f_dvdr is
        port (
            clk         : in  std_logic;  -- Clock input
            reset       : in  std_logic;  -- Reset signal
            divided_clk : out std_logic  -- Divided clock output
        );
    end component;
    FOR ALL : f_dvdr USE ENTITY WORK.f_dvdr (Behavioral);

    component binarytobcd is
        port (
            A : in  std_logic_vector(7 downto 0);  -- Binary input
            B : out std_logic_vector(11 downto 0)  -- BCD output
        );
    end component;
    FOR ALL : binarytobcd USE ENTITY WORK.binary_to_bcd (Structural);

    component bcdtosevensegment is
        port (
            d : in  std_logic_vector (3 downto 0);  -- BCD input
            s : out std_logic_vector (6 downto 0)  -- 7-segment display output
        );
    end component;
    FOR ALL : bcdtosevensegment USE ENTITY WORK.BCD_to_seven_segment (Dataflow);

    component nexys3ssegdriver is
        port (
            MY_CLK  : in  std_logic;  -- Clock input
            DIGIT0  : in  std_logic_vector (7 downto 0);  -- Digit 0 input
            DIGIT1  : in  std_logic_vector (7 downto 0);  -- Digit 1 input
            DIGIT2  : in  std_logic_vector (7 downto 0);  -- Digit 2 input
            DIGIT3  : in  std_logic_vector (7 downto 0);  -- Digit 3 input
            SSEG_CA : out std_logic_vector (7 downto 0);  -- 7-segment display cathode output
            SSEG_AN : out std_logic_vector (3 downto 0)  -- 7-segment display anode output
        );
    end component;
    FOR ALL : nexys3ssegdriver USE ENTITY WORK.nexys3_sseg_driver (Behavioral);

    component h_sync is
        port (
            clk     : in  std_logic;  -- Clock input
            enable  : in  std_logic;  -- Enable signal
            reset   : in  std_logic;  -- Reset signal
            Tdisp   : out std_logic;  -- Display enable output
            op      : out std_logic;  -- Horizontal sync output
            row     : out std_logic_vector(15 downto 0)  -- Row output
        );
    end component;
    FOR ALL : h_sync USE ENTITY WORK.horizontal_sync (Behavioral);

    component v_sync is
        port (
            clk     : in  std_logic;  -- Clock input
            enable  : in  std_logic;  -- Enable signal
            reset   : in  std_logic;  -- Reset signal
            op      : out std_logic;  -- Vertical sync output
            col     : out std_logic_vector(15 downto 0)  -- Column output
        );
    end component;
    FOR ALL : v_sync USE ENTITY WORK.vertical_sync (Behavioral);

    component controller is
        port (
            clk_60hz    : in  std_logic;  -- 60 Hz clock input
            button      : in  std_logic_vector(4 downto 0);  -- Button input
            switch_stop : in  std_logic;  -- Stop switch input
            pause       : out std_logic;  -- Pause output
            restart     : out std_logic;  -- Restart output
            direction   : out std_logic_vector(1 downto 0)  -- Direction output
        );
    end component;

    signal clk_60hz, clk_25mhz : std_logic;  -- 60 Hz and 25 MHz clock signals
    signal controller_dir      : std_logic_vector(1 downto 0);  -- Direction signal from controller
    signal controller_pause    : std_logic;  -- Pause signal from controller
    signal vga_en              : std_logic;  -- VGA enable signal
    signal vga_row, vga_col    : std_logic_vector(15 downto 0);  -- VGA row and column signals
    signal middlevout          : std_logic;  -- Middle vertical sync signal
    signal middlehout          : std_logic;  -- Middle horizontal sync signal
    signal middle25mhzclk      : std_logic;  -- Middle 25 MHz clock signal
    signal middlerow           : std_logic_vector(15 downto 0);  -- Middle row signal
    signal middlecol           : std_logic_vector(15 downto 0);  -- Middle column signal
    signal inverted_hsync      : std_logic;  -- Inverted horizontal sync signal
    signal middle_tdisp        : std_logic;  -- Middle display enable signal
    signal middle_restart      : std_logic;  -- Middle restart signal
    signal middle_score        : std_logic_vector(15 downto 0);  -- Middle score signal
    signal count_8bit          : std_logic_vector(7 downto 0);  -- 8-bit count signal
    signal bcd_signal          : std_logic_vector(11 downto 0);  -- BCD signal
    signal digit_signal0       : std_logic_vector(6 downto 0);  -- Digit signal 0
    signal digit_signal1       : std_logic_vector(6 downto 0);  -- Digit signal 1
    signal digit_signal2       : std_logic_vector(6 downto 0);  -- Digit signal 2
    signal digit_signal3       : std_logic_vector(6 downto 0);  -- Digit signal 3
    signal bcd_to_sseg         : std_logic_vector(27 downto 0);  -- BCD to 7-segment signal
    signal up_signal           : std_logic;  -- Up signal
    signal down_signal         : std_logic;  -- Down signal
    signal load_signal         : std_logic;  -- Load signal

begin
    MY_binary_to_bcd : binarytobcd port map ( 
        A => count_8bit,  -- Connect binary input
        B => bcd_signal  -- Connect BCD output
    );
    
    Bcd_to_seven_low : bcdtosevensegment port map ( 
        d => bcd_signal(3 downto 0),  -- Connect lower BCD digit
        s => digit_signal0  -- Connect to 7-segment display output for lower digit
    );
    
    Bcd_to_seven_high : bcdtosevensegment port map ( 
        d => bcd_signal(7 downto 4),  -- Connect higher BCD digit
        s => digit_signal1  -- Connect to 7-segment display output for higher digit
    );

    nexys3_sseg_driver_inst : nexys3ssegdriver port map (
        MY_CLK => clk_100mhz,  -- Connect 100 MHz clock
        DIGIT0(7 downto 0) => "11111111",  -- Digit 0 input
        DIGIT1(7 downto 0) => "11111111",  -- Digit 1 input
        DIGIT2(6 downto 0) => digit_signal1(6 downto 0),  -- Digit 2 input
        DIGIT2(7) => '1',  -- MSB of Digit 2
        DIGIT3(6 downto 0) => digit_signal0(6 downto 0),  -- Digit 3 input
        DIGIT3(7) => '1',  -- MSB of Digit 3
        SSEG_CA  => SSEG_CA,  -- Connect to 7-segment display cathode output
        SSEG_AN  => SSEG_AN  -- Connect to 7-segment display anode output
    );

    use_game_logic: game_logic
        port map(
            clk_60hz    => clk_60hz,  -- Connect 60 Hz clock
            direction   => controller_dir,  -- Connect direction signal
            pause       => controller_pause,  -- Connect pause signal
            reset       => reset,  -- Connect reset signal
            restart     => middle_restart,  -- Connect restart signal
            clk_25mhz   => clk_25mhz,  -- Connect 25 MHz clock
            en          => middle_tdisp,  -- Connect display enable signal
            row         => middlerow,  -- Connect row signal
            col         => middlecol,  -- Connect column signal
            score       => count_8bit,  -- Connect score signal
            rout        => rout,  -- Connect red output
            gout        => gout,  -- Connect green output
            bout        => bout  -- Connect blue output
        );

    fdr_inst: f_dvdr
        port map (
            clk         => clk_100mhz,  -- Connect 100 MHz clock
            reset       => reset,  -- Connect reset signal
            divided_clk => clk_25mhz  -- Connect divided clock output
        );

    vsync_inst: v_sync port map (
        clk    => clk_100mhz,  -- Connect 100 MHz clock
        enable => inverted_hsync,  -- Connect inverted horizontal sync
        reset  => reset,  -- Connect reset signal
        col    => middlecol,  -- Connect column output
        op     => middlevout  -- Connect vertical sync output
    );

    hsync_inst: h_sync port map (
        clk    => clk_100mhz,  -- Connect 100 MHz clock
        enable => clk_25mhz,  -- Connect 25 MHz clock
        reset  => reset,  -- Connect reset signal
        Tdisp  => middle_tdisp,  -- Connect display enable signal
        row    => middlerow,  -- Connect row output
        op     => middlehout  -- Connect horizontal sync output
    );

    use_controller: controller
        port map(
            clk_60hz    => clk_60hz,  -- Connect 60 Hz clock
            button      => button,  -- Connect button input
            switch_stop => restart_sw,  -- Connect stop switch
            pause       => controller_pause,  -- Connect pause output
            restart     => middle_restart,  -- Connect restart output
            direction   => controller_dir  -- Connect direction output
        );

    hout <= middlehout;  -- Assign horizontal sync output
    vout <= middlevout;  -- Assign vertical sync output
    inverted_hsync <= not middlehout;  -- Assign inverted horizontal sync
    clk_60hz <= not middlevout;  -- Generate 60 Hz clock from vertical sync
    row <= middlerow;  -- Assign row output
    col <= middlecol;  -- Assign column output
end arch;
