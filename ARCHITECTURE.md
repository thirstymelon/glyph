# ✦ Glyph Architecture Specification (v2.1)

**Target Hardware:** Bare-metal Embedded (RP2040 / Vicharak Shrike-Lite initial target)  
**Primary Display:** SSD1306 128x64 OLED (I2C)  
**Language Standard:** Ada 2022 (`-gnat2022`)  
**Memory Model:** 100% Static / Stack Allocation (Zero Dynamic Memory Allocation)  

---

# ✦ Architecture Overview & System Boundaries

Glyph is designed around three strict architectural boundaries:

```text
+-----------------------------------------------------------------------+
|                         APPLICATION / FIRMWARE                        |
|                                                                       |
|  Creates Transport Bridge:  Connects Pico_BSP.I2C -> Glyph.Transport  |
|  Instantiates Display:      OLED : Display.SSD1306.Device_128x64_I2C  |
|  Executes Drawing & Render: OLED.Canvas.Draw_Line(...); OLED.Render;  |
+-----------------------------------++----------------------------------+
                                    ||
           Uses Graphics API        || Implements Transport Interface
                                    || (Calls Pico_BSP.I2C.Write)
                                    \/
+-----------------------------------------------------------------------+
|                           GLYPH FRAMEWORK                             |
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | Displays (High-level bundle: Canvas + Framebuffer + Controller) |  |
|  +--------------------------------+--------------------------------+  |
|                                   |                                   |
|        +--------------------------+--------------------------+        |
|        |                                                     |        |
|        ▼                                                     ▼        |
|  +-----------+                                       +---------------+  |
|  |  Canvas   | (Drawing algorithms)                  |  Controller   |  |
|  +-----+-----+                                       +-------+-------+  |
|        |                                                     |        |
|        | (Mutates pixels)                                    | (Reads)|
|        ▼                                                     ▼        |
|  +-----------------------------------------------------------------+  |
|  |                   Framebuffer (Static 2D Array)                 |  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  Dependencies: ZERO (No BSP, No HAL, No RTOS, No System.Memory)       |
+-----------------------------------------------------------------------+
```

### Architectural Principles:
1. **Zero Coupling to BSP:** Glyph has **no knowledge** of `Pico_BSP`, Pico SDK, or RP2040 registers. `Pico_BSP` has **no knowledge** of Glyph.
2. **Firmware Glue:** The Application / Firmware implements `Glyph.Transports.Transport` using `Pico_BSP.I2C` and wires it to Glyph.
3. **Developer Ergonomics:** The application controls the display through a clean, unified object API:
   ```ada
   OLED.Canvas.Draw_Rectangle (10, 10, 50, 30, On);
   OLED.Canvas.Draw_Line (0, 0, 127, 63, On);
   OLED.Render;
   ```

---

# ✦ Package Hierarchy & Responsibilities

```text
Glyph
├── Glyph.Types             -- Strong scalar range types, Points, Rectangles, Colors
├── Glyph.Transports        -- Abstract interface for I2C / SPI communication
├── Glyph.Pixel_Formats     -- Color & bit-format definitions (Monochrome 1bpp)
├── Glyph.Framebuffers      -- Generic static pixel buffer storage & pixel mapping
├── Glyph.Canvas            -- Hardware-agnostic drawing primitives (Lines, Rectangles, Text)
├── Glyph.Controllers       -- Base Controller interfaces & Command protocols
│   └── Glyph.Controllers.SSD1306 -- SSD1306 init sequences, page-mode frame encoding
└── Glyph.Displays          -- High-level composite types bundling Canvas + Controller
    └── Glyph.Displays.SSD1306  -- Ready-to-use SSD1306 128x64 display instance
```

---

# ✦ Layer Detailed Specifications

## 1. `Glyph.Types`
Provides strong Ada scalar types and geometric data structures. Standard `Integer` aliases are avoided to enforce compile-time parameter safety.

