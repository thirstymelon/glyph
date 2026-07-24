# Coding standard

This document defines the Ada coding conventions for the Glyph project. All source code must conform to these standards.

## Language version

All source code must target Ada 2022. Use of Ada 2022 features such as aspect specifications, contract-based programming, and enhanced generics is encouraged where appropriate.

## Indentation and whitespace

- 3 spaces per indentation level. No tabs.
- 6 spaces for continuation lines (to distinguish from nested blocks).
- One space between keyword and opening parenthesis: `if (X > Y)`.
- One space around binary operators: `A + B`, not `A+B`.
- No space between subprogram name and parameter list: `Draw_Line (Buffer, X, Y)`.
- No space inside parentheses: `(A + B)`, not `( A + B )`.
- No trailing whitespace at end of lines.
- One blank line between subprograms.
- Two blank lines between package sections.

```ada
procedure Example is
   -- Indented by 3 spaces
   if Condition then
      -- Indented by 6 spaces (continuation)
      Do_Something;
   end if;
end Example;
```

## Maximum line length

100 characters. Applies to both code and comments.

## Naming conventions

| Element | Convention | Example |
|---------|------------|---------|
| Package | Hierarchical, capitalized components | `Glyph.Framebuffer.Mono` |
| Subprogram (procedure) | Imperative verb phrase, snake_case | `Draw_Line`, `Fill_Rectangle` |
| Subprogram (function) | Descriptive noun or query, snake_case | `Get_Pixel`, `Is_Visible` |
| Type | Descriptive noun, PascalCase | `Pixel_Format`, `Display_Driver` |
| Private type | Same as type, explicitly `private` in spec | `Framebuffer (private)` |
| Constant | UPPER_SNAKE_CASE | `MAX_DISPLAY_WIDTH` |
| Variable | snake_case | `pixel_buffer`, `cursor_position` |
| Generic formal parameter | Leading `T_` for types, UPPER_SNAKE_CASE for values | `T_Pixel_Type`, `WIDTH` |
| Named access type | Ending in `_Access` | `Framebuffer_Access` |
| Exception | PascalCase ending in `_Error` | `I2C_Transmission_Error`, `I2C_Error` |

### Package naming

- The root package is `Glyph`.
- Subpackages are named hierarchically: `Glyph.<Subsystem>[.<Component>]`.
- Package names use capitalized words without underscores: `Glyph.Framebuffer`.
- Acronyms retain their case: `Glyph.HAL.I2C`.

### Subprogram naming

- Procedures use imperative verbs: `Draw_Line`, `Clear_Buffer`, `Init`.
- Functions use descriptive nouns, adjectives, or queries: `Get_Pixel`, `Is_Visible`, `Width`.
- Predicate functions (returning Boolean) should be prefixed with `Is_` or `Has_`.
- Conversion functions should be prefixed with `To_`: `To_RGB565`, `To_Mono`.

### Keyword case

All Ada keywords are lowercase: `is`, `in`, `out`, `begin`, `end`, `if`, `then`, `else`, `loop`, `for`, `while`, `case`, `when`, `others`, `return`, `constant`, `type`, `subtype`, `package`, `procedure`, `function`, `with`, `use`, `pragma`, `aspect`.

## Package organization

### File per package

Each Ada package must reside in its own file pair (specification and body).

| Component | Specification | Body |
|-----------|---------------|------|
| `Glyph` | `glyph.ads` | `glyph.adb` |
| `Glyph.Framebuffer` | `glyph-framebuffer.ads` | `glyph-framebuffer.adb` |
| `Glyph.Framebuffer.Mono` | `glyph-framebuffer-mono.ads` | `glyph-framebuffer-mono.adb` |

### Package structure

Within a package specification, items should appear in this order:

1. Package documentation comment.
2. `with` and `use` clauses.
3. Type declarations.
4. Constant and variable declarations.
5. Subprogram declarations.
6. `private` section (if applicable):
   - Private type completions.
   - Implementation subprograms.
   - Internal constants.

```ada
--  Package documentation here.

package Glyph.Framebuffer.Mono is

   pragma Preelaborate;

   type Framebuffer is private;

   procedure Clear (FB : in out Framebuffer);

private

   type Framebuffer is record
      Buffer : Buffer_Type (1 .. MAX_BUFFER_SIZE);
   end record;

end Glyph.Framebuffer.Mono;
```

### File organization

Every `.ads` and `.adb` file must include:

1. File header comment.
2. `with` clauses (alphabetically sorted).
3. `use` clauses (if any).
4. Package declaration or body.
5. Subprogram ordering within packages:
   - Public subprograms first.
   - Private subprograms in the `private` section.
   - Subprogram bodies in `.adb` matching spec order.

## File naming

- Specification files use the `.ads` extension.
- Body files use the `.adb` extension.
- File names are lowercase with hyphens separating package hierarchy levels.

| Package | File name |
|---------|-----------|
| `Glyph` | `glyph.ads` / `glyph.adb` |
| `Glyph.Framebuffer` | `glyph-framebuffer.ads` / `glyph-framebuffer.adb` |
| `Glyph.Framebuffer.Mono` | `glyph-framebuffer-mono.ads` / `glyph-framebuffer-mono.adb` |
| `Glyph.Drivers.SSD1306` | `glyph-drivers-ssd1306.ads` / `glyph-drivers-ssd1306.adb` |

## Formatting rules

### Begin/end alignment

The `begin` keyword of a subprogram body should be on its own line, indented to the same level as the enclosing declarative block.

