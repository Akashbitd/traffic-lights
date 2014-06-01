----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity SRFF is port
   ( Set                : in  std_logic
   ; Reset              : in  std_logic
   ; Clock              : in  std_logic
   ; Output             : out std_logic );
end SRFF;

architecture Behavioral of SRFF is
   signal Q             : std_logic;
begin
   Logic:
   process (Clock, Reset)
   begin
      if Reset = '1' then
         Q <= '0';
      elsif rising_edge(Clock) then
         if Set = '1' then
            Q <= '1';
         end if;
      end if;
      Output <= Q;
   end process;
end Behavioral;

