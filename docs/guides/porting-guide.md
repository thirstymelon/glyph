# Porting guide

**Placeholder** — This document will describe how to port Glyph to new hardware platforms.

## Planned content

- Overview of what needs to be ported for a new platform.
- HAL interface implementations:
  - I2C bus abstraction.
  - SPI bus abstraction.
  - GPIO abstraction.
  - Timer abstraction.
- Board-specific configuration.
- Creating a board support package.
- Testing the port (unit tests, communication tests, display tests).
- Common pitfalls and troubleshooting.
- Porting checklist.
- Example: Porting to a new RP2040 board.
- Example: Porting to an STM32 board.
- Example: Porting to an ESP32 board.
