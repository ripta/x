mod aarch64;
mod experiment;

use std::mem;
use memmap;
use aarch64::Assembly;

fn main() {
    let programs = vec![
        ("+ + + + +", 5),
        ("- -", -2),
        ("foo", 0),
        ("+ + * - /", 1),
        ("+ * + * - + * + *", 26),
    ];

    programs.iter().enumerate().for_each(|(i, (program, expected))| {
        println!("Program #{} is: {}", i, program);
        println!("  Expected result: {}", expected);

        let interpreted = eval(0, program);
        println!("The interpreted program calculated the value {}", interpreted);
        assert_eq!(interpreted, *expected);

        let compiled = jit(program);
        // println!("JIT instructions: {}", compiled);
        let compiled_result = run(0, compiled);
        println!("The JIT-compiled program calculates the value {}", compiled_result);
        assert_eq!(interpreted, compiled_result);

        println!();
    });
}

// Evaluates a simple program that consists of the following tokens:
//
// `+` or `-` means add or subtract by 1
// `*` or `/` means multiply or divide with truncation by 2
fn eval(mut accumulator: i32, program: &str) -> i32 {
    for token in program.chars() {
        match token {
            '+' => accumulator += 1,
            '-' => accumulator -= 1,
            '*' => accumulator *= 2,
            '/' => accumulator /= 2,
            _ => { /* ignore everything else */ }
        }
    }

    return accumulator;
}

// JIT compiles a simple program and returns a vector of instructions
// targeting AArch64 architecture.
fn jit(program: &str) -> Assembly {
    let mut asm = Assembly::new();
    asm.save_registers();

    // symbolic repr of the first register
    let x0 = 0;

    for token in program.chars() {
        match token {
            '+' => asm.add64(x0, x0, 1),
            '-' => asm.sub64(x0, x0, 1),
            '*' => asm.lsl64(x0, x0, 1),
            '/' => asm.lsr64(x0, x0, 1),
            _ => { /* ignore everything else */ }
        }
    }

    asm.restore_registers();
    asm.ret();
    return asm;
}

fn run(starting_value: i32, asm: Assembly) -> i32 {
    let ex = asm.to_map_mut().make_exec().unwrap(); // retain region
    let fp = ex.as_ptr();
    let f: extern "C" fn(i32) -> i32  = unsafe { mem::transmute(fp) };
    return f(starting_value);
}
