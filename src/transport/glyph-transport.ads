package Glyph.Transport with
  SPARK_Mode => On
is

   type Byte is mod 2 ** 8;
   type Byte_Array is array (Positive range <>) of Byte;

end Glyph.Transport;
