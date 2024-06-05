--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : f_dvdr.vhf
-- /___/   /\     Timestamp : 05/09/2024 22:28:23
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl /home/enesk/f_dvdr/f_dvdr.vhf -w /home/enesk/f_dvdr/f_dvdr.sch
--Design Name: f_dvdr
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--
----- CELL CB2CE_HXILINX_f_dvdr -----


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CB2CE_HXILINX_f_dvdr is
  
port (
    CEO  : out STD_LOGIC;
    Q0   : out STD_LOGIC;
    Q1   : out STD_LOGIC;
    TC   : out STD_LOGIC;
    C    : in STD_LOGIC;
    CE   : in STD_LOGIC;
    CLR  : in STD_LOGIC
    );
end CB2CE_HXILINX_f_dvdr;

architecture Behavioral of CB2CE_HXILINX_f_dvdr is

  signal COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
  constant TERMINAL_COUNT : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');
  
begin

process(C, CLR)
begin
  if (CLR='1') then
    COUNT <= (others => '0');
  elsif (C'event and C = '1') then
    if (CE='1') then 
      COUNT <= COUNT+1;
    end if;
  end if;
end process;

TC   <= '1' when (COUNT = TERMINAL_COUNT) else '0';
CEO  <= '1' when ((COUNT = TERMINAL_COUNT) and CE='1') else '0';

Q1 <= COUNT(1);
Q0 <= COUNT(0);

end Behavioral;


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity f_dvdr is
   port ( clk         : in    std_logic; 
          reset       : in    std_logic; 
          divided_clk : out   std_logic);
end f_dvdr;

architecture BEHAVIORAL of f_dvdr is
   attribute BOX_TYPE   : string ;
   attribute HU_SET     : string ;
   signal XLXN_3      : std_logic;
   component VCC
      port ( P : out   std_logic);
   end component;
   attribute BOX_TYPE of VCC : component is "BLACK_BOX";
   
   component CB2CE_HXILINX_f_dvdr
      port ( C   : in    std_logic; 
             CE  : in    std_logic; 
             CLR : in    std_logic; 
             CEO : out   std_logic; 
             Q0  : out   std_logic; 
             Q1  : out   std_logic; 
             TC  : out   std_logic);
   end component;
   
   attribute HU_SET of XLXI_4 : label is "XLXI_4_0";
begin
   XLXI_3 : VCC
      port map (P=>XLXN_3);
   
   XLXI_4 : CB2CE_HXILINX_f_dvdr
      port map (C=>clk,
                CE=>XLXN_3,
                CLR=>reset,
                CEO=>divided_clk,
                Q0=>open,
                Q1=>open,
                TC=>open);
   
end BEHAVIORAL;


