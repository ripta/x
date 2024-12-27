package main

import (
	"context"
	"fmt"
	"os"

	"github.com/ripta/x/protohackers-2024/pkg/server"
)

func main() {
	if err := server.New().ExecuteContext(context.Background()); err != nil {
		fmt.Printf("error: %v\n", err)
		os.Exit(1)
	}
}
