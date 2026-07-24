# Hello World

**Placeholder** — This example will demonstrate the minimal Glyph application: initializing the library, drawing simple shapes on a display.

## Planned content

- Minimal Glyph project configuration (Alire project file).
- Library initialization with SSD1306 display configuration.
- Drawing basic shapes: a rectangle, a circle, and a line.
- Displaying text using a built-in font.
- Updating the display to show the drawn content.

## Hardware requirements

- Vicharak Shrike-Lite (or any supported RP2040 board).
- SSD1306 128x64 I2C OLED display.
- Wiring: I2C (SDA/SCL) and power connections.

## Building and running

```sh
cd examples/hello-world
alr build
# Flash the resulting binary to the target board.
```
