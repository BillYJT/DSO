-- Vhdl instantiation template created from schematic C:\Users\Bryce\Dropbox\University\Year 5\Semester 2\Electronic System Design\20170811 Workshop 3 - Project Introduction\Base Code\ESD_CPLD_2014 FINAL\CPLD_top.sch - Tue Aug 07 13:06:56 2018
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module.
-- 2) To use this template to instantiate this component, cut-and-paste and then edit.
--

   COMPONENT CPLD_top
   PORT( ENABLE	:	IN	STD_LOGIC; 
          RAM_FULL	:	IN	STD_LOGIC; 
          RAM_READ_OUT	:	OUT	STD_LOGIC; 
          CLEAR_COUNT	:	OUT	STD_LOGIC; 
          ENABLE_COUNT	:	OUT	STD_LOGIC; 
          FILL_COMPLETE	:	OUT	STD_LOGIC; 
          SLOW_CLK	:	IN	STD_LOGIC; 
          FAST_CLK	:	IN	STD_LOGIC; 
          RAM_READ_IN	:	IN	STD_LOGIC; 
          COUNTER_CLK	:	OUT	STD_LOGIC; 
          ADC_CLK	:	OUT	STD_LOGIC; 
          FORCE	:	IN	STD_LOGIC; 
          EDGE_SW	:	IN	STD_LOGIC; 
          TRIGGER_IN	:	IN	STD_LOGIC);
   END COMPONENT;

   UUT: CPLD_top PORT MAP(
		ENABLE => , 
		RAM_FULL => , 
		RAM_READ_OUT => , 
		CLEAR_COUNT => , 
		ENABLE_COUNT => , 
		FILL_COMPLETE => , 
		SLOW_CLK => , 
		FAST_CLK => , 
		RAM_READ_IN => , 
		COUNTER_CLK => , 
		ADC_CLK => , 
		FORCE => , 
		EDGE_SW => , 
		TRIGGER_IN => 
   );
