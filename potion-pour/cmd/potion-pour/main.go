package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

// Represents the state of a test tube
type TestTube []rune

// Represents the state of the entire game
type GameState struct {
	tubes   []TestTube
	moves   []string
	size    int
	visited map[string]bool
}

// Create a copy of a test tube
func (t TestTube) copy() TestTube {
	newTube := make(TestTube, len(t))
	copy(newTube, t)
	return newTube
}

// Creates a copy of the game state
func (g GameState) copy() GameState {
	newTubes := make([]TestTube, len(g.tubes))
	for i, tube := range g.tubes {
		newTubes[i] = tube.copy()
	}

	newMoves := make([]string, len(g.moves))
	copy(newMoves, g.moves)

	return GameState{
		tubes:   newTubes,
		moves:   newMoves,
		size:    g.size,
		visited: g.visited, // Share the same visited map
	}
}

// Check if a tube is complete (all segments have the same color)
func (t TestTube) isComplete() bool {
	if len(t) == 0 {
		return true
	}

	firstColor := t[0]
	for _, color := range t {
		if color != firstColor {
			return false
		}
	}
	return len(t) == cap(t)
}

// Check if the game is won
func (g GameState) isWon() bool {
	for _, tube := range g.tubes {
		if !tube.isComplete() && len(tube) > 0 {
			return false
		}
	}
	return true
}

// Check if there are any valid moves left
func (g GameState) hasValidMoves() bool {
	for i := range g.tubes {
		for j := range g.tubes {
			if i != j && g.canPour(i, j) {
				return true
			}
		}
	}
	return false
}

// Check if we can pour from source to target
func (g GameState) canPour(sourceIdx, targetIdx int) bool {
	source := g.tubes[sourceIdx]
	target := g.tubes[targetIdx]

	// If source is empty or complete, can't pour
	if len(source) == 0 || source.isComplete() {
		return false
	}

	// If target is complete or full, can't pour
	if target.isComplete() || len(target) >= g.size {
		return false
	}

	// Get the color at the top of the source
	sourceColor := source[len(source)-1]

	// If target is empty, we can pour
	if len(target) == 0 {
		return true
	}

	// Check if the top color of target matches the top color of source
	targetColor := target[len(target)-1]
	return sourceColor == targetColor && len(target) < g.size
}

// Pour from source to target
func (g *GameState) pour(sourceIdx, targetIdx int) bool {
	if !g.canPour(sourceIdx, targetIdx) {
		return false
	}

	source := &g.tubes[sourceIdx]
	target := &g.tubes[targetIdx]

	// Find the color to pour
	colorToPour := (*source)[len(*source)-1]

	// Count how many segments of this color are at the top of source
	countToPour := 0
	for i := len(*source) - 1; i >= 0; i-- {
		if (*source)[i] == colorToPour {
			countToPour++
		} else {
			break
		}
	}

	// Calculate how many we can actually pour (limited by target capacity)
	canPour := min(countToPour, g.size-len(*target))

	// Pour the segments
	for i := 0; i < canPour; i++ {
		*target = append(*target, colorToPour)
		*source = (*source)[:len(*source)-1]
	}

	// Add the move to our list
	g.moves = append(g.moves, fmt.Sprintf("%d %d", sourceIdx+1, targetIdx+1))

	return true
}

// Generate a unique key for a game state to avoid revisiting
func (g GameState) key() string {
	var sb strings.Builder
	for _, tube := range g.tubes {
		sb.WriteString(string(tube))
		sb.WriteRune('|')
	}
	return sb.String()
}

// Solve the game using breadth-first search
func solve(initial GameState) []string {
	// Initialize the visited map in the initial state
	initial.visited = map[string]bool{}

	queue := []GameState{initial}
	initial.visited[initial.key()] = true

	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]

		if current.isWon() {
			return current.moves
		}

		if !current.hasValidMoves() {
			continue
		}

		for i := range current.tubes {
			for j := range current.tubes {
				if i != j && current.canPour(i, j) {
					nextState := current.copy()
					nextState.pour(i, j)

					key := nextState.key()
					if !nextState.visited[key] {
						nextState.visited[key] = true
						queue = append(queue, nextState)
					}
				}
			}
		}
	}

	return nil // No solution found
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)

	// Read the tube size
	scanner.Scan()
	var tubeSize int
	fmt.Sscanf(scanner.Text(), "%d", &tubeSize)

	// Read the tube contents
	var tubes []TestTube
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}

		// Remove brackets
		content := strings.Trim(line, "[]")
		tube := make(TestTube, 0, tubeSize)

		// Add each color to the tube
		for _, c := range content {
			tube = append(tube, c)
		}

		tubes = append(tubes, tube)
	}

	// Create the initial game state
	initialState := GameState{
		tubes: tubes,
		moves: []string{},
		size:  tubeSize,
	}

	// Solve the game
	solution := solve(initialState)

	// Print the solution
	for _, move := range solution {
		fmt.Println(move)
	}
}