```ada
package Glyph.Types is

   type Coordinate is range -32_768 .. 32_767;
   type Dimension  is range 0 .. 32_767;

   type Point is record
      X : Coordinate;
      Y : Coordinate;
   end record;

   type Rect is record
      X      : Coordinate;
      Y      : Coordinate;
      Width  : Dimension;
      Height : Dimension;
   end record;

   type Pixel_Color is (Off, On, Invert);

   type Byte is mod 2 ** 8;
   for Byte'Size use 8;

   type Byte_Array is array (Positive range <>) of Byte;
   pragma Pack (Byte_Array);

end Glyph.Types;
```

---

## 2. `Glyph.Transports`
Provides the hardware-agnostic communication interface. `Data_Kind` allows display drivers to cleanly transmit commands vs pixel data over I2C (control bytes `0x00`/`0x40`) or SPI (D/C GPIO pin toggles).

```ada
with Glyph.Types;

package Glyph.Transports is

   type Data_Kind is (Command, Pixel_Data);

   type Transport is limited interface;

   procedure Send
     (Self : in out Transport;
      Kind : Data_Kind;
      Data : Glyph.Types.Byte_Array) is abstract;

   procedure Reset (Self : in out Transport) is abstract;

end Glyph.Transports;
```

---

## 3. `Glyph.Framebuffers`
Provides generic static pixel storage. For SSD1306, pixels are arranged in **Vertical Page Mode** (1 byte = 8 vertical pixels), eliminating CPU overhead during display rendering.

```ada
generic
   Width  : Glyph.Types.Dimension;
   Height : Glyph.Types.Dimension;
package Glyph.Framebuffers is

   Buffer_Size : constant Natural := (Natural (Width) * Natural (Height)) / 8;

   type Pixel_Buffer is array (1 .. Buffer_Size) of Glyph.Types.Byte;
   pragma Pack (Pixel_Buffer);

   type Framebuffer is tagged limited record
      Data : Pixel_Buffer := (others => 0);
   end record;

   procedure Clear (Self : in out Framebuffer);

   procedure Set_Pixel
     (Self  : in out Framebuffer;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color);

end Glyph.Framebuffers;
```

---

## 4. `Glyph.Canvas`
Provides drawing algorithms (Bresenham lines, rectangles, circles, clipping). `Canvas` holds an access discriminant to a `Framebuffer`.

```ada
generic
   with package FB is new Glyph.Framebuffers (<>);
package Glyph.Canvas is

   type Drawing_Canvas (Buffer : access FB.Framebuffer) is tagged limited record
      Clip_Min_X : Glyph.Types.Coordinate := 0;
      Clip_Min_Y : Glyph.Types.Coordinate := 0;
      Clip_Max_X : Glyph.Types.Coordinate := FB.Width - 1;
      Clip_Max_Y : Glyph.Types.Coordinate := FB.Height - 1;
   end record;

   procedure Clear (Self : in out Drawing_Canvas);

   procedure Draw_Pixel
     (Self  : in out Drawing_Canvas;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color);

   procedure Draw_Line
     (Self  : in out Drawing_Canvas;
      X0, Y0, X1, Y1 : Glyph.Types.Coordinate;
      Color          : Glyph.Types.Pixel_Color);

   procedure Draw_Rectangle
     (Self   : in out Drawing_Canvas;
      X, Y   : Glyph.Types.Coordinate;
      W, H   : Glyph.Types.Dimension;
      Color  : Glyph.Types.Pixel_Color;
      Filled : Boolean := False);

end Glyph.Canvas;
```

---

## 5. `Glyph.Controllers.SSD1306`
Manages display initialization, power states, and page-mode data flushing.

```ada
with Glyph.Transports;
with Glyph.Framebuffers;

package Glyph.Controllers.SSD1306 is

   generic
      with package FB is new Glyph.Framebuffers (<>);
   package Driver is
      type Controller (Bus : access Glyph.Transports.Transport'Class) is tagged limited null record;

      procedure Initialize (Self : in out Controller);
      procedure Flush (Self : in out Controller; Buffer : FB.Framebuffer);
      procedure Set_Contrast (Self : in out Controller; Contrast : Glyph.Types.Byte);
   end Driver;

end Glyph.Controllers.SSD1306;
```

---

