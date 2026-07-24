# Text rendering

**Placeholder** — This example will demonstrate Glyph's text rendering capabilities using bitmap fonts.

## Planned content

- Loading and using built-in bitmap fonts (5x7, 8x13, 10x20).
- Drawing text at various positions and sizes.
- Text alignment (left, center, right).
- Text wrapping and line breaking.
- Custom font loading from ROM data.
- Mixed text and shapes on the same canvas.

## Hardware requirements

- Vicharak Shrike-Lite (or any supported RP2040 board).
- SSD1306 128x64 I2C OLED display.

## Building and running

```sh
cd examples/03-text
alr build
# Flash the resulting binary to the target board.
```
