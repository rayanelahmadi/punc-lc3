# punc-lc3

A multi-cycle implementation of the **LC-3** instruction set in Verilog — "PUnC"
(Pretty Uncomplicated Computer), built as a computer architecture course
project.

The processor fetches, decodes, and executes a 16-bit LC-3 program out of a
1024-word memory, using a control FSM driving a separate datapath. It supports
the arithmetic, logic, load/store, and control-flow instruction set: `ADD`,
`AND`, `NOT`, `LD`, `LDI`, `LDR`, `LEA`, `ST`, `STI`, `STR`, `BR`, `JMP`, `RET`,
`JSR`, `JSRR`, and a `HALT` trap.

The design passes all 19 instruction tests in the course testbench.

---

## Architecture

The design splits cleanly into a controller and a datapath, connected only by
control and status signals — the classic FSM + datapath decomposition.

```
                  ┌──────────────────┐
                  │   PUnCControl    │   FSM: INIT → FETCH → DECODE
                  │  (control FSM)   │        → EXECUTE → [EXECUTE_I] → …
                  └────────┬─────────┘                        │
              control      │      ▲  ir, canWeLoad            │
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
| `STATE_EXECUTE_I` | Second execute cycle, used only by `LDI` and `JSR`/`JSRR` |
| `STATE_HALT` | Terminal state; the PC stops advancing |

Most instructions retire in four cycles. `LDI` needs a fifth because it takes
two dependent memory reads (fetch the pointer, then dereference it), and
`JSR`/`JSRR` need one cycle to save the return address into R7 and another to
redirect the PC.

### Datapath

The datapath is built almost entirely from continuous assignments — the muxes
are ternary chains selected by the controller, with the mux encodings shared
between the two modules through `Defines.v`. The pieces are:

- **PC** — clear / load / increment, with the load source selected between R7,
  a base register, and the adder output.
- **IR** — loaded from memory port 0 during fetch.
- **ALU** — `ADD`, `AND` (register or sign-extended `imm5`), `NOT`, and a
  pass-through used by `LDI`'s second phase.
- **Adder** — a second adder dedicated to address generation, computing
  `PC + PCoffset9/11` and `BaseR + offset6`.
- **Comparator** — derives the `n`/`z`/`p` condition flags that gate `BR`.

Sign extension happens inline at the adder and ALU inputs, sized per
instruction field (`imm5`, `offset6`, `PCoffset9`, `PCoffset11`).

---

## Repository layout

| File | Origin | Description |
|---|---|---|
| `PUnC.v` | original | Top level; wires the controller to the datapath |
| `PUnCControl.v` | original | The control FSM |
| `PUnCDatapath.v` | original | PC, IR, ALU, adder, comparator, muxes |
| `Defines.v` | original | Opcodes, instruction field ranges, mux select encodings |
| `PUnC.t.v` | course-provided | Testbench and assertion macros |
| `testing.asm` | original | Hand-written factorial program, assembled by hand |
| `images/factorial.vmh` | original | The hand-assembled image for `testing.asm` |
| `Memory.v` | reconstructed | 1024 × 16 memory, 2 read ports, 1 write port |
| `RegisterFile.v` | reconstructed | 8 × 16 register file, 3 read ports, 1 write port |
| `tests/*.asm` | reconstructed | LC-3 source for the remaining 18 test programs |
| `images/*.vmh` | generated | Assembled test images loaded by the testbench |
| `tools/asm.py` | new | Minimal LC-3 assembler used to build the images |

### A note on provenance

`Memory.v` and `RegisterFile.v` were skeleton files handed out with the
assignment — you can still see the `//dont touch` markers on their port
connections in `PUnCDatapath.v` — and the `.vmh` test images belonged to the
instructor. Neither survived in my copy of the project, and redistributing
them wouldn't be mine to do anyway.

So both modules here were rewritten from scratch against the port lists the
datapath instantiates, and the 18 remaining test programs were rewritten
against the assertions in the testbench. They're behaviorally equivalent for
the purposes of the suite, but they aren't the originals. Everything marked
"original" in the table above is the actual coursework, unmodified.

Two details worth knowing for anyone reconstructing the skeleton modules
themselves:

- The internal storage arrays **must** be named `mem` and `rfile`, because the
  testbench reaches into them by hierarchical path
  (`punc.dpath.mem.mem[i]`, `punc.dpath.rfile.rfile[i]`) both to load images
  and to dump waveforms.
- `Memory` must **not** clear on reset. The testbench loads the program image
  before pulsing reset, so a reset that zeroed the array would erase the
  program before it ever ran.

---

## Building and running

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/), plus
Python 3 if you want to reassemble the test images.

```sh
make            # compile
make summary    # run the suite, results only
make run        # run with the full instruction trace
```

Expected output from `make summary`:

```
--- Completed 19 Tests  ----
--- Found      0 Errors ----
```

To view waveforms (`make run` writes `PUnCTATest.vcd`):

```sh
make wave       # requires gtkwave
```

To change or add a test, edit the files in `tests/` and reassemble:

```sh
make images
```

---

## Tests

The testbench runs one program per instruction — `addi`, `addr`, `andi`,
`andr`, `not`, `ld`, `ldi`, `ldr`, `lea`, `st`, `sti`, `str`, `jmp`, `jsr`,
`jsrr`, `ret`, `br` — and then two full programs:

- **`gcd`** — Euclid's algorithm by repeated subtraction.
- **`factorial`** — 6! computed with a multiply built out of repeated addition,
  using a nested loop and a two's-complement negation subroutine. This is the
  original hand-written program; `testing.asm` is its annotated source and
  `images/factorial.vmh` the image that was assembled from it by hand.

The two whole programs are the interesting ones, since passing them exercises
the branch, loop, subroutine, and memory paths together rather than one
instruction at a time.
