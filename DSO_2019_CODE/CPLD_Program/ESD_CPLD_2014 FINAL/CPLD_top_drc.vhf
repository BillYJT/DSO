--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : CPLD_top_drc.vhf
-- /___/   /\     Timestamp : 08/07/2018 13:03:19
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: C:\Xilinx\14.7\ISE_DS\ISE\bin\nt64\unwrapped\sch2hdl.exe -intstyle ise -family xc9500xl -flat -suppress -vhdl CPLD_top_drc.vhf -w "C:/Users/Bryce/Dropbox/University/Year 5/Semester 2/Electronic System Design/20170811 Workshop 3 - Project Introduction/Base Code/ESD_CPLD_2014 FINAL/CPLD_top.sch"
--Design Name: CPLD_top
--Device: xc9500xl
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity CPLD_top is
   port ( EDGE_SW       : in    std_logic; 
          ENABLE        : in    std_logic; 
          FAST_CLK      : in    std_logic; 
          FORCE         : in    std_logic; 
          RAM_FULL      : in    std_logic; 
          RAM_READ_IN   : in    std_logic; 
          SLOW_CLK      : in    std_logic; 
          TRIGGER_IN    : in    std_logic; 
          ADC_CLK       : out   std_logic; 
          CLEAR_COUNT   : out   std_logic; 
          COUNTER_CLK   : out   std_logic; 
          ENABLE_COUNT  : out   std_logic; 
          FILL_COMPLETE : out   std_logic; 
          RAM_READ_OUT  : out   std_logic);
end CPLD_top;

architecture BEHAVIORAL of CPLD_top is
   attribute BOX_TYPE   : string ;
   signal INMUX1              : std_logic;
   signal INMUX2              : std_logic;
   signal READY               : std_logic;
   signal START_FILL          : std_logic;
   signal XLXN_19             : std_logic;
   signal XLXN_47             : std_logic;
   signal XLXN_52             : std_logic;
   signal XLXN_66             : std_logic;
   signal XLXN_69             : std_logic;
   signal XLXN_70             : std_logic;
   signal XLXN_75             : std_logic;
   signal XLXN_81             : std_logic;
   signal RAM_READ_OUT_DUMMY  : std_logic;
   signal FILL_COMPLETE_DUMMY : std_logic;
   component XOR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of XOR2 : component is "BLACK_BOX";
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : component is "BLACK_BOX";
   
   component FDCP
      generic( INIT : bit :=  '0');
      port ( C   : in    std_logic; 
             CLR : in    std_logic; 
             D   : in    std_logic; 
             PRE : in    std_logic; 
             Q   : out   std_logic);
   end component;
   attribute BOX_TYPE of FDCP : component is "BLACK_BOX";
   
   component VCC
      port ( P : out   std_logic);
   end component;
   attribute BOX_TYPE of VCC : component is "BLACK_BOX";
   
   component AND2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of AND2 : component is "BLACK_BOX";
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : component is "BLACK_BOX";
   
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : component is "BLACK_BOX";
   
begin
   FILL_COMPLETE <= FILL_COMPLETE_DUMMY;
   RAM_READ_OUT <= RAM_READ_OUT_DUMMY;
   XLXI_1 : XOR2
      port map (I0=>RAM_READ_IN,
                I1=>START_FILL,
                O=>CLEAR_COUNT);
   
   XLXI_2 : XOR2
      port map (I0=>RAM_READ_IN,
                I1=>FILL_COMPLETE_DUMMY,
                O=>ENABLE_COUNT);
   
   XLXI_7 : INV
      port map (I=>RAM_READ_IN,
                O=>RAM_READ_OUT_DUMMY);
   
   XLXI_16 : FDCP
      port map (C=>ENABLE,
                CLR=>XLXN_19,
                D=>XLXN_69,
                PRE=>XLXN_70,
                Q=>READY);
   
   XLXI_17 : VCC
      port map (P=>XLXN_69);
   
   XLXI_18 : FDCP
      port map (C=>XLXN_47,
                CLR=>XLXN_19,
                D=>READY,
                PRE=>FORCE,
                Q=>START_FILL);
   
   XLXI_23 : INV
      port map (I=>RAM_FULL,
                O=>XLXN_19);
   
   XLXI_45 : XOR2
      port map (I0=>TRIGGER_IN,
                I1=>EDGE_SW,
                O=>XLXN_47);
   
   XLXI_46 : INV
      port map (I=>START_FILL,
                O=>FILL_COMPLETE_DUMMY);
   
   XLXI_47 : AND2
      port map (I0=>FAST_CLK,
                I1=>RAM_READ_OUT_DUMMY,
                O=>INMUX1);
   
   XLXI_48 : AND2
      port map (I0=>RAM_READ_IN,
                I1=>SLOW_CLK,
                O=>INMUX2);
   
   XLXI_49 : OR2
      port map (I0=>INMUX2,
                I1=>INMUX1,
                O=>COUNTER_CLK);
   
   XLXI_50 : OR2
      port map (I0=>FAST_CLK,
                I1=>RAM_READ_IN,
                O=>XLXN_52);
   
   XLXI_51 : OR2
      port map (I0=>XLXN_66,
                I1=>XLXN_52,
                O=>XLXN_81);
   
   XLXI_58 : GND
      port map (G=>XLXN_66);
   
   XLXI_60 : GND
      port map (G=>XLXN_70);
   
   XLXI_64 : INV
      port map (I=>XLXN_81,
                O=>XLXN_75);
   
   XLXI_65 : INV
      port map (I=>XLXN_75,
                O=>ADC_CLK);
   
end BEHAVIORAL;


