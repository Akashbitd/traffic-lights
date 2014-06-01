-- Copyright Swinburne (c) 2014
-- Included in assignment files.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- testbench for traffic intersection
--
-- it will be necessary to change the port definitions of the instantiation of
-- the traffic module to match the actual ports used.
-- 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity traffictestbench is
end traffictestbench;

architecture behavior of traffictestbench is 

   -- component declaration for the unit under test (uut)
   component traffic
   port(
      reset     : in std_logic;
      clock     : in std_logic;
      carew     : in std_logic;
      carns     : in std_logic;
      pedew     : in std_logic;
      pedns     : in std_logic;          
      debugled  : out std_logic;
      lightsew  : out std_logic_vector(1 downto 0);
      lightsns  : out std_logic_vector(1 downto 0)
      );
   end component;

   -- inputs
   signal reset :  std_logic := '0';
   signal clock :  std_logic := '0';
   signal carew :  std_logic := '0';
   signal carns :  std_logic := '0';
   signal pedew :  std_logic := '0';
   signal pedns :  std_logic := '0';

   -- outputs
   signal debugled :  std_logic;
   signal lightsew :  std_logic_vector(1 downto 0);
   signal lightsns :  std_logic_vector(1 downto 0);
   
   -- internal
   signal complete : boolean := false;
   signal currenttest : string(1 to 10);

   -- encoding for lights
   constant red   : std_logic_vector(1 downto 0) := "00";
   constant amber : std_logic_vector(1 downto 0) := "01";
   constant green : std_logic_vector(1 downto 0) := "10";
   constant walk  : std_logic_vector(1 downto 0) := "11";

begin

   -- instantiate the unit under test (uut)
   uut: traffic port map(
      reset    => reset,
      clock    => clock,
      debugled => debugled,
      carew    => carew,
      carns    => carns,
      pedew    => pedew,
      pedns    => pedns,
      lightsew => lightsew,
      lightsns => lightsns
   );

   clkprocess:
   process
   begin
      while not complete loop
         clock <= '1'; wait for 500 ns;
         clock <= '0'; wait for 500 ns;
      end loop;
      
      wait;
   end process clkprocess;
   
   
   tb : process
   begin

      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0';

      -- stimulus here
      --==========================================
      
      -- reset circuit
      currenttest <= "reset     ";
      reset <= '1';  wait until rising_edge(clock);
      reset <= '0';  wait until rising_edge(clock);
      
      -- simulation assumes lights start green ns after reset - change if needed
      
      -- lights currently green ns
      -- ew car arrives & waits for the lights to change 
      -- lights should change directly to green ew
      currenttest <= "ew car    ";
      carew <= '1'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ew car arrives
      wait until lightsew = green;
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ew car leaves
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ew
      -- ns car arrives & waits for the lights to change 
      -- lights should change directly to green ns
      currenttest <= "ns car    ";
      carew <= '0'; carns <= '1'; pedew <= '0'; pedns <= '0'; -- ns car arrives
      wait until lightsns = green;
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ns car leaves
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ns
      -- ew pedestrian briefly presses button 
      -- lights should change directly to green+walk ew then green ew
      currenttest <= "ew ped    ";
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '1'; pedns <= '0'; -- ew ped presses button
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ped releases button
      wait until lightsew = walk;
      wait until lightsew = green;
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ew
      -- ew pedestrian briefly presses button 
      -- lights should change directly to green+walk ew then back to green ew
      currenttest <= "ew ped #2 ";
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '1'; pedns <= '0'; -- ew ped presses button
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ped releases button
      wait until lightsew = walk;
      wait until lightsew = green;
      wait for 1 us; -- not a realistic delay but speeds up simulation
      
      -- lights currently green ew
      -- ns pedestrian briefly presses button 
      -- lights should change directly to green+walk ns then to green ns
      currenttest <= "ns ped    ";
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '1'; -- ns ped presses button
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ped releases button
      wait until lightsns = walk;
      wait until lightsns = green;
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ns
      -- ns pedestrian briefly presses button 
      -- lights should change directly to green+walk ns then back to green ns
      currenttest <= "ns ped #2 ";
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '1'; -- ns ped presses button
      wait until falling_edge(clock);
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ped releases button
      wait until lightsns = walk;
      wait until lightsns = green;
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ns
      -- ew & ns cars arrive & wait for the lights to change  
      -- lights should cycle green ew <=> green ns
      currenttest <= "cycling   ";
      carew <= '1'; carns <= '1'; pedew <= '0'; pedns <= '0'; -- ew & ns cars arrives
      for count in 1 to 5 loop
         wait until lightsew = green;
         wait until lightsns = green;
      end loop;
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ew car leaves
      wait for 1 us; -- not a realistic delay but speeds up simulation
            
      -- lights currently green ns
      -- ew & ns peds arrive & wait for the lights to change 
      -- lights should cycle walk+green ew => green ew => walk+green ns => green ns
      currenttest <= "cycling+w ";
      for count in 1 to 5 loop
         carew <= '0'; carns <= '0'; pedew <= '1'; pedns <= '1'; -- ew & ns peds arrives
         wait until falling_edge(clock);
         wait until lightsew = green;
         wait until lightsns = green;
      end loop;
      carew <= '0'; carns <= '0'; pedew <= '0'; pedns <= '0'; -- ew car leaves
      wait for 1 us; -- not a realistic delay but speeds up simulation
      
      complete <= true; -- end simulation
      wait; -- will wait forever
   end process;

end;
