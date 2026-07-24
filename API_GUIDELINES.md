# API guidelines

This document defines the principles and conventions for designing public APIs in the Glyph project. All new API surfaces must conform to these guidelines.

---

## Principles

### 1. Consistency

Related operations must have consistent naming, parameter ordering, and behaviour across the entire library. If `Draw_Line` takes `(Buffer, X1, Y1, X2, Y2)` then `Draw_Rectangle` should take `(Buffer, X, Y, Width, Height)` following the same parameter style.

### 2. Minimal public surface

Expose only what users need. Everything else is private. A smaller API surface is easier to learn, document, test, and maintain.

```ada
--  Good: Minimal public surface.
package Glyph.Framebuffer is
   procedure Clear (FB : in out Framebuffer);
   procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
private
   --  Implementation details hidden.
end Glyph.Framebuffer;

--  Bad: Exposing internal helper subprograms.
package Glyph.Framebuffer is
   procedure Clear (FB : in out Framebuffer);
   procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
   procedure Internal_Validate_Coordinates (FB : Framebuffer; X, Y : Coordinate); --  Should be private.
   function Internal_Compute_Index (FB : Framebuffer; X, Y : Coordinate) return Natural; --  Should be private.
private
   --  ...
end Glyph.Framebuffer;
```

### 3. Information hiding

Users must not depend on internal types, constants, or subprograms. The private part of a package specification must be considered internal and subject to change without notice.

### 4. Backward compatibility

Public APIs must maintain backward compatibility within a major version. Changes that break backward compatibility must be reserved for major version bumps (v1.x -> v2.x).

### 5. Fail early, fail loud

Validate all parameters at the API boundary. Use preconditions, subtype constraints, and explicit checks to catch invalid inputs as early as possible.

```ada
--  Good: Parameter validation at the API boundary.
procedure Draw_Pixel
  (FB : in out Framebuffer;
   X, Y : Coordinate;
   C : Pixel)
   with Pre => X < FB.Width and then Y < FB.Height;
```

### 6. Predictable defaults

Where a subprogram has common usage patterns, provide sensible defaults through default parameter values.

```ada
--  Good: Default fill mode to False (outline only).
procedure Draw_Rectangle
  (FB     : in out Framebuffer;
   X, Y   : Coordinate;
   W, H   : Positive;
   C      : Pixel;
   Filled : Boolean := False);
```

---

## API design conventions

### Parameter ordering

Follow a consistent left-to-right ordering:

1. The primary object being operated on (e.g., `Buffer`).
2. Positional parameters (coordinates, dimensions).
3. Styling parameters (colour, line width).
4. Behavioural flags (booleans, enumeration options).
5. Default parameters at the end.

```ada
procedure Draw_Line
  (Buffer    : in out Framebuffer;
   X1, Y1    : Coordinate;  -- Start position
   X2, Y2    : Coordinate;  -- End position
   Color     : Pixel;       -- Style
   Line_Width : Width := 1);  -- Optional style
```

### Naming

- Procedures use imperative verbs: `Draw`, `Clear`, `Fill`, `Init`, `Update`.
- Functions use descriptive nouns or queries: `Get_Pixel`, `Is_Visible`, `Width`.
- Boolean-returning functions use `Is_`, `Has_`, `Can_` prefixes.
- Type names describe what the type represents: `Framebuffer`, `Coordinate`, `Pixel_Format`.

### Subprogram length

Subprograms should do one thing. If a subprogram is longer than 30 lines, consider splitting it.

### Function vs procedure

- Use a function when the operation computes a value without side effects on parameters (except `out` parameters where functions are not applicable).
- Use a procedure when the operation primarily modifies state.

```ada
--  Function: computes a value.
function Get_Pixel (FB : Framebuffer; X, Y : Coordinate) return Pixel;

--  Procedure: modifies state.
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Pixel);
```

### Error handling

- Use subtypes and constraints to prevent invalid states at compile time.
- Use preconditions to document and enforce valid input ranges.
- Return status codes (enumerated types) for expected failure modes (I2C errors, SPI errors).
- Raise exceptions only for unexpected, unrecoverable conditions.

