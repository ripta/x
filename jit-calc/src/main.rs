
fn main() {
    let program = "+ + * - /";
    let interpreted = eval(0, program);
    println!("The program \"{}\" calculates the value {}",
             program, interpreted);
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
