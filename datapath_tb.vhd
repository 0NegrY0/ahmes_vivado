-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity datapath_tb is
end;

architecture bench of datapath_tb is

  component datapath
      Port (
          clk : in std_logic;
          rst : in std_logic;
          err : out std_logic_vector(0 downto 0)
       );
  end component;

  signal clk: std_logic;
  signal rst: std_logic;
  signal err: std_logic_vector(0 downto 0) ;
  
  -- Clock period definitions
   constant clk_period : time := 10 ns;

begin

  uut: datapath port map ( clk => clk,
                         rst => rst,
                         err => err);

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

  stimulus: process
  begin
  
    wait for 100 ns;
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    
    wait for clk_period * 10;


    -- Put test bench stimulus code here

    wait;
  end process;


end;