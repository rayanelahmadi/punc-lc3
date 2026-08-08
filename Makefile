#===============================================================================
# Makefile for PUnC LC3 Processor
#
#   make          - compile the testbench
#   make run      - compile and run the full test suite
#   make summary  - run the suite, showing only test results (no debug traces)
#   make images   - reassemble tests/*.asm into images/*.vmh
#   make wave     - open the resulting waveform in GTKWave
#   make clean    - remove build products
#===============================================================================

IVERILOG := iverilog
VVP      := vvp
GTKWAVE  := gtkwave
PYTHON   := python3

TOP      := PUnC.t.v
OUT      := punc.vvp
VCD      := PUnCTATest.vcd

SOURCES  := PUnC.t.v PUnC.v PUnCControl.v PUnCDatapath.v \
            Memory.v RegisterFile.v Defines.v

ASMS     := $(wildcard tests/*.asm)
VMHS     := $(patsubst tests/%.asm,images/%.vmh,$(ASMS))

.PHONY: all run summary images wave clean

all: $(OUT)

$(OUT): $(SOURCES)
	$(IVERILOG) -g2005 -o $(OUT) $(TOP)

run: $(OUT)
	$(VVP) $(OUT)

# Same run as `make run`, with the per-instruction trace filtered out so only
# the test results are shown.
summary: $(OUT)
	@$(VVP) $(OUT) 2>&1 | grep -v -e 'ExecuteInstruction' -e 'VCD warning'

images: $(VMHS)

images/%.vmh: tests/%.asm tools/asm.py
	@mkdir -p images
	$(PYTHON) tools/asm.py $< $@

wave: $(VCD)
	$(GTKWAVE) $(VCD)

$(VCD): run

clean:
	rm -f $(OUT) $(VCD)
