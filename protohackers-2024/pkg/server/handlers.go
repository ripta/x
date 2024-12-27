package server

import (
	"context"
	"github.com/sourcegraph/conc/pool"
	"log/slog"
	"net"
)

type Handler func(context.Context, *slog.Logger, net.Conn)

type registration struct {
	Name              string
	Initializer       func(context.Context, *slog.Logger, *pool.ContextPool) error
	ConnectionHandler Handler
}
