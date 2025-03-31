package game

import "fmt"

func Solve(words []string, grid *Grid) ([]Solution, error) {
	solutions := []Solution{}
	solution := Solution{}

	solveRecursive(grid, words, solution, &solutions)
	if len(solutions) == 0 {
		return nil, fmt.Errorf("no solution exists for the given grid and words")
	}

	return solutions, nil
}

func solveRecursive(g *Grid, words []string, currentSolution Solution, solutions *[]Solution) {
	if g.Done() {
		solutionCopy := make(Solution, len(currentSolution))
		copy(solutionCopy, currentSolution)
		*solutions = append(*solutions, solutionCopy)
		return
	}

	// If there's an active word, try to deactivate it
	if g.ActiveWord != "" {
		for row := 0; row < g.Rows; row++ {
			for col := 0; col < g.Cols; col++ {
				pos := Position{Row: row, Col: col}
				if g.IsValid(pos) && !g.UsedTiles[pos] {
					gridCopy := g.Copy()
					gridCopy.UsedTiles[pos] = true
					gridCopy.ActiveWord = "" // Deactivate the word

					updatedSolution := append(currentSolution, pos)
					solveRecursive(gridCopy, words, updatedSolution, solutions)
				}
			}
		}

		return
	}

	// Try to activate a word
	for _, word := range words {
		// Try horizontal (left to right)
		for row := 0; row < g.Rows; row++ {
			for col := 0; col <= g.Cols-len(word); col++ {
				if g.canSpellWord(word, row, col, 0, 1) {
					solutionMoves := Solution{}
					gridCopy := g.Copy()

					// Use tiles to spell the word
					for i := range word {
						pos := Position{Row: row, Col: col + i}
						gridCopy.UsedTiles[pos] = true
						solutionMoves = append(solutionMoves, pos)
					}

					// Set the active word
					gridCopy.ActiveWord = word

					// Continue recursively
					updatedSolution := append(currentSolution, solutionMoves...)
					solveRecursive(gridCopy, words, updatedSolution, solutions)
				}
			}
		}

		// Try horizontal (right to left)
		for row := 0; row < g.Rows; row++ {
			for col := g.Cols - 1; col >= len(word)-1; col-- {
				if g.canSpellWord(word, row, col, 0, -1) {
					solutionMoves := Solution{}
					gridCopy := g.Copy()

					// Use tiles to spell the word
					for i := range word {
						pos := Position{Row: row, Col: col - i}
						gridCopy.UsedTiles[pos] = true
						solutionMoves = append(solutionMoves, pos)
					}

					// Set the active word
					gridCopy.ActiveWord = word

					// Continue recursively
					updatedSolution := append(currentSolution, solutionMoves...)
					solveRecursive(gridCopy, words, updatedSolution, solutions)
				}
			}
		}

		// Try vertical (top to bottom)
		for col := 0; col < g.Cols; col++ {
			for row := 0; row <= g.Rows-len(word); row++ {
				if g.canSpellWord(word, row, col, 1, 0) {
					solutionMoves := Solution{}
					gridCopy := g.Copy()

					// Use tiles to spell the word
					for i := range word {
						pos := Position{Row: row + i, Col: col}
						gridCopy.UsedTiles[pos] = true
						solutionMoves = append(solutionMoves, pos)
					}

					// Set the active word
					gridCopy.ActiveWord = word

					// Continue recursively
					updatedSolution := append(currentSolution, solutionMoves...)
					solveRecursive(gridCopy, words, updatedSolution, solutions)
				}
			}
		}

		// Try vertical (bottom to top)
		for col := 0; col < g.Cols; col++ {
			for row := g.Rows - 1; row >= len(word)-1; row-- {
				if g.canSpellWord(word, row, col, -1, 0) {
					solutionMoves := Solution{}
					gridCopy := g.Copy()

					// Use tiles to spell the word
					for i := range word {
						pos := Position{Row: row - i, Col: col}
						gridCopy.UsedTiles[pos] = true
						solutionMoves = append(solutionMoves, pos)
					}

					// Set the active word
					gridCopy.ActiveWord = word

					// Continue recursively
					updatedSolution := append(currentSolution, solutionMoves...)
					solveRecursive(gridCopy, words, updatedSolution, solutions)
				}
			}
		}
	}
}
