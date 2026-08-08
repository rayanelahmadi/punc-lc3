# punc-lc3

A **16-bit LC-3 processor implemented in Verilog** — PUnC, for "Pretty
Uncomplicated Computer." It's a multi-cycle CPU built from scratch at the RTL
level: a control FSM, a datapath, and a memory hierarchy, running real compiled
LC-3 programs out of a 1024-word memory.

It implements the full LC-3 user instruction set — arithmetic, logic, three
addressing modes for loads and stores, conditional branches, and subroutine
calls — and **passes all 19 tests in the course testbench**.

```
--- Completed 19 Tests  ----
--- Found      0 Errors ----
```

---

## Instruction set

| Class | Instructions |
|---|---|
| Arithmetic / logic | `ADD`, `AND` (register and immediate forms), `NOT` |
| Loads | `LD` (PC-relative), `LDI` (indirect), `LDR` (base + offset), `LEA` |
| Stores | `ST` (PC-relative), `STI` (indirect), `STR` (base + offset) |
| Control flow | `BR` (any `n`/`z`/`p` combination), `JMP`, `RET` |
| Subroutines | `JSR` (PC-relative), `JSRR` (register) |
| System | `HALT` |

---

## Architecture

The design separates the control FSM from the datapath entirely — they
communicate only through control signals and status flags, with the mux
encodings shared between them via `Defines.v`. This is the standard
decomposition for a multi-cycle CPU, and it keeps the sequencing logic
readable independently of the wiring it drives.

```
                  ┌──────────────────┐
                  │   PUnCControl    │   FSM: INIT → FETCH → DECODE
                  │  (control FSM)   │        → EXECUTE → [EXECUTE_I] → …
                  └────────┬─────────┘                        │
              control      │      ▲  ir, condition flags      │
              signals      ▼      │                           ▼
                  ┌──────────────────┐                   STATE_HALT
                  │  PUnCDatapath    │
                  │  PC · IR · ALU   │
                  │  adder · muxes   │
                  └───┬──────────┬───┘
                      │          │
              ┌───────▼───┐  ┌───▼──────────┐
              │  Memory   │  │ RegisterFile │
              │ 1024 × 16 │  │    8 × 16    │
              └───────────┘  └──────────────┘
```

### Control FSM

| State | Purpose |
|---|---|
| `STATE_INIT` | Clear the PC on reset |
| `STATE_FETCH` | Drive `PC` onto the memory read port, latch `IR`, increment `PC` |
| `STATE_DECODE` | Settle the instruction fields |
| `STATE_EXECUTE` | Single-cycle execution for most opcodes |
| `STATE_EXECUTE_I` | Second execute cycle, for `LDI` and `JSR`/`JSRR` |
| `STATE_HALT` | Terminal state; the PC stops advancing |

Most instructions retire in four cycles. Two cases need a fifth, and they're
the interesting ones:

- **`LDI`** performs two *dependent* memory reads — fetch a pointer from
  memory, then dereference it. The second address isn't known until the first
  read returns, so it can't be folded into one cycle.
- **`JSR`/`JSRR`** need one cycle to save the return address into R7 and
  another to redirect the PC, since both write to register-file and PC state
  that the other depends on.

### Datapath

Built almost entirely from continuous assignments, with muxes expressed as
ternary chains driven by the controller's select signals:

- **PC** — clear / load / increment, with the load source selected between R7,
  a base register, and the address adder.
- **IR** — latched from memory read port 0 during fetch.
- **ALU** — `ADD`, `AND` (register or sign-extended `imm5`), `NOT`, and a
  pass-through used by `LDI`'s second phase.
- **Address adder** — a second adder dedicated to address generation, so
  `PC + PCoffset9/11` and `BaseR + offset6` don't contend with the ALU.
- **Comparator** — derives the `n`/`z`/`p` condition flags that gate `BR`.

Sign extension happens inline at the adder and ALU inputs, sized per
instruction field (`imm5`, `offset6`, `PCoffset9`, `PCoffset11`).

### Memory and register file

`Memory` is a 1024 × 16 array with two asynchronous read ports and one
synchronous write port — one read port for the datapath, one reserved for the
testbench's debug probe. `RegisterFile` is 8 × 16 with three asynchronous read
ports and one synchronous write port, since instructions like `STR` need two
source registers read simultaneously alongside the debug port.

---

## Building and running

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/), plus
Python 3 to reassemble the test images.

```sh
make            # compile
make summary    # run the test suite, results only
make run        # run with the full per-instruction trace
make wave       # view waveforms in GTKWave (after make run)
```

To modify or add a test, edit the assembly in `tests/` and rebuild the images:

```sh
make images
```

---

## Tests

The suite (`PUnC.t.v`, provided by the course) runs one program per
instruction, then two complete programs that exercise the branch, loop,
subroutine, and memory paths together:

- **`gcd`** — Euclid's algorithm by repeated subtraction.
- **`factorial`** — 6! computed with a multiply built out of repeated addition,
  using a nested loop and a two's-complement negation subroutine. `testing.asm`
  is the annotated source, hand-assembled into `images/factorial.vmh`.

Each test loads a `.vmh` image into memory, runs until the PC stops advancing,
and asserts against expected register and memory contents.

---

## Repository layout

| Path | Description |
|---|---|
| `PUnC.v` | Top level; wires the controller to the datapath |
| `PUnCControl.v` | The control FSM |
| `PUnCDatapath.v` | PC, IR, ALU, address adder, comparator, muxes |
| `Defines.v` | Opcodes, instruction field ranges, mux select encodings |
| `Memory.v` | 1024 × 16 memory, 2 read ports, 1 write port |
| `RegisterFile.v` | 8 × 16 register file, 3 read ports, 1 write port |
| `PUnC.t.v` | Testbench and assertion macros |
| `testing.asm` | Annotated assembly source for the factorial program |
| `tests/` | LC-3 assembly source for the test programs |
| `images/` | Assembled `.vmh` images loaded by the testbench |
| `tools/asm.py` | Minimal LC-3 assembler used to build the images |
