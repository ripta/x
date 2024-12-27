package server

import (
	"context"
	"io"
	"log/slog"
	"net"
)

// Echo is an implementation of https://protohackers.com/problem/0.
func Echo(ctx context.Context, log *slog.Logger, conn net.Conn) {
	n, err := io.Copy(conn, conn)
	if err != nil {
		log.ErrorContext(ctx, "failed to copy", slog.Any("error", err))
		return
	}

	log.InfoContext(ctx, "ok", slog.Int64("bytes", n))
}
