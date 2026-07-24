# Testing

This document describes the testing strategy for the Glyph project. Testing is divided into several levels, each serving a specific purpose in validating the library's correctness and performance.

---

## Testing levels

### Unit tests

Unit tests verify individual subprograms and packages in isolation. They run on the host PC and do not require hardware.

**Scope**: Every public subprogram in the core packages (Types, Colors, Framebuffer, Canvas, Drawing, Fonts, Images).

**Requirements**:

- Unit tests must be deterministic.
- Unit tests must not depend on hardware.
- Unit tests must not depend on I/O (except for logging test results).
- Each test should focus on one behaviour.

```ada
--  Example unit test for framebuffer pixel operations.
procedure Test_Set_Pixel
  (T : in out AUnit.Test_Cases.Test_Case'Class)
is
   FB : Framebuffer (Width => 128, Height => 64);
begin
   Set_Pixel (FB, 10, 10, White);
   Assert (Get_Pixel (FB, 10, 10) = White, "Pixel should be white after Set_Pixel");
end Test_Set_Pixel;
```

**Framework**: AUnit (Ada unit testing framework).

**Coverage target**: >= 80% of public subprograms.

### Integration tests

Integration tests verify interactions between packages. They test that the Canvas correctly calls Framebuffer operations, that Drawing primitives produce correct pixel patterns, and that data flows correctly through the rendering pipeline.

**Scope**: Cross-package interactions, rendering pipeline, coordinate transformations, clipping.

**Requirements**:

- Integration tests may use test-only support packages.
- Integration tests may construct complex scenarios (multi-shape scenes, rendered text, blitted images).
- Integration tests should verify visual output against known reference patterns.

```ada
--  Example integration test: Canvas clipping with rectangle drawing.
procedure Test_Clipped_Rectangle
  (T : in out AUnit.Test_Cases.Test_Case'Class)
is
   FB  : Framebuffer (128, 64);
   C   : Canvas (FB);
   Ref : constant Byte_Array := --  Pre-computed reference pixel data.
begin
   C.Set_Clip_Region ((10, 10), (100, 40));
   C.Draw_Rectangle ((5, 5), (120, 50), White, Filled => True);
   --  Only the intersection with the clip region should be drawn.
   Assert (FB.Get_Pixel (8, 8) = Black, "Pixel outside clip region should be black");
   Assert (FB.Get_Pixel (15, 15) = White, "Pixel inside clip region should be white");
end Test_Clipped_Rectangle;
```

### Hardware tests

Hardware tests run on target microcontrollers with actual displays attached. They validate that display drivers correctly communicate with the display controller and produce visible output.

**Scope**: Display drivers, HAL implementations, board-specific backends.

**Requirements**:

- Hardware tests must be clearly documented with wiring diagrams.
- Hardware tests should include visual patterns for manual verification.
- Hardware tests must handle missing hardware gracefully (skip rather than fail).

**Categories**:

1. **Initialization tests**: Verify the display powers on and enters normal operation mode.
2. **Communication tests**: Verify I2C/SPI transactions complete without errors.
3. **Pattern tests**: Display known test patterns and verify them visually or with a light sensor.
4. **Stress tests**: Drive the display at maximum refresh rate for extended periods.

### Simulation tests

The library provides a simulation framebuffer that renders to a host-PC memory buffer instead of a real display. Simulation tests allow running the full application logic without hardware.

**Scope**: End-to-end rendering scenarios, animation sequences, widget interactions.

**Implementation**: A simulation display driver receives framebuffer contents and optionally writes them to a PNG file or displays them in a window.

### Performance benchmarks

Performance benchmarks measure execution time and memory usage of key operations.

**Scope**: All drawing primitives, framebuffer operations, text rendering, image blitting.

**Metrics**:

- Time per operation (microseconds on target hardware).
- Time per frame (complete rendering pipeline).
- Code size (bytes of flash used).
- RAM usage (bytes, peak and average).
- I2C/SPI bus utilization (bytes transferred per frame).

