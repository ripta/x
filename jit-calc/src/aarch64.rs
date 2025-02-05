use std::fmt;
use std::fmt::{Debug, Display, Formatter};

const FP: u8 = 29;
const LR: u8 = 30;
const SP: u8 = 31;

// Assembly instructions for AArch64
pub struct Assembly {
    instructions: Vec<u8>,
}

impl Assembly {
    pub fn new() -> Assembly {
        Assembly {
            instructions: Vec::new(),
        }
    }

    fn write(&mut self, instruction: u32) {
        self.instructions.append(&mut instruction.to_le_bytes().to_vec());
    }

    pub fn as_mapmut(&self) -> memmap::MmapMut {
        let mut mm = memmap::MmapMut::map_anon(self.instructions.len()).unwrap();
        mm.clone_from_slice(self.instructions.as_slice());
        return mm;
    }

    // Calling convention https://mariokartwii.com/armv8/ch26.html
    pub fn restore_registers(&mut self) {
        self.ldp64(FP, LR, SP, 32); // ldp x29, x30, [sp, #16]
        self.add64(SP, SP, 32); // add x29, sp, #32
    }

    // Calling convention https://mariokartwii.com/armv8/ch26.html
    pub fn save_registers(&mut self) {
        self.sub64(SP, SP, 32); // sub sp, sp, #32
        self.stp64(FP, LR, SP, 32); // stp x29, x30, [sp, #16]
    }

    // ADD - Add (immediate)
    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/ADD--immediate---Add-immediate-value-?lang=en
    //
    // bits: 1__0__0_100010_0__000000000000_00000_00000
    //      sf op  S        sh imm12        Rn    Rd
    pub fn add64(&mut self, rd: u8, rn: u8, imm12: u16) {
        let mut val : u32 = 0b1 << 31;
        val |= 0b0 << 30;
        val |= 0b100010 << 23;
        val |= 0b0 << 22; // sh
        val |= (imm12 as u32) << 10;
        val |= (rn as u32) << 5;
        val |= rd as u32;

        self.write(val);
    }

    // LDP - Load Pair of Registers
    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/LDP--Load-pair-of-registers-?lang=en
    //
    // bits: 1__0101_0__010_1_0000000_00000_00000_00000
    //       opc     VR enc L imm7    Rt2   Rn    Rt1
    // idx:  1__0987_6__543_2_1098765_43210_98765_43210
    //          3              2          1           0
    //
    // opc = 0 for 32-bit
    //       1 for 64-bit
    // encoding class = 001 for post-index
    //                  011 for pre-index
    //                  010 for signed offset <-- this function
    // L = 1 for load; see also STP
    pub fn ldp64(&mut self, rt1: u8, rt2: u8, rn: u8, imm7: u8) {
        let mut val : u32 = 0x01 << 31;
        val |= 0x05 << 27;
        val |= 0x02 << 23;
        val |= 0x01 << 22;

        let offset = imm7 >> 3; // offset is a multiple of 8 bits encoded as imm7 / 8
        val |= (offset as u32) << 15;

        val |= (rt2 as u32) << 10;
        val |= (rn as u32) << 5;
        val |= rt1 as u32;

        self.write(val);
    }

    // LSL - Logical Shift Left (immediate)
    // LSL Rd, Rn, sh
    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/LSL--immediate---Logical-shift-left--immediate---an-alias-of-UBFM-?lang=en
    //
    // bits: 1__1__0100110_1_000000_000000_00000_00000
    //       sf op         N immr   imms   Rn    Rd
    //
    // sf = 1 for 64-bit, 0 for 32-bit
    // op = 1
    // N = 1 for 64-bit, 0 for 32-bit
    //
    // immr = -sh mod 64
    // imms = 63 - sh
    pub fn lsl64(&mut self, rd: u8, rn: u8, sh: u8) {
        let immr = (64 - sh) as u32;
        let imms = (63 - sh) as u32;

        let mut val : u32 = 0b1 << 31;
        val |= 0b1 << 30;
        val |= 0b0100110 << 23;
        val |= 0b1 << 22;
        val |= immr << 16;
        val |= imms << 10;
        val |= (rn as u32) << 5;
        val |= rd as u32;

        self.write(val);
    }

    // LSR - Logical Shift Right (immediate)
    // LSR Rd, Rn, sh
    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/LSR--immediate---Logical-shift-right--immediate---an-alias-of-UBFM-?lang=en
    //
    // bits: 1__1__0100110_1_000000_000000_00000_00000
    //       sf op         N immr   imms   Rn    Rd
    //
    // sf = 1 for 64-bit, 0 for 32-bit
    // op = 1
    // N = 1 for 64-bit, 0 for 32-bit
    //
    // immr = -sh mod 64
    // imms = 63 - sh
    pub fn lsr64(&mut self, rd: u8, rn: u8, sh: u8) {
        let immr = sh as u32;
        let imms = 0b111111;

        let mut val : u32 = 0b1 << 31;
        val |= 0b1 << 30;
        val |= 0b0100110 << 23;
        val |= 0b1 << 22;
        val |= immr << 16;
        val |= imms << 10;
        val |= (rn as u32) << 5;
        val |= rd as u32;

        self.write(val);
    }

    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/RET--Return-from-subroutine-?lang=en
    // bits: 1101011_0010_11111_000000_xxxxx_00000 = 0xd65f_0000
    //                                 Rn
    //
    // Rn = x30 = 30 in bits 5-9
    //
    // ret x30 = 0xd65f << 16 | (30 << 5) = 0xd65f_03c0
    pub fn ret(&mut self) {
        let mut val : u32 = 0xd65f << 16;
        val |= 30 << 5;

        self.write(val);
    }

