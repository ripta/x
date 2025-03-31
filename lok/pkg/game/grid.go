package game

// Grid represents the game grid
type Grid struct {
	Tiles      [][]rune
	Rows       int
	Cols       int
	UsedTiles  map[Position]bool
	ActiveWord string
}

func (g *Grid) String() string {
	var result string
	for _, row := range g.Tiles {
		result += "\t[" + string(row) + "]\n"
	}
	return result
}

func (g *Grid) IsValid(pos Position) bool {
	return pos.Row >= 0 && pos.Row < g.Rows && pos.Col >= 0 && pos.Col < g.Cols && g.Tiles[pos.Row][pos.Col] != ' '
}

func (g *Grid) Done() bool {
	if g.ActiveWord != "" {
		return false
	}

	for row := 0; row < g.Rows; row++ {
		for col := 0; col < g.Cols; col++ {
			pos := Position{Row: row, Col: col}
			if g.IsValid(pos) && !g.UsedTiles[pos] {
				return false
			}
		}
	}

	return true
}

// Check if a word can be spelled starting from a position in a given direction
func (g *Grid) canSpellWord(word string, startRow, startCol, rowDir, colDir int) bool {
	if startRow < 0 || startRow >= g.Rows || startCol < 0 || startCol >= g.Cols {
		return false
	}

	for i, char := range word {
		row := startRow + i*rowDir
		col := startCol + i*colDir

		if row < 0 || row >= g.Rows || col < 0 || col >= g.Cols {
			return false
		}

		if g.Tiles[row][col] != char && g.Tiles[row][col] != '.' {
			return false
		}

		pos := Position{Row: row, Col: col}
		if g.UsedTiles[pos] {
			return false
		}
	}

	return true
}

// Create a copy of the grid
func (g *Grid) Copy() *Grid {
	newGrid := &Grid{
		Tiles:      make([][]rune, g.Rows),
		Rows:       g.Rows,
		Cols:       g.Cols,
		UsedTiles:  make(map[Position]bool),
		ActiveWord: g.ActiveWord,
	}

	// Copy tiles
	for i := 0; i < g.Rows; i++ {
		newGrid.Tiles[i] = make([]rune, g.Cols)
		copy(newGrid.Tiles[i], g.Tiles[i])
	}

	// Copy used tiles
	for pos, used := range g.UsedTiles {
		newGrid.UsedTiles[pos] = used
	}

	return newGrid
}
