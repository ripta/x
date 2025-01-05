
// Scratch module to easily dump AArch64 assembly instructions
//
//   cargo clean; cargo build; objdump -d target/debug/deps/*.o | less
//
// and look for "<_compute>:" (without quotes). I tried `cargo asm`
// (cargo-show-asm) but it doesn't show the raw bytes, even with --disasm.
#[no_mangle]
pub fn compute(mut accumulator: i64) -> i64 {
    // b2c: 91 00 05 08  add     x8, x8, #1
    // b38: 91 00 05 08  add     x8, x8, #1
    // b44: d3 7f f9 08  lsl     x8, x8, #1
    // b50: f1 00 05 08  subs    x8, x8, #1
    // b5c: 93 41 fd 08  asr     x8, x8, #1
    accumulator += 1;
    accumulator += 1;
    accumulator <<= 1;
    accumulator -= 1;
    accumulator >>= 1;
    return accumulator;
}
