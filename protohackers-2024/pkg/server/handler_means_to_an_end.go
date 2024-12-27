package server

import (
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
)

// MeansToAnEnd is an implementation of https://protohackers.com/problem/2.
func MeansToAnEnd(ctx context.Context, log *slog.Logger, conn net.Conn) {
	data := map[int32]int32{}

	for {
		in := make([]byte, 9)
		if _, err := io.ReadFull(conn, in); err != nil {
			if !errors.Is(err, io.EOF) {
				log.ErrorContext(ctx, "failed to read", slog.Any("error", err))
			}
			return
		}

		switch in[0] {
		case 'I':
			ts := binary.BigEndian.Uint32(in[1:5])
			price := binary.BigEndian.Uint32(in[5:])
			data[int32(ts)] = int32(price)
		case 'Q':
			mintime := int32(binary.BigEndian.Uint32(in[1:5]))
			maxtime := int32(binary.BigEndian.Uint32(in[5:]))

			total := 0
			count := 0
			for ts, price := range data {
				if ts >= mintime && ts <= maxtime {
					total += int(price)
					count++
				}
			}

			avg := 0
			if count > 0 {
				avg = total / count
			}

			out := make([]byte, 4)
			binary.BigEndian.PutUint32(out, uint32(avg))

			n, err := conn.Write(out)
			if err != nil {
				log.ErrorContext(ctx, "failed to write", slog.Any("error", err))
				continue
			}

			log.InfoContext(ctx, "query", slog.Int64("write_bytes", int64(n)), slog.String("query", fmt.Sprintf("Q[%d:%d] = %d", mintime, maxtime, avg)))
		default:
			log.ErrorContext(ctx, "unknown command", slog.String("command", string(in[0])))
		}
	}
}
