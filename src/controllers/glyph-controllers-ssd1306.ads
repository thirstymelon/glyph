with HAL.I2C;
with Glyph.Transport;

package Glyph.Controllers.SSD1306 with
  SPARK_Mode => Off
is

   Default_I2C_Address : constant HAL.I2C.I2C_Address := 16#3C#;

   type Controller is tagged limited record
      Address     : HAL.I2C.I2C_Address := Default_I2C_Address;
      Initialized : Boolean := False;
   end record;

   procedure Set_Address
     (Self : in out Controller; Address : HAL.I2C.I2C_Address);

   function Get_Address
     (Self : Controller) return HAL.I2C.I2C_Address;

   procedure Initialize
     (Self : in out Controller; Bus : in out HAL.I2C.I2C_Port'Class);

   procedure Flush
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array);

   procedure Set_Address_Window
     (Self       : in out Controller;
      Bus        : in out HAL.I2C.I2C_Port'Class;
      Col_Start  : Natural;
      Col_End    : Natural;
      Page_Start : Natural;
      Page_End   : Natural);

   procedure Write_Data
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array);

end Glyph.Controllers.SSD1306;
