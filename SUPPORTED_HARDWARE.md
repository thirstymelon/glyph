# Supported hardware

This document lists the microcontroller boards and platforms that Glyph targets or supports.

---

## Initial target

The initial development target:

| Component | Model | Interface |
|-----------|-------|-----------|
| Board | Vicharak Shrike-Lite | — |
| MCU | RP2040 (Dual Cortex-M0+) | — |
| Display | SSD1306 128x64 OLED | I2C |

## Planned support

### RP2040 family

| Board | Variant | Status |
|-------|---------|--------|
| Raspberry Pi Pico | RP2040 | Planned |
| Raspberry Pi Pico 2 | RP2350 | Planned |
| Adafruit Feather RP2040 | RP2040 | Planned |
| SparkFun Pro Micro RP2040 | RP2040 | Planned |
| Seeed XIAO RP2040 | RP2040 | Planned |
| Waveshare RP2040 | RP2040 | Planned |
| Vicharak Shrike-Lite | RP2040 | Initial target |
| Custom RP2040 boards | RP2040 | Planned |

### STM32 family

| Board | MCU | Status |
|-------|-----|--------|
| STM32F103 Blue Pill | STM32F103C8T6 | Future |
| STM32F407 Discovery | STM32F407VG | Future |
| STM32H743 Nucleo | STM32H743ZI | Future |
| STM32G0 series | STM32G0x1 | Future |

### ESP32 family

| Board | MCU | Status |
|-------|-----|--------|
| ESP32-DevKitC | ESP32 | Future |
| ESP32-S3-DevKitC | ESP32-S3 | Future |
| ESP32-C3-DevKitM | ESP32-C3 (RISC-V) | Future |

### AVR family

| Board | MCU | Status |
|-------|-----|--------|
| Arduino Uno | ATmega328P | Future |
| Arduino Mega | ATmega2560 | Future |
| Arduino Nano | ATmega328P | Future |

### RISC-V family

| Board | MCU | Status |
|-------|-----|--------|
| ESP32-C3 | ESP32-C3 | Future |
| SiFive HiFive1 | FE310 | Future |

---

## HAL implementation status

| Platform | I2C | SPI | GPIO | Timers | Status |
|----------|-----|-----|------|--------|--------|
| RP2040 (Shrike-Lite) | Planned | N/A | Planned | Planned | v0.2 |
| RP2040 (Pico) | Future | Future | Future | Future | v0.8 |
| STM32 (via HAL) | Future | Future | Future | Future | v2.0 |
| ESP32 | Future | Future | Future | Future | v2.0 |
| AVR | Future | Future | Future | Future | v2.0 |
| RISC-V | Future | Future | Future | Future | v2.0 |

---

## Adding a new board

To add support for a new board:

1. Implement the HAL interface packages for the board's peripherals (I2C, SPI, GPIO, Timers).
2. Create a board-specific configuration package or configuration file.
3. Write a hardware test that verifies communication with a display.
4. Update this document and the CI configuration.

See [ARCHITECTURE.md](ARCHITECTURE.md) and the porting guide in `docs/guides/porting-guide.md` for details.
