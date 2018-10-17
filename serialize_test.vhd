library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

use work.SERIALIZE_PKG.all;


package serialize_test_pkg is

   type type_a is record
      a : std_logic_vector(15 downto 0);
      b : std_logic_vector(31 downto 0);
      c : std_logic_vector(7 downto 0);
      d : std_logic_vector(7 downto 0);
   end record type_a;

   constant type_a_width : integer := 64;

   function serialize (input   : type_a) return std_logic_vector;
   function deserialize (input : std_logic_vector) return type_a;



   type type_a_array is array (0 to 3) of type_a;

   constant type_a_array_width : integer := type_a_width*4;


   function serialize (input : type_a_array) return std_logic_vector;

   function deserialize (input : std_logic_vector) return type_a_array;


   type mixed_type is record
      i    : std_logic_vector(3 downto 0);
      j    : std_logic;
      x    : type_a;
      y    : type_a;
      zzzz : type_a_array;
   end record mixed_typ;
   constant mixed_type_width : integer := type_a_array_width+type_a_width*2+1+4;


   function serialize (input : mixed_type) return std_logic_vector;

   function deserialize (input : std_logic_vector) return mixed_type;

end package serialize_test_pkg;

package body serialize_test_pkg is

   function serialize (
         input : type_a)
      return std_logic_vector is
      variable ser : serializer_t(type_a_width-1 downto 0);
      variable r   : std_logic_vector(type_a_width-1 downto 0);
   begin  -- function serialize_detectorCacheLine_t
      serialize_init(ser);
      serialize(ser, input.a);
      serialize(ser, input.b);
      serialize(ser, input.c);
      serialize(ser, input.d);
      r := serialize_get(ser);
      return r;
   end function serialize;


   function deserialize (
         input : std_logic_vector)
      return type_a is
      variable ser : serializer_t(type_a_width-1 downto 0);
      variable r   : type_a;
   begin  -- function serialize_detectorCacheLine_t
      ser := serialize_set(input);
      deserialize(ser, r.a);
      deserialize(ser, r.b);
      deserialize(ser, r.c);
      deserialize(ser, r.d);
      return r;
   end function deserialize;


   function serialize (
         input : type_a_array)
      return std_logic_vector is
      variable ser : serializer_t(type_a_array_width-1 downto 0);
      variable r   : std_logic_vector(type_a_array_width-1 downto 0);
      
   begin  -- function serialize_detectorCacheLine_t
      serialize_init(ser);
      for i in input'range loop
         serialize(ser, serialize(input(i)));
      end loop;  -- i
      r := serialize_get(ser);
      return r;
   end function serialize;


   function deserialize (
         input : std_logic_vector)
      return type_a_array is

      variable ser : serializer_t(type_a_array_width-1 downto 0);
      variable r   : type_a_array;
      variable one : std_logic_vector(type_a_width-1 downto 0);
   begin  -- function serialize_detectorCacheLine_t
      ser := serialize_set(input);
      for i in type_a_array'range loop
         deserialize(ser, one);
         r(i) := deserialize(one);
      end loop;  -- i
      return r;
   end function deserialize;


   function serialize (
         input : mixed_type)
      return std_logic_vector is
      variable ser : serializer_t(mixed_type_width-1 downto 0);
      variable r   : std_logic_vector(mixed_type_width-1 downto 0);
   begin  -- function serialize_detectorCacheLine_t
      serialize_init(ser);
      serialize(ser, input.i);
      serialize(ser, input.j);
      serialize(ser, serialize(input.x));
      serialize(ser, serialize(input.y));
      serialize(ser, serialize(input.zzzz));
      r := serialize_get(ser);
      return r;
   end function serialize;
   
   function deserialize (
         input : std_logic_vector)
      return mixed_type is
      variable ser  : serializer_t(mixed_type_width-1 downto 0);
      variable r    : mixed_type;
      variable onex : std_logic_vector(type_a_width-1 downto 0);
      variable oney : std_logic_vector(type_a_width-1 downto 0);
      variable onez : std_logic_vector(type_a_array_width-1 downto 0);
   begin  -- function serialize_detectorCacheLine_t
      ser    := serialize_set(input);
      deserialize(ser, r.i);
      deserialize(ser, r.j);
      deserialize(ser, onex);
      r.x    := deserialize(onex);
      deserialize(ser, oney);
      r.y    := deserialize(oney);
      deserialize(ser, onez);
      r.zzzz := deserialize(onez);
      return r;
   end function deserialize;

   
end package body serialize_test_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

use work.SERIALIZE_PKG.all;
use work.serialize_test_pkg.all;


entity serialize_test is
   
   port (
         clk              : in  std_logic;
         type_a_in        : in  type_a;
         type_a_out       : out type_a;
         type_a_array_in  : in  type_a_array;
         type_a_array_out : out type_a_array;
         mixed_type_in    : in  mixed_type;
         mixed_type_out   : out mixed_type);


end entity serialize_test;
architecture beh of serialize_test is

   signal type_a_ser       : std_logic_vector(type_a_width-1 downto 0)       := (others => '0');
   signal type_a_array_ser : std_logic_vector(type_a_array_width-1 downto 0) := (others => '0');
   signal mixed_type_ser   : std_logic_vector(mixed_type_width-1 downto 0)   := (others => '0');
begin  -- architecture beh

   process (clk) is
   begin  -- process
      if (clk'event and clk = '1') then  -- rising clock edge
         --serialize
         type_a_ser       <= serialize(type_a_in);
         type_a_array_ser <= serialize(type_a_array_in);
         mixed_type_ser   <= serialize(mixed_type_in);


         --deserialize
         type_a_out       <= deserialize(type_a_ser);
         type_a_array_out <= deserialize(type_a_array_ser);
         mixed_type_out   <= deserialize(mixed_type_ser);

         
      end if;
   end process;

end architecture beh;
