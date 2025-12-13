# Provide input string or path to file:
"1abc2\npqr3stu8vwx\na1b2c3d4e5f\ntreb7uchet\n"
# &fras "../../aux/aoc-2023/day-01/input-test-a.txt"
# &fras "../../aux/aoc-2023/day-01/input-final.txt"

# Split string on newlines:
⟜∘
≠@\n
⊜□

# With deprecated dyadic 2-output flip (uiua<0.18), for each row:
# - Subtract ASCII '0', e.g., '9' -> 9
# - Keep only values less than 10 (discard non-numbers)
# - Take first value of row and multiply that by 10
# - Take last value of row and add to above value
≡(+⊣ : ×10⊢⟜∘ ▽<10⟜∘ -@0 °□)

# With experimental monadic backward (uiua>=0.18):
# ≡(+ ˜⊣ ×10⊢⟜∘ ▽<10⟜∘ -@0°□)

# Sum all rows for final answer:
/+
