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
  - [ASM — Colleen](#asm--colleen)
    - [How it works](#how-it-works-3)
    - [The technique — positional specifiers](#the-technique--positional-specifiers)
    - [Constraints met](#constraints-met-2)
    - [Build \& verify](#build--verify-3)
  - [ASM — Grace](#asm--grace)
    - [How it works](#how-it-works-4)
    - [The `%%` trick in NASM](#the--trick-in-nasm)
    - [Constraints met](#constraints-met-3)
    - [Build \& verify](#build--verify-4)
  - [ASM — Sully](#asm--sully)
    - [How it works](#how-it-works-5)
    - [The `__?FILE?__` trick](#the-__file__-trick)
    - [Build \& verify](#build--verify-5)
  - [Bonus](#bonus)
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

## ASM — Colleen

### How it works

Same principle as C/Colleen: the full source is stored as a format string `source` in `.data`. A `print` routine calls `printf(source, '\n', '"', source)` which replaces the format specifiers and reconstructs the source — including the `source: db "..."` line itself.

The entry point is `global main`, linked via `gcc` (`nasm -f elf64` + `gcc -no-pie`). All memory references use RIP-relative addressing (`default rel`) for ASLR compatibility.

### The technique — positional specifiers

The C version uses sequential `%c`/`%s`. The ASM version uses **positional** specifiers so each argument can be referenced by index:

| Specifier | Argument | Register | Value |
|-----------|----------|----------|-------|
| `%1$c`    | 1st      | `esi`    | 10 → `\n` |
| `%2$c`    | 2nd      | `edx`    | 34 → `"` |
| `%3$s`    | 3rd      | `rcx`    | `source` (raw bytes, no re-interpretation) |

`xor eax, eax` before `call printf` sets the SSE argument count to 0 — mandatory for variadic functions in the System V x86-64 ABI.

### Constraints met

| Requirement | Where |
|---|---|
| Clear entry point | `global main` + `main:` label |
| Extra routine called from entry point | `print:`, called from `main` |
| Comment inside entry point | `; I Want to Make Free` inside `main` |
| Comment outside entry point | `; It's a Quine of Magic` in `.data` |

### Build & verify

```bash
cd ASM && make Colleen
./Colleen | diff - colleen.s   # no output = perfect quine
```

---

## ASM — Grace

### How it works

Grace writes its own source to `Grace_kid.s` using `fopen` / `fprintf` / `fclose`. The entry point (`main`) is defined entirely inside a NASM `%macro`, invoked at the bottom of the file — satisfying the "program runs by calling a macro" constraint.

Three NASM macros mirror the three `#define` of C/Grace:
- `%define S` — the format string (same positional specifier trick as ASM/Colleen)
- `%define N` — the output filename `"Grace_kid.s"`
- `%macro MAIN 0` — the full `main` body, expanded once at the `MAIN` invocation line

`fprintf` arguments follow the same register mapping as Colleen, with `rdi` carrying the `FILE*` (saved in `rbx` across calls since `rax` is clobbered by each `call`).

Stack layout in `main`:

```
push rbp    → rsp % 16 == 0
push rbx    → rsp % 16 == 8
sub rsp, 8  → rsp % 16 == 0   ✓ aligned before every call
```

### The `%%` trick in NASM

The format string must reproduce lines like `%%define S`, `%%macro MAIN 0`, `%%endmacro` in the output. `%%` in a C printf format string outputs a literal `%`. NASM stores `%%` as two raw bytes in the binary — fprintf then interprets them and emits a single `%`.

| In `S`       | fprintf outputs | What appears in `Grace_kid.s` |
|--------------|-----------------|-------------------------------|
| `%%define`   | `%define`       | `%define S "..."`             |
| `%%macro`    | `%macro`        | `%macro MAIN 0`               |
| `%%endmacro` | `%endmacro`     | `%endmacro`                   |

### Constraints met

| Requirement | Where |
|---|---|
| No extra routines | only `main:` exists, defined inside `%macro MAIN 0` |
| Exactly 3 macros | `%define S`, `%define N`, `%macro MAIN 0` |
| One comment | `; It's a Quine of Magic` in `.data` |
| Program runs by calling a macro | `MAIN` at end of file |

### Build & verify

```bash
cd ASM && make Grace
./Grace && diff Grace_kid.s grace.s   # no output = perfect quine
```

---

## ASM — Sully

### How it works

Sully is the ASM counterpart of C/Sully: a self-replicating chain that writes `Sully_X.s`, compiles it, and runs it if `X >= 0`.

The key difference from the C version: instead of storing `i` as a `dd` value in `.data`, the integer is read at runtime from the **filename of the current binary** — via the NASM special token `__?FILE?__`.

```
; i = 5          ← comment showing the current value (reproduced by %4$d)
default rel
...
fname: db __?FILE?__, 0   ← NASM embeds the source filename at assemble time
```

At startup, the code scans `fname` for an underscore. If found, the digit after it is the current `i`; decrement gives the value to write. If no underscore (original `sully.s`), the hardcoded default `mov ebx, 5` applies.

```
sully (ebx=5) → Sully_5.s → Sully_4.s → ... → Sully_0.s → stops
```

The `fprintf` call uses a 4th positional argument `%4$d` for the integer, in addition to the usual `%1$c` / `%2$c` / `%3$s` triple.

The compile command (stored in `comp_fmt`) chains nasm + gcc + rm in a single `system()` call and has **5 occurrences of `%d`** — which requires passing 2 extra arguments on the stack beyond the 6 register slots.

### The `__?FILE?__` trick

`__?FILE?__` is a NASM built-in that expands to the current source filename **at assembly time**, not at runtime. It is reproduced literally by the format string (via `%3$s`) — each generated file gets its own name embedded when NASM assembles it.

| File assembled | `fname` contains |
|----------------|-----------------|
| `sully.s`      | `"sully.s"`     |
| `Sully_4.s`    | `"Sully_4.s"`   |

This lets every generation determine its own `i` without any mutable data in `.data`.

### Build & verify

```bash
cd ASM && make Sully
./Sully
diff Sully_5.s sully.s          # Sully_5.s is identical to sully.s
diff <(sed 's/; i = .*/; i = X/' Sully_4.s) \
     <(sed 's/; i = .*/; i = X/' Sully_3.s)  # all generations identical modulo i
```

---

## Bonus

> To do — reimplement the full project in a third language (not C, not ASM, not a trivial C→C++ copy).

The bonus is only evaluated if the mandatory part is perfect. The chosen language must handle the quine constraint natively (no file reads, no external input). In languages without a preprocessor or macro system, the `#define` / `%macro` patterns from Grace are replaced by the language's equivalent construct.

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
# C
./Colleen | diff - colleen.c          # pure quine: stdout == source
./Grace && diff Grace_kid.c grace.c   # file quine: written file == source
./Sully && diff Sully_4.c sully.c     # chain quine: only int i differs

# ASM
./Colleen | diff - colleen.s
./Grace && diff Grace_kid.s grace.s
./Sully && diff Sully_5.s sully.s   # chain quine: Sully_5 == sully, others differ only in i
```