## 6. `Glyph.Displays` (Developer Composite API)
Bundles `Framebuffer`, `Canvas`, and `Controller` into a single object so the application firmware enjoys intuitive dot-syntax (`OLED.Canvas.Draw_Line(...)` and `OLED.Render`).

```ada
with Glyph.Transports;
with Glyph.Framebuffers;
with Glyph.Canvas;
with Glyph.Controllers.SSD1306;

package Glyph.Displays.SSD1306_128x64_I2C is

   package FB_128x64 is new Glyph.Framebuffers (Width => 128, Height => 64);
   package Canvas_128x64 is new Glyph.Canvas (FB => FB_128x64);
   package Controller_128x64 is new Glyph.Controllers.SSD1306.Driver (FB => FB_128x64);

   type Device (Bus : access Glyph.Transports.Transport'Class) is tagged limited record
      Buffer     : aliased FB_128x64.Framebuffer;
      Canvas     : Canvas_128x64.Drawing_Canvas (Buffer => Buffer'Access);
      Controller : Controller_128x64.Controller (Bus => Bus);
   end record;

   procedure Initialize (Self : in out Device);
   procedure Render (Self : in out Device);

end Glyph.Displays.SSD1306_128x64_I2C;
```

---

# ✦ Firmware Integration Example (The Glue Code)

Below is how an application on RP2040 (Vicharak Shrike-Lite) glues `Pico_BSP` and `Glyph` together:

```ada
with Pico_BSP.I2C;
with Glyph.Transports;
with Glyph.Displays.SSD1306_128x64_I2C;
with Glyph.Types; use Glyph.Types;

procedure Main is

   -- 1. Create a Transport implementation wrapping Pico_BSP's I2C peripheral
   type Pico_I2C_Transport is new Glyph.Transports.Transport with record
      Bus_Id : Pico_BSP.I2C.I2C_Peripheral_Id := Pico_BSP.I2C.I2C_0;
      Addr   : Glyph.Types.Byte := 16#3C#; -- Default SSD1306 I2C Address
   end record;

   overriding
   procedure Send
     (Self : in out Pico_I2C_Transport;
      Kind : Glyph.Transports.Data_Kind;
      Data : Glyph.Types.Byte_Array) is
   begin
      -- Translate Kind into SSD1306 I2C Prefix:
      -- 16#00# for Command, 16#40# for Control/Data
      case Kind is
         when Glyph.Transports.Command   => Pico_BSP.I2C.Write_Prefix (Self.Bus_Id, Self.Addr, 16#00#, Data);
         when Glyph.Transports.Pixel_Data => Pico_BSP.I2C.Write_Prefix (Self.Bus_Id, Self.Addr, 16#40#, Data);
      end case;
   end Send;

   overriding
   procedure Reset (Self : in out Pico_I2C_Transport) is
   begin
      null; -- I2C OLED displays standard reset via software command
   end Reset;

   -- 2. Instantiate the Transport and Display objects statically
   I2C_Bus : aliased Pico_I2C_Transport;
   OLED    : Glyph.Displays.SSD1306_128x64_I2C.Device (Bus => I2C_Bus'Access);

begin
   -- Initialize Hardware & Display
   Pico_BSP.I2C.Initialize (I2C_Bus.Bus_Id);
   OLED.Initialize;

   -- Drawing graphics using dot-notation!
   OLED.Canvas.Clear;
   OLED.Canvas.Draw_Rectangle (X => 10, Y => 10, W => 50, H => 30, Color => On);
   OLED.Canvas.Draw_Line (X0 => 0, Y0 => 0, X1 => 127, Y1 => 63, Color => On);

   -- Flush drawing buffer to SSD1306 OLED hardware
   OLED.Render;

end Main;
```

---

# ✦ Architectural Compliance Checklist

When adding new packages or features to Glyph, ensure:
1. **No `Pico_BSP` or HAL imports in `Glyph` packages.**
2. **No dynamic allocation (`Ada.Unchecked_Deallocation`, `new`) anywhere.**
3. **All memory structures statically dimensioned via generics.**
4. **Drawing procedures handle off-screen clipping safely.**
