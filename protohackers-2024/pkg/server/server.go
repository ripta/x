package server

import (
	"context"
	"errors"
	"github.com/sourcegraph/conc/pool"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"strconv"
	"sync"
	"syscall"
	"time"

	"github.com/spf13/cobra"
)

type server struct {
	addr     string
	handlers []registration
}

func New() *cobra.Command {
	bsc := NewBudgetChatServer()

	s := &server{
		addr: "0.0.0.0:8080",
		handlers: []registration{
			{"echo", nil, Echo},                             // Problem 0
			{"prime_time", nil, PrimeTime},                  // Problem 1
			{"means_to_an_end", nil, MeansToAnEnd},          // Problem 2
			{"budget_chat", bsc.Init, bsc.HandleConnection}, // Problem 3
		},
	}

	c := &cobra.Command{
		Use:           "server",
		SilenceErrors: true,
		SilenceUsage:  true,
		RunE: func(cmd *cobra.Command, args []string) error {
			return s.Run(cmd.Context())
		},
	}

	c.Flags().StringVar(&s.addr, "addr", s.addr, "address to start listens on")

	return c
}

func (s *server) Run(ctx context.Context) error {
	ctx, cancel := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM, syscall.SIGHUP)
	defer cancel()

	logger := slog.New(slog.NewTextHandler(os.Stderr, nil))

	host, port, err := net.SplitHostPort(s.addr)
	if err != nil {
		return err
	}

	iPort, err := strconv.ParseInt(port, 10, 64)
	if err != nil {
		return err
	}

	p := pool.New().WithContext(ctx).WithCancelOnError().WithFirstError()
	for i := range s.handlers {
		handler := s.handlers[i]
		addr := net.JoinHostPort(host, strconv.Itoa(int(iPort)+i))

		logger := logger.With(slog.String("server", handler.Name))
		logger.Info("mounting server")

		if hi := handler.Initializer; hi != nil {
			logger.Info("initializing")
			if err := hi(ctx, logger, p); err != nil {
				logger.ErrorContext(ctx, "failed to initialize", slog.Any("error", err))
				return err
			}
		}

		p.Go(func(ctx context.Context) error {
			cfg := net.ListenConfig{}
			listener, err := cfg.Listen(ctx, "tcp", addr)
			if err != nil {
				logger.ErrorContext(ctx, "failed to listen", slog.Any("error", err))
				return err
			}

			logger.Info("listening", slog.String("listen_addr", listener.Addr().String()))
			go start(ctx, logger, listener, handler.ConnectionHandler)

			<-ctx.Done()
			return listener.Close()
		})
	}

	logger.Info("servers started; waiting for exit")
	if err := p.Wait(); !errors.Is(err, context.Canceled) {
		return err
	}
	return nil
}

func start(ctx context.Context, logger *slog.Logger, listener net.Listener, hnd Handler) {
	wg := sync.WaitGroup{}
	for {
		conn, err := listener.Accept()
		if err != nil {
			select {
			case <-ctx.Done():
				if !errors.Is(ctx.Err(), context.Canceled) {
					logger.Error("context done", slog.Any("error", ctx.Err()))
				}
				break
			default:
				logger.Error("failed to accept connection", slog.Any("error", err))
			}
			continue
		}

		logger.Info("accepted connection")
		wg.Add(1)
		go func() {
			defer wg.Done()
			t0 := time.Now()

			ctx, cancel := context.WithTimeout(ctx, 6*time.Minute)
			defer cancel()

			logger := logger.With(slog.String("remote_addr", conn.RemoteAddr().String()))
			defer conn.Close()

			conn.SetDeadline(time.Now().Add(5 * time.Minute))
			hnd(ctx, logger, conn)

			logger.Info("completed request", slog.Duration("duration", time.Since(t0)))
		}()
	}

	logger.Info("waiting for connections to close")
	wg.Wait()

	logger.Info("all connections closed")
}