    // STP - Store Pair of Registers
    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/STP--Store-pair-of-registers-?lang=en
    //
    // bits: 1__0101_0__001_0_0000000_00000_00000_00000
    //       1__0101_0__010_0_0000101_11101_11111_11010
    //       opc     VR enc L imm7    Rt2   Rn    Rt1
    // idx:  1__0987_6__543_2_1098765_43210_98765_43210
    //          3              2          1           0
    //
    // opc = 0 for 32-bit
    //       1 for 64-bit
    // encoding class = 001 for post-index
    //                  011 for pre-index
    //                  010 for signed offset <-- this function
    // L = 0 for store; see also LDP
    pub fn stp64(&mut self, rt1: u8, rt2: u8, rn: u8, imm7: u8) {
        let mut val: u32 = 0x01 << 31;
        val |= 0x05 << 27;
        val |= 0x02 << 23;
        val |= 0x00 << 22;

        let offset = imm7 >> 3; // offset is a multiple of 8 bits encoded as imm7 / 8
        val |= (offset as u32) << 15;

        val |= (rt2 as u32) << 10;
        val |= (rn as u32) << 5;
        val |= rt1 as u32;

        self.write(val);
    }

    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/SUB--immediate---Subtract-immediate-value-?lang=en
    // bits: 0__1__0_10001_00_000000000000_00000_00000
    //      sf op  S       sh imm12        Rn    Rd
    pub fn sub32(&mut self, rd: u8, rn: u8, imm12: u16) {
        let mut val : u32 = 0xa2 << 23;
        val |= (imm12 as u32) << 10;
        val |= (rn as u32) << 5;
        val |= rd as u32;

        self.write(val);
    }

    // https://developer.arm.com/documentation/ddi0602/2024-12/Base-Instructions/SUB--immediate---Subtract-immediate-value-?lang=en
    // bits: 1__1__0_100010_0__000000000000_00000_00000
    //      sf op  S        sh imm12        Rn    Rd
    pub fn sub64(&mut self, rd: u8, rn: u8, imm12: u16) {
        let mut val : u32 = 0b1 << 31;
        val |= 0b1 << 30;
        val |= 0b100010 << 23;
        val |= 0b0 << 22; // sh

        val |= (imm12 as u32) << 10;
        val |= (rn as u32) << 5;
        val |= rd as u32;

        self.write(val);
    }
}

impl Debug for Assembly {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        f.debug_list().entries(self.instructions.iter().map(|b| format!("0x{:02x}", b))).finish()
    }
}

impl Default for Assembly {
    fn default() -> Self {
        Self::new()
    }
}

impl Display for Assembly {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        let instrs = self.instructions.chunks(4).map(|c|
            c.iter().map(|b| format!("0x{:02x}", b)).collect::<Vec<String>>().join(" ")
        ).collect::<Vec<String>>().join(",\n  ");
        return write!(f, "[\n  {},\n]", instrs);
    }
}

impl PartialEq<Vec<u8>> for Assembly {
    fn eq(&self, other: &Vec<u8>) -> bool {
        self.instructions == *other
    }
}

impl PartialEq<Assembly> for Vec<u8> {
    fn eq(&self, other: &Assembly) -> bool {
        other == self
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn assembly_new() {
        let mut asm = Assembly::new();
        asm.write(0x0105090d);

        assert_eq!(vec![0x0d, 0x09, 0x05, 0x01], asm.instructions);
        assert_eq!(vec![0x0d, 0x09, 0x05, 0x01], asm);

        let mm = asm.as_mapmut();
        assert_eq!(vec![0x0d, 0x09, 0x05, 0x01], mm.to_vec());
    }

    #[test]
    fn add64() {
        let mut asm = Assembly::new();
        asm.add64(0, 1, 2);

        assert_eq!(vec![0x20, 0x08, 0x00, 0x91], asm);
    }

    #[test]
    fn sub32() {
        let mut asm = Assembly::new();
        asm.sub32(0, 0, 12);

        assert_eq!(vec![0x00, 0x30, 0x00, 0x51], asm);
    }

    #[test]
    fn sub64() {
        let mut asm = Assembly::new();
        asm.sub64(0, 0, 12);

        assert_eq!(vec![0x00, 0x30, 0x00, 0xd1], asm);
    }
}