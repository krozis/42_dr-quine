# dr-quine

> 42 project — implement self-reproducing programs (quines) in C and x86-64 Assembly.

---

## Table of Contents

1. [What is a Quine?](#what-is-a-quine)
2. [Rules](#rules)
3. [Project Structure](#project-structure)
4. [C Implementation](#c-implementation)
   - [How it works](#how-it-works)
   - [The technique — %c / %s trick](#the-technique--c--s-trick)
   - [Constraints met](#constraints-met)
   - [Build & verify](#build--verify)
5. [ASM Implementation](#asm-implementation)
   - [How it works](#how-it-works-1)
   - [Constraints met](#constraints-met-1)
   - [Build & verify](#build--verify-1)
6. [Quines: things to know](#quines-things-to-know)

---

## What is a Quine?

A **quine** is a program that, when executed, produces its own source code as output — without reading any file, without using any external input.

```
./Colleen | diff - colleen.c   # no output = perfect quine
```

The challenge: the program must carry a representation of itself inside its own code, and use it to reconstruct the source at runtime.

---

## Rules

- **Forbidden**: reading the source file, using any external input (stdin, files, network…).
- **Required**: both a C and an x86-64 ASM version for every program.
- **Three programs**: `Colleen`, `Grace`, `Sully` (executables with a capital letter).
- Strict compilation: `-Wall -Wextra -Werror` for C, `nasm -f elf64` + `gcc` for ASM.
- No crashes, no undefined behavior, no memory errors.

---

## Project Structure

```
.
├── C/
│   ├── Makefile
│   ├── colleen.c
│   ├── grace.c
│   └── sully.c
└── ASM/
    ├── Makefile
    ├── colleen.s
    ├── grace.s
    └── sully.s
```

Each directory has its own `Makefile` with the standard rules: `all`, `clean`, `fclean`, `re`.
Files recompile only when necessary (standard dependency tracking via `.o` objects).

---

## C Implementation

### How it works

The source code is stored as a **global format string** `s`. The `print()` function calls `printf(s, ...)` which fills in the format specifiers and reconstructs the source — including the declaration of `s` itself.

### The technique — `%c` / `%s` trick

Every character that cannot appear literally inside a C string is replaced by a `%c` format specifier paired with its ASCII value:

| Character | ASCII | Appears as in `s` |
|-----------|-------|-------------------|
| `\n`      | 10    | `%c` + arg `10`   |
| `\t`      | 9     | `%c` + arg `9`    |
| `"`       | 34    | `%c` + arg `34`   |

The string declaration itself is reproduced using `%c%s%c`:
- first `%c` (34) → opening `"`
- `%s` → the content of `s` itself (the whole format string, printed raw)
- second `%c` (34) → closing `"`

Because `%s` inserts the raw bytes of `s` (no escape interpretation), the string declaration in the output shows the format specifiers literally — exactly as they appear in the source.

### Constraints met

| Requirement | Where |
|---|---|
| `main` function | `int main(void)` |
| Extra function called from `main` | `void print(void)` |
| Comment outside any function | Line 3: `// Boolean Rhapsody` |
| Comment inside `main` | Line 14: `// Killer Quine` |

### Build & verify

```bash
cd C/
make
./Colleen | diff - colleen.c   # no output = quine is valid
```

---

## ASM Implementation

### How it works

The same logic applies in Assembly: the source code (as text) is embedded in the `.data` section as a null-terminated string. A `write` syscall outputs it character by character (or all at once), reconstructing the source from within the binary itself.

The string contains the format specifiers in textual form (literal `%c`, `%s`); a separate routine handles the substitution of special characters before the final write.

### Constraints met

| Requirement | Where |
|---|---|
| Clear entry point | `_start` label (linked via `gcc`) |
| Extra routine called from entry point | `print` (or equivalent) |
| Comment outside entry point | In `.data` section or above `_start` |
| Comment inside entry point or its immediate routine | Inside `_start` or `print` |

### Build & verify

```bash
cd ASM/
make
./Colleen > out && diff out colleen.s   # empty diff = quine is valid
```

---

## Quines: things to know

**Why not just `cat` the file?**
Reading the source file is trivially disqualified. The point is that the program carries the information inside itself.

**The self-reference paradox**
A quine must encode its own encoding. The `%s` trick solves this: by inserting the raw format string via `%s`, the string declaration line is reconstructed without any additional escaping.

**Verifying correctness**
The canonical check is a byte-for-byte diff:
```bash
./Colleen | diff - colleen.c
```
No output means the program's output is identical to its source file.

**Why `%c` with ASCII values instead of `\n` / `\t`?**
Using `\n` in a C string literal produces an actual newline byte in memory. When printed via `%s`, this outputs a real newline — which would break the string declaration line across multiple lines, making it syntactically invalid in the output. Using `%c` + `10` keeps the string on one line and injects newlines at the right positions during printing.
