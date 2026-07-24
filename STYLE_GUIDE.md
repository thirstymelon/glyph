# Style guide

This document is a quick-reference companion to the [CODING_STANDARD.md](CODING_STANDARD.md). It focuses on visual style and formatting decisions.

---

## Indentation

- 3 spaces per level.
- No tabs.
- 6 spaces for continuation lines.

---

## Maximum line length

100 characters. Both code and comments.

---

## White space

- One space between keyword and opening parenthesis: `if (X > Y)`.
- One space around binary operators: `A + B`, not `A+B`.
- No space between subprogram name and parameter list: `Draw_Line (Buffer, X, Y)`.
- No space inside parentheses: `(A + B)`, not `( A + B )`.
- No trailing whitespace at end of lines.
- One blank line between subprograms.
- Two blank lines between package sections.

---

## Blank lines

```ada
package Glyph.Example is
   --  One blank line after package declaration.
   procedure A;
   --  One blank line between subprograms.
   procedure B;
end Glyph.Example;
```

---

## Parameter alignment

Long parameter lists place one parameter per line.

```ada
procedure Draw_Line
  (Buffer : in out Framebuffer;
   X1, Y1 : Coordinate;
   X2, Y2 : Coordinate);
```

Short parameter lists may stay on one line.

```ada
procedure Clear (Buffer : in out Framebuffer);
```

---

## Keyword case

All Ada keywords are lowercase: `is`, `in`, `out`, `begin`, `end`, `if`, `then`, `else`, `loop`, `for`, `while`, `case`, `when`, `others`, `return`, `constant`, `type`, `subtype`, `package`, `procedure`, `function`, `with`, `use`, `pragma`, `aspect`.

---

## Identifier case

- Package names: Capitalized components, no underscores: `Glyph.Framebuffer.Mono`.
- Type names: PascalCase: `Pixel_Format`, `Display_Driver_Ref`.
- Subprogram names: snake_case: `Draw_Line`, `Get_Pixel`.
- Constants: UPPER_SNAKE_CASE: `MAX_BUFFER_SIZE`.
- Variables: snake_case: `current_position`, `temp_buffer`.
- Exceptions: PascalCase ending in `_Error`: `I2C_Error`.

---

## Comment formatting

```ada
--  Sentence case, starting with capital letter.
--  Ending with period if full sentence.
--  One space between -- and text.
```

---

## File headers

```ada
----------------------------------------------------------------------------
--  filename.extension
--
--  One-line purpose description.
--
--  Optional additional context (2-3 lines max).
--
--  Copyright (c) 2026 Glyph Contributors
--  Distributed under the Apache License, Version 2.0. See LICENSE.md.
----------------------------------------------------------------------------
```

---

## Aspect formatting

```ada
procedure Set_Pixel
  (Buffer : in out Framebuffer;
   X, Y   : Coordinate;
   Color  : Pixel_Type)
   with Pre => X < Buffer.Width
               and then Y < Buffer.Height;
```

Aspects on type declarations:

```ada
type Coordinate is new Natural
   with Type_Invariant => Coordinate <= MAX_COORDINATE;
```

---

## Use clauses

- `use` clauses are permitted in package bodies.
- `use type` clauses are preferred over full `use` clauses where applicable.
- `use` clauses in package specifications should be avoided unless they improve readability significantly.
- Rename long package names with `package O renames` if `use` is undesirable.

---

## File organization

Every `.ads` and `.adb` file must include:

1. File header comment.
2. `with` clauses (alphabetically sorted).
3. `use` clauses (if any).
4. Package declaration or body.
5. Subprogram ordering within packages:
   - Public subprograms first.
   - Private subprograms in the `private` section.
   - Subprogram bodies in `.adb` matching spec order.