**Implementation**: Benchmarks are in `tests/benchmarks/` and use the `GNAT.Benchmark` timing facilities or hardware timers.

---

## Test organization

```
tests/
  unit/
    glyph-types_tests.ads
    glyph-types_tests.adb
    glyph-colors_tests.ads
    glyph-colors_tests.adb
    glyph-framebuffer-mono_tests.ads
    glyph-framebuffer-mono_tests.adb
    glyph-drawing_tests.ads
    glyph-drawing_tests.adb
    ...
  integration/
    glyph-rendering-pipeline_tests.ads
    glyph-rendering-pipeline_tests.adb
    glyph-canvas-clipping_tests.ads
    glyph-canvas-clipping_tests.adb
    ...
  benchmarks/
    framebuffer_benchmark.adb
    drawing_benchmark.adb
    text_benchmark.adb
    ...
```

Test file names mirror source file names with a `_tests` suffix.

---

## Test framework

Glyph uses **AUnit** as the primary test framework. AUnit is the Ada equivalent of JUnit and is included in the GNAT distribution.

```ada
with AUnit.Test_Cases;
with AUnit.Test_Suites;

package Glyph.Framebuffer.Mono_Tests is

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

end Glyph.Framebuffer.Mono_Tests;
```

---

## Writing tests

### Test structure

Each test procedure should follow the Arrange-Act-Assert pattern:

```ada
procedure Test_Fill_Buffer
  (T : in out AUnit.Test_Cases.Test_Case'Class)
is
   FB : Framebuffer (128, 64);  --  Arrange
begin
   Fill (FB, White);            --  Act
   Assert (FB.Get_Pixel (0, 0) = White, "Pixel should be white after fill");  --  Assert
   Assert (FB.Get_Pixel (127, 63) = White, "Last pixel should also be white");
end Test_Fill_Buffer;
```

### Test naming

Test procedure names should describe the behaviour being tested:

- `Test_Draw_Line_Horizontal`
- `Test_Draw_Line_Vertical`
- `Test_Draw_Line_Diagonal`
- `Test_Draw_Line_Clipped_Both_Ends`
- `Test_Draw_Line_Width_Zero` (boundary case)

### Test coverage

- Every public subprogram must have at least one happy-path test.
- Boundary conditions must be tested: minimum, maximum, and out-of-range values.
- Empty/null scenarios must be tested: zero-length line, zero-size rectangle.
- Side effects must be tested: verifying that a subprogram modifies the intended state without modifying other state.

---

## CI integration

All tests run as part of the CI pipeline on every push and pull request.

- Unit tests run on the host PC using the native GNAT compiler.
- Integration tests run on the host PC.
- Hardware tests run on a schedule or on demand (not on every push).
- Benchmarks run on demand and results are compared against previous runs.

---

## Regression tests

When a bug is fixed, a regression test must be added to verify:

1. The bug no longer occurs.
2. The fix does not break any existing behaviour.
3. The exact scenario that revealed the bug is captured.

```ada
--  Regression test for issue #42: Draw_Line with X1 > X2 produced incorrect output.
procedure Test_Regression_Issue_042
  (T : in out AUnit.Test_Cases.Test_Case'Class)
is
   FB : Framebuffer (128, 64);
begin
   Draw_Line (FB, X1 => 100, Y1 => 10, X2 => 50, Y2 => 30, Color => White);
   --  Verify pixels along the line from (50,30) to (100,10).
   Assert (FB.Get_Pixel (75, 20) = White, "Midpoint of reversed line should be white");
end Test_Regression_Issue_042;
```

---

## Continuous integration testing

The CI pipeline defined in `.github/workflows/ci.yml` runs:

1. **Build check**: Verify the project compiles without errors.
2. **Unit tests**: Run all unit tests and report failures.
3. **Integration tests**: Run all integration tests.
4. **Coding standard check**: Verify code formatting with pre-commit hooks.
5. **Coverity scan** (scheduled): Static analysis for potential defects.

See the CI workflow files in `.github/workflows/` for the current configuration.
