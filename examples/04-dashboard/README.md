# Sensor dashboard

**Placeholder** — This example will demonstrate a realistic embedded application built with Glyph: a sensor monitoring dashboard.

## Planned content

- Reading sensor data (simulated or real via ADC/I2C).
- Displaying numeric values with labels.
- Real-time bar chart visualization.
- Warning indicators and thresholds.
- Menu navigation using input buttons.
- Screen transitions and animation.
- Power management (display sleep/wake).

## Hardware requirements

- Vicharak Shrike-Lite (or any supported RP2040 board).
- SSD1306 128x64 I2C OLED display.
- Optional: sensor modules (temperature, humidity, light sensor).
- Push buttons for user input (navigate menu, acknowledge warnings).

## Building and running

```sh
cd examples/sensor-dashboard
alr build
# Flash the resulting binary to the target board.
```
