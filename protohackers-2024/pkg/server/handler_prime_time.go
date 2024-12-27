package server

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"github.com/fxtlabs/primes"
	"log/slog"
	"math"
	"net"
)

type PrimeTimeRequest struct {
	Method string   `json:"method"`
	Number *float64 `json:"number"`
}

type PrimeTimeResponse struct {
	Method string `json:"method"`
	Prime  *bool  `json:"prime"`
	Error  string `json:"error,omitempty"`
}

// PrimeTime is an implementation of https://protohackers.com/problem/1.
func PrimeTime(ctx context.Context, log *slog.Logger, conn net.Conn) {
	handleError := func(msg string, attrs ...any) {
		log.ErrorContext(ctx, msg, attrs...)

		n, err := conn.Write(append([]byte(msg), '\n'))
		if err != nil {
			log.ErrorContext(ctx, "failed to write response", slog.Any("error", err))
		}

		log.InfoContext(ctx, "ok", slog.Int("bytes", n))
	}

	scanner := bufio.NewScanner(conn)
	scanner.Split(bufio.ScanLines)

	i := 0
	for scanner.Scan() {
		i++

		raw := scanner.Bytes()
		// fmt.Printf("-> raw #%d: %s\n", i, string(raw))

		req := PrimeTimeRequest{}
		if err := json.Unmarshal(raw, &req); err != nil {
			handleError("failed to decode request", slog.Any("error", err))
			continue
		}

		if req.Method != "isPrime" {
			handleError("invalid method", nil, slog.String("method", req.Method))
			continue
		}

		prime, err := isPrime(req.Number)
		if err != nil {
			handleError("failed to check if number is prime", slog.Any("error", err))
			continue
		}

		res := PrimeTimeResponse{
			Method: req.Method,
			Prime:  &prime,
		}

		out, err := json.Marshal(&res)
		if err != nil {
			log.ErrorContext(ctx, "failed to encode response", slog.Any("error", err))
			continue
		}

		n, err := conn.Write(append(out, '\n'))
		if err != nil {
			log.ErrorContext(ctx, "failed to write response", slog.Any("error", err))
			continue
		}

		log.InfoContext(ctx, "ok", slog.Bool("prime", prime), slog.Int("bytes", n))
	}
}

func isPrime(n *float64) (bool, error) {
	if n == nil {
		return false, errors.New("number is nil")
	}

	fv := *n
	if iv := math.Trunc(fv); iv == fv {
		return primes.IsPrime(int(iv)), nil
	}

	return false, nil
}
