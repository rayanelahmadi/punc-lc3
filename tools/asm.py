#!/usr/bin/env python3
"""
Minimal LC-3 assembler for the PUnC test images.

Produces a 128-line .vmh file (one 4-digit hex word per line), which is the
format PUnC.t.v expects:  $readmemh("images/<name>.vmh", ..., 0, 127)

Supported syntax
----------------
    LABEL:  INSTR  operands        ; comment
            .FILL  value|LABEL
            .ORIG  addr            (set the assembly location counter)

Operands: R0-R7, #decimal, xHEX, or a label (for PC-relative instructions).
"""

import re
import sys

OPCODES = {
    'ADD': 0b0001, 'AND': 0b0101, 'BR': 0b0000, 'JMP': 0b1100,
    'JSR': 0b0100, 'LD': 0b0010, 'LDI': 0b1010, 'LDR': 0b0110,
    'LEA': 0b1110, 'NOT': 0b1001, 'ST': 0b0011, 'STI': 0b1011,
    'STR': 0b0111, 'HALT': 0b1111,
}

MEM_WORDS = 128


class AsmError(Exception):
    pass


def parse_reg(tok):
    m = re.fullmatch(r'[Rr]([0-7])', tok)
    if not m:
        raise AsmError("expected a register, got %r" % tok)
    return int(m.group(1))


def parse_num(tok):
    tok = tok.strip()
    if tok.startswith('#'):
        return int(tok[1:], 10)
    if tok.lower().startswith('x'):
        return int(tok[1:], 16)
    if tok.lower().startswith('0x'):
        return int(tok, 16)
    return int(tok, 10)


def is_num(tok):
    try:
        parse_num(tok)
        return True
    except ValueError:
        return False


def fit(val, bits, what):
    """Mask val into `bits` bits, checking it is representable."""
    lo, hi = -(1 << (bits - 1)), (1 << bits) - 1
    if not (lo <= val <= hi):
        raise AsmError("%s out of range for %d bits: %d" % (what, bits, val))
    return val & ((1 << bits) - 1)


def tokenize(line):
    line = re.sub(r';.*', '', line)          # strip comments
    return line.strip()


def first_pass(lines):
    """Resolve labels to addresses; return (labels, [(addr, mnemonic, args)])."""
    labels, items, addr = {}, [], 0

    for lineno, raw in enumerate(lines, 1):
        text = tokenize(raw)
        if not text:
            continue

        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)\s*:\s*(.*)$', text)
        if m:
            label, text = m.group(1), m.group(2).strip()
            if label in labels:
                raise AsmError("line %d: duplicate label %s" % (lineno, label))
            labels[label] = addr
            if not text:
                continue

        parts = re.split(r'[\s,]+', text)
        mnemonic, args = parts[0].upper(), [p for p in parts[1:] if p]

        if mnemonic == '.ORIG':
            addr = parse_num(args[0])
            continue

        items.append((addr, mnemonic, args, lineno))
        addr += 1

    return labels, items


def offset_to(labels, target, pc, bits, lineno):
    """PC-relative offset. `pc` is already-incremented, as PUnC computes it."""
    if target in labels:
        delta = labels[target] - pc
    elif is_num(target):
        delta = parse_num(target)
    else:
        raise AsmError("line %d: unknown label %r" % (lineno, target))
    try:
        return fit(delta, bits, "offset to %s" % target)
    except AsmError as e:
        raise AsmError("line %d: %s" % (lineno, e))


def assemble_one(addr, mnemonic, args, labels, lineno):
    pc = addr + 1  # PUnC increments PC during fetch, before execute

    if mnemonic == '.FILL':
        v = labels[args[0]] if args[0] in labels else parse_num(args[0])
        return v & 0xFFFF

    if mnemonic == 'HALT':
        return OPCODES['HALT'] << 12

    if mnemonic == 'RET':
        return (OPCODES['JMP'] << 12) | (7 << 6)

    if mnemonic in ('ADD', 'AND'):
        dr, sr1 = parse_reg(args[0]), parse_reg(args[1])
        word = (OPCODES[mnemonic] << 12) | (dr << 9) | (sr1 << 6)
        if is_num(args[2]):
            return word | (1 << 5) | fit(parse_num(args[2]), 5, "imm5")
        return word | parse_reg(args[2])

    if mnemonic == 'NOT':
        dr, sr = parse_reg(args[0]), parse_reg(args[1])
        return (OPCODES['NOT'] << 12) | (dr << 9) | (sr << 6) | 0b111111

    if mnemonic in ('LD', 'LDI', 'LEA', 'ST', 'STI'):
        reg = parse_reg(args[0])
        off = offset_to(labels, args[1], pc, 9, lineno)
        return (OPCODES[mnemonic] << 12) | (reg << 9) | off

    if mnemonic in ('LDR', 'STR'):
        reg, base = parse_reg(args[0]), parse_reg(args[1])
        off = fit(parse_num(args[2]), 6, "offset6")
        return (OPCODES[mnemonic] << 12) | (reg << 9) | (base << 6) | off

    if mnemonic == 'JMP':
        return (OPCODES['JMP'] << 12) | (parse_reg(args[0]) << 6)

    if mnemonic == 'JSR':
        off = offset_to(labels, args[0], pc, 11, lineno)
        return (OPCODES['JSR'] << 12) | (1 << 11) | off

    if mnemonic == 'JSRR':
        return (OPCODES['JSR'] << 12) | (parse_reg(args[0]) << 6)

    if mnemonic.startswith('BR'):
        flags = mnemonic[2:].lower() or 'nzp'
        if not set(flags) <= set('nzp'):
            raise AsmError("line %d: bad branch %r" % (lineno, mnemonic))
        n, z, p = ('n' in flags), ('z' in flags), ('p' in flags)
        off = offset_to(labels, args[0], pc, 9, lineno)
        return (OPCODES['BR'] << 12) | (n << 11) | (z << 10) | (p << 9) | off

    raise AsmError("line %d: unknown mnemonic %r" % (lineno, mnemonic))


def assemble(source):
    labels, items = first_pass(source.splitlines())
    image = [0] * MEM_WORDS
    for addr, mnemonic, args, lineno in items:
        if addr >= MEM_WORDS:
            raise AsmError("line %d: address %d past end of image" % (lineno, addr))
        image[addr] = assemble_one(addr, mnemonic, args, labels, lineno)
    return image


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: asm.py <input.asm> <output.vmh>")
    with open(sys.argv[1]) as f:
        image = assemble(f.read())
    with open(sys.argv[2], 'w') as f:
        for word in image:
            f.write("%04x\n" % word)


if __name__ == '__main__':
    main()
