----------------------------------------------------------------------------------
-- DFF.vhd
--
-- D Flip-Flop implementation.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity DFF is port
   ( Clock              : in  std_logic
   ; Set                : in  std_logic
   ; Output             : out std_logic );
end DFF;

architecture Behavioral of DFF is
   signal Q             : std_logic;
begin
   Logic:
   process (Clock)
   begin
      Q <= Q;
      if rising_edge(Clock) then
         Q <= Set;
      end if;
      Output <= Q;
   end process;
end Behavioral;

