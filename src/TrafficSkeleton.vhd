----------------------------------------------------------------------------------
-- Traffic.vhd
--
-- Toplevel module for the traffic light/intersection controller.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Traffic is port
   ( Reset              : in  std_logic
   ; Clock              : in  std_logic

   -- CPLD board LED
   ; DebugLED           : out std_logic
   
   -- Car/Ped sensors
   ; CarEW              : in  std_logic
   ; CarNS              : in  std_logic
   ; PedEW              : in  std_logic
   ; PedNS              : in  std_logic

   -- Light control
   ; LightsEW           : out std_logic_vector (1 downto 0)
   ; LightsNS           : out std_logic_vector (1 downto 0) );
end Traffic;

architecture Behavioral of Traffic is
   -- Encoding for lights
   constant RED         : std_logic_vector (1 downto 0) := "00";
   constant AMBER       : std_logic_vector (1 downto 0) := "01";
   constant GREEN       : std_logic_vector (1 downto 0) := "10";
   constant WALK        : std_logic_vector (1 downto 0) := "11";
   
   -- State machine
   type StateType       is ( EWAmber, EWTraffic, EWPed, NSAmber, NSTraffic, NSPed );
   signal State         : StateType;
   signal NextState     : StateType;
   
   -- Counter flags
   signal CntPed        : std_logic;
   signal CntAmber      : std_logic;
   signal CntCar        : std_logic;
   signal CntClear      : std_logic;
   signal CntClearNext  : std_logic;
   
   -- NS synchronous inputs
   signal CarNSs        : std_logic;
   signal PedNSHold     : std_logic;
   signal PedNSReset    : std_logic;
   
   -- EW synchronous inputs
   signal CarEWs        : std_logic;
   signal PedEWHold     : std_logic;
   signal PedEWReset    : std_logic;
begin
   DebugLED <= Reset; -- Show reset status on FPGA LED
   
   Timer : entity Counter port map
      ( Clear  => CntClear
      , Clock  => Clock
      , CntPed => CntPed
      , CntAmb => CntAmber
      , CntCar => CntCar );
      
   CarEWDFF : entity DFF port map
      ( Set    => CarEW
      , Clock  => Clock
      , Output => CarEWs );
      
   CarNSDFF : entity DFF port map
      ( Set    => CarNS
      , Clock  => Clock
      , Output => CarNSs );
   
   PedNSSRFF : entity SRFF port map
      ( Set    => PedNS
      , Reset  => PedNSReset
      , Clock  => Clock
      , Output => PedNSHold );
      
   PedEWSRFF : entity SRFF port map
      ( Set    => PedEW
      , Reset  => PedEWReset
      , Clock  => Clock
      , Output => PedEWHold );

   SynchronousProcess:
   process (Reset, Clock)
   begin
      if (Reset = '1') then
         State <= EWTraffic;
         CntClear <= '1';
      elsif (rising_edge(Clock)) then
         State <= NextState;
         CntClear <= CntClearNext;
      end if;
   end process SynchronousProcess;

   CombinatorialProcess:
   process (State, CarEWs, CarNSs, PedEWHold, PedNSHold, CntAmber, CntCar, CntPed)
   begin
      LightsEW <= RED;
      LightsNS <= RED;
      NextState <= State;
      CntClearNext <= '0';
      PedNSReset <= '0';
      PedEWReset <= '0';
      
      case State is
         when EWAmber =>
            LightsEW <= AMBER;
            if (CntAmber = '1') then
               if (PedNSHold = '1') then
                  NextState <= NSPed;
               else
                  NextState <= NSTraffic;
               end if;
            end if;
            
         when EWTraffic =>
            LightsEW <= GREEN;
            if (CntCar = '1') then
               if (PedNSHold = '1' or CarNSs = '1') then
                  NextState <= EWAmber;
                  CntClearNext <= '1';
               elsif (PedEWHold = '1') then
                  NextState <= EWPed;
                  CntClearNext <= '1';
               end if;
            end if;
         
         when EWPed =>
            LightsEW <= WALK;
            if (CntPed = '1') then
               PedEWReset <= '1';
               NextState <= EWTraffic;
            end if;
         
         when NSAmber =>
            LightsNS <= AMBER;
            if (CntAmber = '1') then
               if (PedEWHold = '1') then
                  NextState <= EWPed;
               else
                  NextState <= EWTraffic;
               end if;
            end if;
         
         when NSTraffic =>
            LightsNS <= GREEN;
            if (CntCar = '1') then
               if (PedEWHold = '1' or CarEWs = '1') then
                  NextState <= NSAmber;
                  CntClearNext <= '1';
               elsif (PedNSHold = '1') then
                  NextState <= NSPed;
                  CntClearNext <= '1';
               end if;
            end if;
         
         when NSPed =>
            LightsNS <= WALK;
            if (CntPed = '1') then
               PedNSReset <= '1';
               NextState <= NSTraffic;
            end if;
      end case;
   end process CombinatorialProcess;
end Behavioral;