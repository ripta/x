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
	tubes []TestTube
	moves []string
	size  int
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
		tubes: newTubes,
		moves: newMoves,
		size:  g.size,
	}
}

// Check if a tube is complete (all segments have the same color or empty)
func (t TestTube) isComplete(tubeSize int) bool {
	if len(t) == 0 {
		return true
	}

	if len(t) != tubeSize {
		return false
	}

	firstColor := t[0]
	for _, color := range t {
		if color != firstColor {
			return false
		}
	}
	return true
}

// Check if the game is won
func (g GameState) isWon() bool {
	for _, tube := range g.tubes {
		if len(tube) > 0 && !tube.isComplete(g.size) {
			return false
		}
	}
	return true
}

// Get the top color of a tube and count of that color at the top
func getTopColorInfo(tube TestTube) (rune, int) {
	if len(tube) == 0 {
		return 0, 0
	}

	color := tube[len(tube)-1]
	count := 0

	for i := len(tube) - 1; i >= 0; i-- {
		if tube[i] == color {
			count++
		} else {
			break
		}
	}

	return color, count
}

// Check if we can pour from source to target
func canPour(source, target TestTube, tubeSize int) bool {
	// If source is empty, can't pour
	if len(source) == 0 {
		return false
	}

	// If target is full, can't pour
	if len(target) >= tubeSize {
		return false
	}

	// If source is complete with all same color filling the tube, don't pour
	if len(source) == tubeSize && source.isComplete(tubeSize) {
		return false
	}

	// If target is empty, we can pour
	if len(target) == 0 {
		return true
	}

	// Get top colors
	sourceColor, _ := getTopColorInfo(source)
	targetColor, _ := getTopColorInfo(target)

	// Check if colors match
	return sourceColor == targetColor
}

// Pour from source to target
func pour(source, target *TestTube, tubeSize int) int {
	if !canPour(*source, *target, tubeSize) {
		return 0
	}

	// Get top color and count
	sourceColor, sourceCount := getTopColorInfo(*source)

	// Calculate how many we can actually pour (limited by target capacity)
	canPourCount := min(sourceCount, tubeSize-len(*target))

	// Pour the segments
	for i := 0; i < canPourCount; i++ {
		*target = append(*target, sourceColor)
		*source = (*source)[:len(*source)-1]
	}

	return canPourCount
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
	queue := []GameState{initial}
	visited := make(map[string]bool)
	visited[initial.key()] = true

	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]

		// Check if we've won
		if current.isWon() {
			return current.moves
		}

		// Try all possible moves
		for i := range current.tubes {
			for j := range current.tubes {
				if i == j {
					continue
				}

				if canPour(current.tubes[i], current.tubes[j], current.size) {
					// Create a new state
					next := current.copy()

					// Pour from tube i to tube j
					poured := pour(&next.tubes[i], &next.tubes[j], next.size)

					if poured > 0 {
						// Record the move
						next.moves = append(next.moves, fmt.Sprintf("%d %d", i+1, j+1))

						// Check if we've seen this state before
						key := next.key()
						if !visited[key] {
							visited[key] = true
							queue = append(queue, next)
						}
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
	if solution == nil {
		fmt.Println("No solution found")
	} else {
		for i, move := range solution {
			fmt.Printf("%03d: %+v\n", i+1, move)
		}
		fmt.Printf("Total moves: %d\n", len(solution))
	}
}
