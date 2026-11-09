with Ada.Streams.Stream_IO;
with Interfaces;
with GNAT.OS_Lib;
with Ada.Strings.Fixed;

package body Glyph.Simulator.SPI is

   use Interfaces;
   use type HAL.UInt8;

   procedure Connect_DC
     (This : in out Simulated_SPI_Port; DC : Any_Simulated_GPIO)
   is
   begin
      This.DC_Pin := DC;
   end Connect_DC;

   function Get_Pixel
     (This : Simulated_SPI_Port; X : Natural; Y : Natural) return Glyph.Colors.RGB565
   is
   begin
      if X < Display_Width and then Y < Display_Height then
         return This.GRAM (X, Y);
      else
         return 16#0000#;
      end if;
   end Get_Pixel;

   procedure Clear_Memory (This : in out Simulated_SPI_Port) is
   begin
      This.GRAM := [others => [others => 16#0000#]];
   end Clear_Memory;

   overriding function Data_Size
     (This : Simulated_SPI_Port) return HAL.SPI.SPI_Data_Size
   is
      pragma Unreferenced (This);
   begin
      return HAL.SPI.Data_Size_8b;
   end Data_Size;

   overriding procedure Transmit
     (This    : in out Simulated_SPI_Port;
      Data    : HAL.SPI.SPI_Data_8b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (Timeout);
      Is_Data : Boolean := True;
      Byte_Val : HAL.UInt8;
   begin
      Status := HAL.SPI.Ok;
      This.Transfers_Count := This.Transfers_Count + 1;
      This.Bytes_Received  := This.Bytes_Received + Data'Length;

      if This.DC_Pin /= null then
         Is_Data := This.DC_Pin.Set;
      end if;

      if not Is_Data then
         --  Command byte(s)
         if Data'Length > 0 then
            This.Current_Command := Data (Data'First);
            This.Cmd_Param_Idx   := 0;
            This.Have_High_Byte  := False;

            if This.Current_Command = 16#2C# then
               --  Memory Write start: reset pixel cursor to window top-left
               This.Current_X := This.Col_Start;
               This.Current_Y := This.Row_Start;
            end if;
         end if;
      else
         --  Data bytes for the current command
         for I in Data'Range loop
            Byte_Val := Data (I);

            case This.Current_Command is
               when 16#2A# =>  --  CASET (Column Address Set: 4 bytes)
                  case This.Cmd_Param_Idx is
                     when 0 =>
                        This.Col_Start := Natural (Byte_Val) * 256;
                     when 1 =>
                        This.Col_Start := This.Col_Start + Natural (Byte_Val);
                     when 2 =>
                        This.Col_End   := Natural (Byte_Val) * 256;
                     when 3 =>
                        This.Col_End   := This.Col_End + Natural (Byte_Val);
                        if This.Col_End >= Display_Width then
                           This.Col_End := Display_Width - 1;
                        end if;
                     when others => null;
                  end case;
                  This.Cmd_Param_Idx := This.Cmd_Param_Idx + 1;

               when 16#2B# =>  --  PASET (Page Address Set: 4 bytes)
                  case This.Cmd_Param_Idx is
                     when 0 =>
                        This.Row_Start := Natural (Byte_Val) * 256;
                     when 1 =>
                        This.Row_Start := This.Row_Start + Natural (Byte_Val);
                     when 2 =>
                        This.Row_End   := Natural (Byte_Val) * 256;
                     when 3 =>
                        This.Row_End   := This.Row_End + Natural (Byte_Val);
                        if This.Row_End >= Display_Height then
                           This.Row_End := Display_Height - 1;
                        end if;
                     when others => null;
                  end case;
                  This.Cmd_Param_Idx := This.Cmd_Param_Idx + 1;

               when 16#2C# =>  --  RAMWR (Memory Write: 2 bytes per pixel)
                  if not This.Have_High_Byte then
                     This.High_Byte      := Byte_Val;
                     This.Have_High_Byte := True;
                  else
                     declare
                        Pix_Val : constant Glyph.Colors.RGB565 :=
                          Glyph.Colors.RGB565
                            (Natural (This.High_Byte) * 256 + Natural (Byte_Val));
                     begin
                        if This.Current_X < Display_Width
                          and then This.Current_Y < Display_Height
                        then
                           This.GRAM (This.Current_X, This.Current_Y) := Pix_Val;
                        end if;

                        This.Current_X := This.Current_X + 1;
                        if This.Current_X > This.Col_End then
                           This.Current_X := This.Col_Start;
                           This.Current_Y := This.Current_Y + 1;
                           if This.Current_Y > This.Row_End then
                              This.Current_Y := This.Row_Start;
                           end if;
                        end if;
                     end;
                     This.Have_High_Byte := False;
                  end if;

               when others => null;
            end case;
         end loop;
      end if;
   end Transmit;

   overriding procedure Transmit
     (This    : in out Simulated_SPI_Port;
      Data    : HAL.SPI.SPI_Data_16b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (This, Data, Timeout);
   begin
      Status := HAL.SPI.Ok;
   end Transmit;

   overriding procedure Receive
     (This    : in out Simulated_SPI_Port;
      Data    : out HAL.SPI.SPI_Data_8b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (This, Timeout);
   begin
      Data := [others => 0];
      Status := HAL.SPI.Ok;
   end Receive;

   overriding procedure Receive
     (This    : in out Simulated_SPI_Port;
      Data    : out HAL.SPI.SPI_Data_16b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (This, Timeout);
   begin
      Data := [others => 0];
      Status := HAL.SPI.Ok;
   end Receive;

   overriding function Support
     (This : Simulated_GPIO_Point; Capa : HAL.GPIO.Capability) return Boolean
   is
      pragma Unreferenced (This, Capa);
   begin
      return True;
   end Support;

   overriding function Mode
     (This : Simulated_GPIO_Point) return HAL.GPIO.GPIO_Mode
   is
   begin
      return This.Curr_Mode;
   end Mode;

   overriding procedure Set_Mode
     (This : in out Simulated_GPIO_Point; Mode : HAL.GPIO.GPIO_Config_Mode)
   is
   begin
      This.Curr_Mode := Mode;
   end Set_Mode;

   overriding function Pull_Resistor
     (This : Simulated_GPIO_Point) return HAL.GPIO.GPIO_Pull_Resistor
   is
   begin
      return This.Resistor;
   end Pull_Resistor;

   overriding procedure Set_Pull_Resistor
     (This : in out Simulated_GPIO_Point; Pull : HAL.GPIO.GPIO_Pull_Resistor)
   is
   begin
      This.Resistor := Pull;
   end Set_Pull_Resistor;

   overriding procedure Set (This : in out Simulated_GPIO_Point) is
   begin
      This.State := True;
   end Set;

   overriding procedure Clear (This : in out Simulated_GPIO_Point) is
   begin
      This.State := False;
   end Clear;

   overriding procedure Toggle (This : in out Simulated_GPIO_Point) is
   begin
      This.State := not This.State;
   end Toggle;

   overriding function Set (This : Simulated_GPIO_Point) return Boolean is
   begin
      return This.State;
   end Set;

   function Total_Bytes_Received (This : Simulated_SPI_Port) return Natural is
   begin
      return This.Bytes_Received;
   end Total_Bytes_Received;

   function Total_Transfers_Count (This : Simulated_SPI_Port) return Natural is
   begin
      return This.Transfers_Count;
   end Total_Transfers_Count;

   procedure Reset_Metrics (This : in out Simulated_SPI_Port) is
   begin
      This.Bytes_Received  := 0;
      This.Transfers_Count := 0;
   end Reset_Metrics;

   --  BMP Helper writes
   procedure Write_U16
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Unsigned_16) is
   begin
      Unsigned_8'Write (Stream, Unsigned_8 (Value and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 8) and 16#FF#));
   end Write_U16;

   procedure Write_U32
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Unsigned_32) is
   begin
      Unsigned_8'Write (Stream, Unsigned_8 (Value and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 8) and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 16) and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 24) and 16#FF#));
   end Write_U32;

   procedure Write_I32
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Integer_32) is
   begin
      Write_U32 (Stream, Unsigned_32'Mod (Value));
   end Write_I32;

   procedure Export_BMP
     (Port      : Simulated_SPI_Port;
      File_Path : String;
      Scale     : Positive := 1)
   is
      use Ada.Streams.Stream_IO;

      File       : File_Type;
      Stream     : Stream_Access;
      Out_Width  : constant Positive := Display_Width * Scale;
      Out_Height : constant Positive := Display_Height * Scale;
      Row_Bytes  : constant Natural := Out_Width * 3;
      Padding    : constant Natural := (4 - (Row_Bytes mod 4)) mod 4;
      Image_Size : constant Unsigned_32 :=
        Unsigned_32 ((Row_Bytes + Padding) * Out_Height);
      File_Size  : constant Unsigned_32 := 54 + Image_Size;
      Pad_Byte   : constant Unsigned_8 := 0;
      Pix        : Glyph.Colors.RGB565;
   begin
      Create (File, Out_File, File_Path);
      Stream := Ada.Streams.Stream_IO.Stream (File);

      --  BITMAPFILEHEADER (14 bytes)
      Character'Write (Stream, 'B');
      Character'Write (Stream, 'M');
      Write_U32 (Stream, File_Size);
      Write_U16 (Stream, 0);  --  Reserved 1
      Write_U16 (Stream, 0);  --  Reserved 2
      Write_U32 (Stream, 54); --  Pixel offset

      --  BITMAPINFOHEADER (40 bytes)
      Write_U32 (Stream, 40);                     --  Header size
      Write_I32 (Stream, Integer_32 (Out_Width));  --  Image width
      Write_I32 (Stream, Integer_32 (Out_Height)); --  Image height (bottom-up)
      Write_U16 (Stream, 1);                      --  Color planes
      Write_U16 (Stream, 24);                     --  Bits per pixel
      Write_U32 (Stream, 0);                      --  BI_RGB (no compression)
      Write_U32 (Stream, Image_Size);             --  Image size
      Write_I32 (Stream, 2835);                   --  H resolution (72 DPI)
      Write_I32 (Stream, 2835);                   --  V resolution (72 DPI)
      Write_U32 (Stream, 0);                      --  Colors in palette
      Write_U32 (Stream, 0);                      --  Important colors

      --  Pixel data in bottom-up order (Y from Out_Height - 1 down to 0)
      for Out_Y in reverse 0 .. Out_Height - 1 loop
         declare
            Src_Y : constant Natural := Out_Y / Scale;
         begin
            for Out_X in 0 .. Out_Width - 1 loop
               declare
                  Src_X : constant Natural := Out_X / Scale;
               begin
                  Pix := Port.Get_Pixel (Src_X, Src_Y);
                  --  BMP 24-bit pixel order: Blue, Green, Red
                  Unsigned_8'Write
                    (Stream, Unsigned_8 (Glyph.Colors.Blue_Channel (Pix)));
                  Unsigned_8'Write
                    (Stream, Unsigned_8 (Glyph.Colors.Green_Channel (Pix)));
                  Unsigned_8'Write
                    (Stream, Unsigned_8 (Glyph.Colors.Red_Channel (Pix)));
               end;
            end loop;

            --  Row padding to 4-byte boundary
            for P in 1 .. Padding loop
               Unsigned_8'Write (Stream, Pad_Byte);
            end loop;
         end;
      end loop;

      Close (File);
   end Export_BMP;

   function Find_FFmpeg return String is
      use type GNAT.OS_Lib.String_Access;
      Found : GNAT.OS_Lib.String_Access :=
        GNAT.OS_Lib.Locate_Exec_On_Path ("ffmpeg");
   begin
      if Found /= null then
         declare
            Path : constant String := Found.all;
         begin
            GNAT.OS_Lib.Free (Found);
            return Path;
         end;
      elsif GNAT.OS_Lib.Is_Regular_File ("/opt/homebrew/bin/ffmpeg") then
         return "/opt/homebrew/bin/ffmpeg";
      elsif GNAT.OS_Lib.Is_Regular_File ("/usr/local/bin/ffmpeg") then
         return "/usr/local/bin/ffmpeg";
      elsif GNAT.OS_Lib.Is_Regular_File ("/usr/bin/ffmpeg") then
         return "/usr/bin/ffmpeg";
      else
         return "ffmpeg";
      end if;
   end Find_FFmpeg;

   procedure Export_GIF
     (Port         : Simulated_SPI_Port;
      File_Path    : String;
      Scale        : Positive := 1;
      Duration_Sec : Positive := 2)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP (Port, Tmp_BMP, Scale);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-vf"),
            new String'("split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_GIF;

   procedure Export_Video
     (Port         : Simulated_SPI_Port;
      File_Path    : String;
      Scale        : Positive := 1;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP (Port, Tmp_BMP, Scale);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         FPS_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (FPS), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-framerate"),
            new String'(FPS_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-c:v"),
            new String'("libx264"),
            new String'("-pix_fmt"),
            new String'("yuv420p"),
            new String'("-vf"),
            new String'("pad=ceil(iw/2)*2:ceil(ih/2)*2"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_Video;

end Glyph.Simulator.SPI;
