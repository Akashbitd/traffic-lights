----------------------------------------------------------------------------------
-- Counter.vhd
--
-- An event timer based on a counter with thresholds.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Counter is port
   ( Clear              : in  std_logic
   ; Clock              : in  std_logic
   
   -- Count threshold outputs
   ; CntPed             : out std_logic
   ; CntAmb             : out std_logic
   ; CntCar             : out   std_logic );
end Counter;

architecture Behavioral of Counter is
   signal Count         : natural range 0 to 10000;
begin
   Counter:
   process (Clear, Clock)
   begin
      if (Clear = '1') then
         Count <= 0;
      elsif (rising_edge(Clock)) then
         Count <= Count + 1;
      end if;
   end process;
   
   Flags:
   process (Count)
   begin
      CntPed <= '0';
      CntAmb <= '0';
      CntCar <= '0';
      -- Pedestrian time threshold
      if (Count > 450) then
         CntPed <= '1';
      end if;
      -- Amber time threshold
      if (Count > 150) then
         CntAmb <= '1';
      end if;
      -- Traffic time threshold
      if (Count > 600) then
         CntCar <= '1';
      end if;
   end process;
end Behavioral;