```ada
type Transfer_Status is (Success, Bus_Error, Timeout);

function I2C_Write (Address : HAL.I2C.Address; Data : Byte_Array) return Transfer_Status;
```

### Overloading

Overloading should be used sparingly and only when the parameter types make the intended subprogram unambiguous. Prefer distinct names when overloading might confuse users.

```ada
--  Acceptable overloading: same operation, different input types.
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : Mono_Pixel);
procedure Draw_Pixel (FB : in out Framebuffer; X, Y : Coordinate; C : RGB565_Pixel);

--  Prefer distinct names when operations are different.
--  Good:
procedure Draw_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
procedure Draw_Horizontal_Line (FB : in out Framebuffer; X, Y, Length : Coordinate; C : Pixel);

--  Bad: Confusing overloading.
procedure Draw_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
procedure Draw_Line (FB : in out Framebuffer; X, Y, Length : Coordinate; C : Pixel; Horizontal : Boolean);
```

---

## Documentation

### Every public subprogram must be documented

```ada
--  Draw a line between two points.
--  FB     - The framebuffer to draw on.
--  X1, Y1 - Starting pixel coordinates.
--  X2, Y2 - Ending pixel coordinates.
--  Color  - The pixel colour value.
--  Raises Constraint_Error if any coordinate is out of bounds.
procedure Draw_Line
  (FB    : in out Framebuffer;
   X1, Y1 : Coordinate;
   X2, Y2 : Coordinate;
   Color  : Pixel);
```

### Document preconditions explicitly

```ada
--  Set a pixel to the specified colour.
--  The coordinates (X, Y) must be within the framebuffer bounds.
--  Callers should verify bounds via FB.Width and FB.Height if needed.
procedure Set_Pixel
  (FB : in out Framebuffer;
   X, Y : Coordinate;
   C : Pixel)
   with Pre => X < FB.Width and then Y < FB.Height;
```

---

## Example: good vs bad API design

### Good API design

```ada
package Glyph.Drawing is

   type Line_Style is (Solid, Dashed, Dotted);

   procedure Draw_Line
     (FB       : in out Framebuffer;
      X1, Y1   : Coordinate;
      X2, Y2   : Coordinate;
      Color    : Pixel;
      Width    : Line_Width := 1;
      Style    : Line_Style := Solid)
      with Pre => Width > 0;

   procedure Fill_Rectangle
     (FB     : in out Framebuffer;
      X, Y   : Coordinate;
      W, H   : Positive;
      Color  : Pixel);

end Glyph.Drawing;
```

### Bad API design

```ada
package Glyph.Drawing is

   --  Inconsistent parameter ordering relative to Draw_Line.
   procedure Draw_Rect (C : Pixel; X, Y, W, H : Integer; FB : in out Framebuffer);

   --  Boolean flag instead of enumerated type.
   procedure Draw_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Integer; C : Pixel; Dashed : Boolean);

   --  No documentation.
   --  Ambiguous parameter names.
   procedure Draw_Circle (FB : in out Framebuffer; A, B, R : Natural; C : Pixel; F : Boolean);

end Glyph.Drawing;
```

---

## Deprecation policy

1. Mark deprecated subprograms with `pragma Deprecated`.
2. Document the replacement in a comment.
3. Maintain backward compatibility for one major version cycle.
4. Remove deprecated subprograms at the next major version release.

```ada
--  Deprecated: Use Draw_Line with Style parameter instead.
pragma Deprecated (Draw_Dashed_Line, "Use Draw_Line with Line_Style => Dashed");
procedure Draw_Dashed_Line (FB : in out Framebuffer; X1, Y1, X2, Y2 : Coordinate; C : Pixel);
```

---

## Future extensibility

### Adding parameters

When a subprogram may need additional parameters in the future, provide a default parameter value that preserves the existing signature.

```ada
--  Future: Could add Transparency => Boolean := False
procedure Draw_Pixel
  (FB   : in out Framebuffer;
   X, Y : Coordinate;
   C    : Pixel);
```

### Adding subprograms

New subprograms should be added as new declarations rather than modifying existing ones. New functionality should not change the behaviour of existing subprograms.
