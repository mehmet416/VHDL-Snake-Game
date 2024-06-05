----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:41:31 04/19/2024 
-- Design Name: 
-- Module Name:    shift_add3 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;

entity InputOutputMapping is
    Port (
        input_data : in  std_logic_vector(3 downto 0);
        output_data : out std_logic_vector(3 downto 0)
    );
end InputOutputMapping;

architecture Behavioral of InputOutputMapping is
begin
    process(input_data)
    begin
        case input_data is
            when "0000" =>
                output_data <= "0000";
            when "0001" =>
                output_data <= "0001";
            when "0010" =>
                output_data <= "0010";
            when "0011" =>
                output_data <= "0011";
            when "0100" =>
                output_data <= "0100";
            when "0101" =>
                output_data <= "1000";
            when "0110" =>
                output_data <= "1001";
            when "0111" =>
                output_data <= "1010";
            when "1000" =>
                output_data <= "1011";
            when "1001" =>
                output_data <= "1100";
            when others =>
                output_data <= "----"; -- Dont care for other cases
        end case;
    end process;
end Behavioral;


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity binary_to_bcd is
    Port (
        A: in  std_logic_vector(7 downto 0);
        B : out std_logic_vector(11 downto 0)
    );
end binary_to_bcd;

architecture Structural of binary_to_bcd is

component InputOutputMapping 
    Port (
        input_data : in STD_LOGIC_VECTOR (3 downto 0);
        output_data : out STD_LOGIC_VECTOR (3 downto 0)    
    );
end component;


signal im_signal: std_logic_vector(87 downto 0); 

begin


shift_add1 : InputOutputMapping port map(
	input_data(0) => A(5),
	input_data(1) => A(6),
	input_data(2) => A(7),
	input_data(3) => '0',
   output_data(0) => im_signal(5),
	output_data(1) => im_signal(6),
	output_data(2) => im_signal(7),
	output_data(3) => im_signal(18)

);
shift_add2 : InputOutputMapping port map(
	input_data(0) => A(4),
	input_data(1) => im_signal(5),
	input_data(2) => im_signal(6),
	input_data(3) => im_signal(7),
   output_data(0) => im_signal(9),
	output_data(1) => im_signal(10),
	output_data(2) => im_signal(11),
	output_data(3) => im_signal(17)

);
shift_add3 : InputOutputMapping port map(
	input_data(0) => A(3),
	input_data(1) => im_signal(9),
	input_data(2) => im_signal(10),
	input_data(3) => im_signal(11),
   output_data(0) => im_signal(13),
	output_data(1) => im_signal(14),
	output_data(2) => im_signal(15),
	output_data(3) => im_signal(16)

);
shift_add4 : InputOutputMapping port map(
	input_data(0) => im_signal(16),
	input_data(1) => im_signal(17),
	input_data(2) => im_signal(18),
	input_data(3) => '0',
   output_data(0) => im_signal(25),
	output_data(1) => im_signal(26),
	output_data(2) => im_signal(27),
	output_data(3) => B(9)

);
shift_add5 : InputOutputMapping port map(
	input_data(0) => A(2),
	input_data(1) => im_signal(13),
	input_data(2) => im_signal(14),
	input_data(3) => im_signal(15),
   output_data(0) => im_signal(21),
	output_data(1) => im_signal(22),
	output_data(2) => im_signal(23),
	output_data(3) => im_signal(24)

);
shift_add6 : InputOutputMapping port map(
	input_data(0) => im_signal(24),
	input_data(1) => im_signal(25),
	input_data(2) => im_signal(26),
	input_data(3) => im_signal(27),
   output_data(0) => B(5),
	output_data(1) => B(6),
	output_data(2) => B(7),
	output_data(3) => B(8)

);
shift_add7 : InputOutputMapping port map(
	input_data(0) => A(1),
	input_data(1) => im_signal(21),
	input_data(2) => im_signal(22),
	input_data(3) => im_signal(23),
   output_data(0) => B(1),
	output_data(1) => B(2),
	output_data(2) => B(3),
	output_data(3) => B(4)

);

B(11) <= '0';
B(10) <= '0';
B(0)  <= A(0);
 
end Structural;