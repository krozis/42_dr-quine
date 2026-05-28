# dr-quine

> 42 project — implement self-reproducing programs (quines) in C and x86-64 Assembly.

---

## Table of Contents

- [dr-quine](#dr-quine)
  - [Table of Contents](#table-of-contents)
  - [What is a Quine?](#what-is-a-quine)
  - [Rules](#rules)
  - [Project Structure](#project-structure)
  - [C — Colleen](#c--colleen)
    - [How it works](#how-it-works)
    - [The technique — `%c` / `%s` trick](#the-technique--c--s-trick)
    - [Constraints met](#constraints-met)
    - [Build \& verify](#build--verify)
  - [C — Grace](#c--grace)
    - [How it works](#how-it-works-1)
    - [Constraints met](#constraints-met-1)
    - [Build \& verify](#build--verify-1)
  - [C — Sully](#c--sully)
    - [How it works](#how-it-works-2)
    - [The `%%` trick](#the--trick)
    - [Build \& verify](#build--verify-2)
  - [ASM Implementation](#asm-implementation)
    - [How it works](#how-it-works-3)
    - [Constraints met](#constraints-met-2)
    - [Build \& verify](#build--verify-3)
  - [Quines: things to know](#quines-things-to-know)

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
- C comments must be formated as follow :

```C
1  /*
2     Comment Here
3  */
```

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

## C — Colleen

### How it works

The source code is stored as a **global format string** `s`. The `print()` function calls `printf(s, ...)` which fills in the format specifiers and reconstructs the source — including the declaration of `s` itself.

### The technique — `%c` / `%s` trick

Every character that cannot appear literally inside a C string is replaced by a `%c` format specifier paired with its ASCII value:

| Character | ASCII | In `s` |
|-----------|-------|--------|
| `\n`      | 10    | `%c` + arg `10` |
| `\t`      | 9     | `%c` + arg `9`  |
| `"`       | 34    | `%c` + arg `34` |

The string declaration line is reproduced using `%c%s%c`:
- first `%c` (34) → opening `"`
- `%s` → the raw bytes of `s` (the whole format string, no re-interpretation)
- second `%c` (34) → closing `"`

Because `%s` inserts raw bytes, the format specifiers inside `s` appear literally in the output — exactly as written in the source.

### Constraints met

| Requirement | Where |
|---|---|
| `main` function | `int main(void)` |
| Extra function called from `main` | `void print(void)` |
| Comment outside any function | `// Boolean Rhapsody` |
| Comment inside `main` | `// Killer Quine` |

### Build & verify

```bash
cc -Wall -Wextra -Werror -o Colleen C/colleen.c && ./Colleen | diff - C/colleen.c
```

---

## C — Grace

### How it works

Grace is a quine that **writes its output to a file** (`Grace_kid.c`) instead of stdout.  
The source has **no declared functions** — `main` is hidden inside a `#define MAIN` macro and invoked at the bottom of the file.

Three defines:
- `#define S` — the format string (same `%c`/`%s` trick as Colleen)
- `#define N` — the output filename `"Grace_kid.c"`
- `#define MAIN` — expands to the full `int main(void){...}` body

The macro at the bottom of the file:
```c
MAIN
```
...is the only "call site". The preprocessor expands it before the compiler ever sees a function declaration.

### Constraints met

| Requirement | Where |
|---|---|
| No functions declared | `main` lives inside `#define MAIN` |
| Exactly 3 `#define` | `S`, `N`, `MAIN` |
| One comment | `// Another One Writes the Rust` |
| Program runs by calling a macro | `MAIN` at end of file |

### Build & verify

```bash
cc -Wall -Wextra -Werror -o Grace C/grace.c && ./Grace && diff Grace_kid.c C/grace.c
```

---

## C — Sully

### How it works

Sully is a **self-replicating chain**: it writes a modified copy of itself to `Sully_{i-1}.c`, compiles it, and runs it — if `i - 1 >= 0`.

The integer `i` (initially `5`) decrements at each generation:

```
Sully (i=5) → Sully_4.c (i=4) → Sully_3.c (i=3) → ... → Sully_0.c (i=0) → Sully_-1.c compiled but not run
```

This produces **13 files** in total: 6 source files + 6 binaries + the original `Sully` binary.

Each program:
1. Builds the filename: `snprintf(name, ..., "Sully_%d.c", i - 1)`
2. Writes its own source with `i - 1` substituted via `fprintf(f, s, ..., i - 1, ...)`
3. Compiles the new file with `system()`
4. Runs it with `execl()` if `i - 1 >= 0`

### The `%%` trick

The source contains `%d` and `%s` inside runtime `snprintf` format strings (e.g. `"Sully_%d.c"`). If stored as-is in `s`, `fprintf` would consume them as format specifiers and output a number instead of `%d`.

The fix: store them as `%%d` / `%%s` in `s`.

| In `s`  | `fprintf` outputs | `%s` prints raw |
|---------|-------------------|-----------------|
| `%%d`   | `%d`              | `%%d`           |
| `%%s`   | `%s`              | `%%s`           |

The generated file therefore inherits `%%d` in its own `s` — and will produce the correct `%d` output in turn. The chain is self-consistent across all generations.

### Build & verify

```bash
cc -Wall -Wextra -Werror -o Sully C/sully.c && ./Sully
ls Sully* | wc -l        # should print 13
diff Sully_4.c C/sully.c # only line 5 (int i) should differ
```

---

## ASM Implementation

### How it works

The same logic applies in Assembly: the source code (as text) is embedded in the `.data` section as a null-terminated string. Special characters (newlines, tabs, quotes) are handled by injecting their ASCII values at the right positions, using Linux syscalls (`write`) for output.

For Grace and Sully the output goes through a file descriptor obtained via `open`/`creat`.

### Constraints met

| Requirement | Where |
|---|---|
| Clear entry point | `_start` label (linked via `gcc`) |
| Extra routine called from entry point | helper routine (e.g. `print`) |
| Comment outside entry point | in `.data` section or above `_start` |
| Comment inside entry point or its immediate routine | inside `_start` or `print` |

### Build & verify

```bash
cd ASM/
make
./Colleen | diff - colleen.s
./Grace && diff Grace_kid.s grace.s
./Sully && ls Sully* | wc -l
```

---

## Quines: things to know

**Why not just `cat` the file?**
Reading the source file is trivially disqualified. The point is that the program carries the information inside itself.

**The self-reference paradox**
A quine must encode its own encoding. The `%s` trick solves this: by inserting the raw format string via `%s`, the string declaration line is reconstructed without any additional escaping.

**Why `%c` with ASCII values instead of `\n` / `\t`?**
Using `\n` in a C string literal produces an actual newline byte in memory. When printed via `%s`, this outputs a real newline — which would break the `char *s = "..."` declaration across multiple lines, making the output syntactically invalid C. Using `%c` + `10` keeps `s` on one line while injecting newlines at the right positions.

**The `%%` problem in Sully**
When the source itself contains `%d` or `%s` inside string literals (for `snprintf` calls), those clash with the format string trick. Using `%%d` in `s` makes `fprintf` output a literal `%d`, while `%s` prints `%%d` into the string declaration — which the next generation also uses correctly. The escaping propagates intact through the chain.

**Verifying correctness**
```bash
./Colleen | diff - colleen.c          # pure quine: stdout == source
./Grace && diff Grace_kid.c grace.c   # file quine: written file == source
./Sully && diff Sully_4.c sully.c     # chain quine: only int i differs
```
