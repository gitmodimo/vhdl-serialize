-------------------------------------------------------------------------------
-- Title      : SERIALIZER_PKG
-- Project    : 
-------------------------------------------------------------------------------
-- File       : SERIALIZE_PKG.vhd
-- Author     : Rafal H 
-- Created    : 16:49:41 16-10-2018
-- Last update: 10:37:35 17-10-2018
-- Platform   : Vivado
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Provides simple serialization mechanism
-------------------------------------------------------------------------------
--
--    This library is free software; you can redistribute it and/or
--    modify it under the terms of the GNU Lesser General Public
--    License as published by the Free Software Foundation; either
--    version 2.1 of the License, or (at your option) any later version.

--    This library is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--    Lesser General Public License for more details.

--    You should have received a copy of the GNU Lesser General Public
--    License along with this library; if not, write to the Free Software
--    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
package SERIALIZE_PKG is


   type serializer_bit_t is record
      serbit : std_logic;
      used   : boolean;
   end record serializer_bit_t;

   type serializer_t is array (integer range <>) of serializer_bit_t;



   procedure serialize_init (variable SER : out serializer_t);

   procedure serialize (variable SER : inout serializer_t; ADD : in std_logic_vector);

   procedure serialize (variable SER : inout serializer_t; ADD : in std_logic);

   procedure deserialize (variable SER : inout serializer_t; variable GET : out std_logic_vector);

   procedure deserialize (variable SER : inout serializer_t; variable GET : out std_logic);

   procedure deserialize_sig (variable SER : inout serializer_t; signal GET : out std_logic_vector);

   procedure deserialize_sig (variable SER : inout serializer_t; signal GET : out std_logic);

   function serialize_get (SER : serializer_t) return std_logic_vector;

   function serialize_set (SER : in std_logic_vector) return serializer_t;


end package SERIALIZE_PKG;

package body SERIALIZE_PKG is

   procedure serialize_init (
         variable SER : out serializer_t) is
      variable s : serializer_t(SER'range);
   begin  -- function serialize
      for i in SER'range loop
         SER(i).serbit := '0';
         SER(i).used   := false;
      end loop;  -- i      
   end procedure serialize_init;

   procedure serialize (
         variable SER : inout serializer_t;
         ADD          : in    std_logic_vector) is
      variable bitidx : integer := 0;
   begin  -- procedure serialize      
      bitidx := ADD'low;
      for i in SER'low to SER'high loop
         if (SER(i).used = false and bitidx <= ADD'high) then
            SER(i).used   := true;
            SER(i).serbit := add(bitidx);
            bitidx        := bitidx+1;
         end if;
      end loop;  -- i
   end procedure serialize;


   procedure serialize (
         variable SER : inout serializer_t;
         ADD          : in    std_logic) is
      variable bitidx : integer := 0;
   begin  -- procedure serialize      
      bitidx := 0;
      for i in SER'low to SER'high loop
         if (SER(i).used = false and bitidx <= 0) then
            SER(i).used   := true;
            SER(i).serbit := add;
            bitidx        := bitidx+1;
         end if;
      end loop;  -- i
   end procedure serialize;

   procedure deserialize (
         variable SER : inout serializer_t;
         variable GET : out   std_logic_vector) is
      variable bitidx : integer := 0;
   begin  -- procedure serialize      
      bitidx := GET'low;
      for i in SER'low to SER'high loop
         if (SER(i).used = true and bitidx <= GET'high) then
            SER(i).used := false;
            GET(bitidx) := SER(i).serbit;
            bitidx      := bitidx+1;
         end if;
      end loop;  -- i
   end procedure deserialize;


   procedure deserialize (
         variable SER : inout serializer_t;
         variable GET : out   std_logic) is
      variable bitidx : integer := 0;
   begin  -- procedure serialize      
      bitidx := 0;
      for i in SER'low to SER'high loop
         if (SER(i).used = true and bitidx <= 0) then
            SER(i).used := false;
            GET         := SER(i).serbit;
            bitidx      := bitidx+1;
         end if;
      end loop;  -- i
   end procedure deserialize;
   
   procedure deserialize_sig (
         variable SER : inout serializer_t;
         signal GET   : out   std_logic_vector) is
      variable GET_V : std_logic_vector(GET'range);
   begin  -- procedure serialize      
      deserialize(SER, GET_V);
      GET <= GET_V;
   end procedure deserialize_sig;
   
   procedure deserialize_sig (
         variable SER : inout serializer_t;
         signal GET   : out   std_logic) is
      variable GET_V : std_logic;
   begin  -- procedure serialize      
      deserialize(SER, GET_V);
      GET <= GET_V;
   end procedure deserialize_sig;

   function serialize_get (
         SER : serializer_t)
      return std_logic_vector is
      variable s : std_logic_vector(SER'range);
   begin  -- function serialize
      for i in SER'range loop
         s(i) := SER(i).serbit;
      end loop;  -- i      
      return s;
   end function serialize_get;

   function serialize_set (
         SER : in std_logic_vector)
      return serializer_t is
      variable s : serializer_t(SER'range);
   begin  -- function serialize
      for i in SER'range loop
         s(i).serbit := SER(i);
         s(i).used   := true;
      end loop;  -- i      
      return s;
   end function serialize_set;


end package body SERIALIZE_PKG;