```ada
procedure Draw_Line
  (Buffer : in out Framebuffer;
   X1, Y1 : Coordinate;
   X2, Y2 : Coordinate)
is
   DX : constant Integer := X2 - X1;
   DY : constant Integer := Y2 - Y1;
begin
   --  Implementation
end Draw_Line;
```

### Parameter formatting

Long parameter lists place one parameter per line:

```ada
procedure Draw_Rectangle
  (Buffer   : in out Framebuffer;
   X, Y     : Coordinate;
   Width    : Positive;
   Height   : Positive;
   Color    : Pixel_Type;
   Filled   : Boolean := False);
```

Short parameter lists may stay on one line:

```ada
procedure Clear (Buffer : in out Framebuffer);
```

### Operator spacing

Operators should have spaces around them:

```ada
A + B
C - D
E * F
G / H
I mod J
```

### Control structures

```ada
if Condition then
   Do_Something;
end if;

for I in 1 .. 10 loop
   Process (I);
end loop;

case Value is
   when 0 =>
      Handle_Zero;
   when others =>
      Handle_Other;
end case;
```

### Aspect formatting

```ada
procedure Set_Pixel
  (Buffer : in out Framebuffer;
   X, Y   : Coordinate;
   Color  : Pixel_Type)
   with Pre => X < Buffer.Width
               and then Y < Buffer.Height;

type Coordinate is new Natural
   with Type_Invariant => Coordinate <= MAX_COORDINATE;
```

### Use clauses

- `use` clauses are permitted in package bodies.
- `use type` clauses are preferred over full `use` clauses where applicable.
- `use` clauses in package specifications should be avoided unless they improve readability significantly.
- Rename long package names with `package O renames ...` if `use` is undesirable.

## Comment style

### Line comments

Use `--` followed by two spaces for line comments. Comments explaining the following code should be at the same indentation level as the code.

```ada
--  This is a line comment.

--  This comment explains the purpose of the following block.
Do_Something;
Do_Something_Else;
```

### Block comments

Use line comments for multi-line explanations rather than comment brackets.

```ada
--  This is a multi-line comment block.
--  Each line starts with -- and two spaces.
--  The block explains a complex algorithm or design decision.
```

### Inline comments

Use inline comments sparingly. Place them two spaces after the code.

```ada
Counter := Counter + 1;  --  Increment frame counter
```

## Header format

Every Ada source file must begin with a header:

```ada
----------------------------------------------------------------------------
--  glyph.ads
--
--  Glyph: Embedded Graphics Framework for Ada
--
--  Top-level package providing library initialization and configuration.
--
--  Copyright (c) 2026 Glyph Contributors
--  Distributed under the Apache License, Version 2.0. See LICENSE.md.
----------------------------------------------------------------------------
```

## Documentation style

### Package documentation

Every package specification must include a documentation comment describing:

- The purpose and responsibility of the package.
- Usage assumptions or prerequisites.
- Thread-safety notes (if applicable).

### Subprogram documentation

Every public subprogram must include a comment describing:

- The purpose of the subprogram.
- Each parameter (mode and meaning).
- The return value (for functions).
- Exceptions raised.
- Preconditions or assumptions.

```ada
--  Draw a single pixel at the specified coordinates.
--  Buffer  - The framebuffer to draw on.
--  X       - X coordinate of the pixel.
--  Y       - Y coordinate of the pixel.
--  Color   - The pixel color value.
--  Raises Constraint_Error if the coordinates are out of bounds.
procedure Draw_Pixel
  (Buffer : in out Framebuffer;
   X, Y   : Coordinate;
   Color  : Pixel_Type);
```

### Type documentation

Every public type must include a comment describing its purpose and any constraints on its values.

```ada
--  Pixel coordinate within the framebuffer.
--  Valid range is 0 .. Framebuffer_Width - 1 for X,
--  and 0 .. Framebuffer_Height - 1 for Y.
subtype Coordinate is Natural;
```

## Error handling

- Use Ada subtypes and constraints to prevent invalid values at compile time.
- Use preconditions and postconditions to document and enforce contracts.
- Use exceptions only for exceptional conditions that cannot be prevented by type checking.
- Use status codes (enumerated return types) for expected failure modes such as I2C transmission errors.
- Internal errors (bugs) should raise `Program_Error` or `Assertion_Error`.

```ada
type I2C_Status is (Success, Bus_Error, Arbitration_Lost, Timeout);

function Write
  (Address : I2C_Address;
   Data    : Byte_Array) return I2C_Status;
```

## Assertions and contracts

- Use `pragma Assert` for internal invariants.
- Use aspect `Pre` and `Post` on public subprograms where the contract is clear and stable.
- Use aspect `Type_Invariant` on types with invariant constraints.

```ada
procedure Set_Pixel
  (Buffer : in out Framebuffer;
   X, Y   : Coordinate;
   Color  : Pixel_Type)
   with Pre => X < Buffer.Width and then Y < Buffer.Height;
```

## Git commit format

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) format.

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for details and examples.

## Review checklist

Before submitting a pull request, verify:

- [ ] Code follows indentation, naming, and formatting rules.
- [ ] All public subprograms are documented.
- [ ] All parameters have mode indicators (`in`, `out`, `in out`).
- [ ] No hard-coded magic numbers (use named constants).
- [ ] No dead code or commented-out code.
- [ ] No heap allocation after initialization.
- [ ] No floating-point arithmetic in rendering paths.
- [ ] No recursion with unbounded depth.
- [ ] All subprograms have pre/post conditions where applicable.
- [ ] Tests cover the new functionality (happy path and edge cases).
- [ ] Documentation is updated.
- [ ] Commit messages follow conventional commit format.
