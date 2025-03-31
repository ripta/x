package main

import (
	"bufio"
	"errors"
	"fmt"
	"os"

	"github.com/ripta/x/lok/pkg/game"
)

func main() {
	if err := run(); err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}
}

func run() error {
	words := []string{"LOK"}
	grid := getInput()

	solutions, err := game.Solve(words, grid)
	if err != nil {
		return err
	}

	if len(solutions) == 0 {
		return errors.New("no solutions found")
	}

	fmt.Printf("Found %d solutions:\n", len(solutions))
	for i, solution := range solutions {
		fmt.Printf("Solution %d:\n", i+1)
		for j, move := range solution {
			fmt.Printf("  Move %d: (%d,%d) %s\n", j+1, move.Row+1, move.Col+1, string(grid.Tiles[move.Row][move.Col]))
		}
	}

	return nil
}

func getInput() *game.Grid {
	scanner := bufio.NewScanner(os.Stdin)
	var gridLines []string

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			break
		}
		gridLines = append(gridLines, line)
	}

	// Determine grid dimensions
	rows := len(gridLines)
	cols := 0
	for _, line := range gridLines {
		if len(line) > cols {
			cols = len(line)
		}
	}

	// Initialize grid
	grid := &game.Grid{
		Tiles:      make([][]rune, rows),
		Rows:       rows,
		Cols:       cols,
		UsedTiles:  make(map[game.Position]bool),
		ActiveWord: "",
	}

	// Fill the grid
	for i, line := range gridLines {
		grid.Tiles[i] = make([]rune, cols)
		for j := 0; j < cols; j++ {
			if j < len(line) {
				grid.Tiles[i][j] = rune(line[j])
			} else {
				grid.Tiles[i][j] = ' ' // Fill with spaces if row is shorter than max cols
			}
		}
	}

	fmt.Printf("Found grid:\n%v", grid)

	return grid
}
