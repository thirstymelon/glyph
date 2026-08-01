# ✦ Glyph

Glyph is a lightweight, portable graphics framework for bare-metal and embedded systems, written in **Ada 2022**.

Designed around deterministic execution, static memory allocation, and a layered architecture, Glyph cleanly separates graphics algorithms, framebuffer management, display controllers, and hardware transports. The project aims to provide a reusable graphics foundation for embedded applications rather than a collection of board-specific display drivers.

Glyph is completely independent of any BSP, HAL, SDK, or RTOS, making it suitable for a wide range of embedded targets.

The initial development platform is the **Vicharak Shrike-Lite (RP2040)** driving an **SSD1306 128×64 OLED display over I²C**. The architecture is intentionally designed to support additional display controllers, transport interfaces, and pixel formats as the framework evolves.

---

# ✦ About the Project

Glyph is both an open-source graphics framework and a personal learning project.

This is my first embedded graphics framework and my first experience implementing display drivers and rendering algorithms from scratch. Rather than assembling existing libraries, I'm intentionally building every layer myself to gain a deeper understanding of:

- Embedded graphics
- Display controller protocols
- Ada framework design
- Bare-metal software architecture

While I'm not looking for code contributions that implement features on my behalf, I greatly appreciate:

- Architecture reviews
- Ada best practices
- Design discussions
- Documentation improvements
- Bug reports
- Constructive feedback

The goal is to learn by building while creating a useful graphics framework for the Ada embedded community.

---

## ✦ Design Principles

Glyph is built around a small set of core principles:

- **Ada 2022** throughout the entire codebase
- **Hardware-independent core** with no BSP, HAL, SDK, or RTOS dependencies
- **Zero dynamic memory allocation** using static memory only
- **Deterministic execution** suitable for bare-metal systems
- **Strong typing** for graphics primitives and geometry
- **Layered architecture** with clear separation of responsibilities
- **Reusable algorithms** independent of display hardware
- **Portable by design** across microcontrollers and display controllers

---

## ✦ Current Status

Glyph has established its core architecture and graphics pipeline, including clipping, rasterization, framebuffer management, and hardware verification on a physical device.

### Completed

- ✅ Core project structure and Alire integration
- ✅ Strong scalar and geometric types (`Point`, `Line`, `Rect`, etc.)
- ✅ Liang–Barsky line clipping algorithm
- ✅ Bresenham integer line rasterization algorithm
- ✅ Abstract transport interface
- ✅ Static framebuffer implementation
- ✅ Canvas drawing API
- ✅ SSD1306 display controller
- ✅ High-level display abstraction
- ✅ Physical hardware verification on RP2040 + SSD1306

### Planned

- ⏳ Rectangle, circle, and ellipse primitives
- ⏳ Bitmap font rendering
- ⏳ Image rendering
- ⏳ Lightweight UI widgets
- ⏳ SPI transport support
- ⏳ Additional display controllers (ST7789, ILI9341)

---

## ✦ Architecture

```text
               +-------------------+
               |    Application    |
               +---------+---------+
                         |
           +-------------+-------------+
           |                           |
           ▼                           ▼
    +--------------+            +--------------+
    |    Canvas    |            |  Controller  |
    +------+-------+            +------+-------+
           |                           |
           ▼                           |
    +--------------+                   |
    | Framebuffer  |<------------------+
    +--------------+                   |
                                       ▼
                               +---------------+
                               |   Transport   |
                               +---------------+
```

The architecture intentionally separates:

- **Algorithms** — clipping and rasterization
- **Canvas** — drawing primitives
- **Framebuffer** — pixel storage
- **Controllers** — display protocols
- **Transport** — hardware communication

For a detailed architectural overview, see **ARCHITECTURE.md**.

---

## ✦ Example

The following example targets a **Vicharak Shrike-Lite (RP2040)** driving a **128×64 SSD1306 OLED** over **I²C**.

```ada
with RP.GPIO;          use RP.GPIO;
with RP.I2C_Master;
with RP.Device;
with RP.Clock;
with Pico;

with Glyph.Types;      use Glyph.Types;
with Glyph.Displays.SSD1306_128x64_I2C;
with Pico_Transport;

procedure Main is

   -- RP2040 I²C0 (Shrike-Lite)
   Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA  : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL  : RP.GPIO.GPIO_Point renames Pico.GP9;

   I2C_Bus :
     aliased Pico_Transport.Pico_I2C_Transport
       (Port_Ptr => Port'Access);

   OLED :
     Glyph.Displays.SSD1306_128x64_I2C.Device
       (Bus => I2C_Bus'Access);

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);

   SDA.Configure (Output, Floating, RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (Output, Floating, RP.GPIO.I2C, Schmitt => True);

   Port.Configure (Baudrate => 400_000);

   OLED.Initialize;

   OLED.Canvas.Clear;

   -- Draw a frame
   OLED.Canvas.Glow_Line (0,   0,   127, 0,   On);
   OLED.Canvas.Glow_Line (127, 0,   127, 63,  On);
   OLED.Canvas.Glow_Line (127, 63,  0,   63,  On);
   OLED.Canvas.Glow_Line (0,   63,  0,   0,   On);

   -- Draw primitives
   OLED.Canvas.Glow_Line (8, 8, 119, 55, On);
   OLED.Canvas.Glow_Pixel (64, 32, On);

   OLED.Render;

   loop
      null;
   end loop;
end Main;
```

---

## ✦ Project Structure

```text
glyph/
├── config/
├── src/
│   ├── algorithms/          -- Pure graphics algorithms
│   │   ├── bresenham/
│   │   ├── liang_barsky/
│   │   └── glyph-algorithms.ads
│   │
│   ├── canvas/              -- Glow_* drawing API
│   │
│   ├── controllers/         -- Display controller implementations
│   │
│   ├── displays/            -- High-level display composites
│   │
│   ├── framebuffer/         -- Static framebuffer implementation
│   │
│   ├── pixel_formats/       -- Pixel and color format definitions
│   │
│   ├── transport/           -- Hardware transport abstraction
│   │
│   ├── glyph.ads
│   └── glyph-types.ads
│
├── tests/
│   └── unit/
│
├── ARCHITECTURE.md
├── README.md
├── alire.toml
└── glyph.gpr
```

---

## ✦ License

Glyph is licensed under the **Apache License 2.0**.
