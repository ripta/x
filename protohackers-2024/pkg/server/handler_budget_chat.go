package server

import (
	"bufio"
	"context"
	"github.com/sourcegraph/conc/pool"
	"log/slog"
	"net"
	"regexp"
	"strings"
)

type BudgetChatMessage struct {
	Username string
	Message  string
}

type BudgetChatSession struct {
	Connection net.Conn
	Username   string
}

type BudgetChatServer struct {
	joinCh  chan BudgetChatSession
	leaveCh chan string

	messageCh chan BudgetChatMessage
}

var (
	UsernameValidator = regexp.MustCompile("^[a-zA-Z0-9]{1,16}$")
)

func NewBudgetChatServer() *BudgetChatServer {
	return &BudgetChatServer{
		joinCh:    make(chan BudgetChatSession),
		leaveCh:   make(chan string),
		messageCh: make(chan BudgetChatMessage),
	}
}

func (cs *BudgetChatServer) HandleConnection(ctx context.Context, log *slog.Logger, conn net.Conn) {
	welcomeMsg := []byte("Welcome to BudgetChat! Please enter your username:\n")
	if _, err := conn.Write(welcomeMsg); err != nil {
		log.ErrorContext(ctx, "failed to write welcome message", slog.Any("error", err))
		return
	}

	scanner := bufio.NewScanner(conn)
	scanner.Split(bufio.ScanLines)
	if !scanner.Scan() {
		log.ErrorContext(ctx, "failed to read username")
		return
	}

	username := scanner.Text()
	if !UsernameValidator.MatchString(username) {
		log.ErrorContext(ctx, "invalid username", slog.String("username", username))
		return
	}

	cs.joinCh <- BudgetChatSession{
		Connection: conn,
		Username:   username,
	}

	defer func() {
		log.Info("user leaving", slog.String("username", username))
		cs.leaveCh <- username
	}()

	for scanner.Scan() {
		cs.messageCh <- BudgetChatMessage{
			Username: username,
			Message:  scanner.Text(),
		}
	}
}

func (cs *BudgetChatServer) Init(_ context.Context, log *slog.Logger, pool *pool.ContextPool) error {
	pool.Go(func(ctx context.Context) error {
		cs.Process(ctx, log)
		log.Info("server shutdown")
		return nil
	})

	return nil
}

func (cs *BudgetChatServer) Process(ctx context.Context, log *slog.Logger) {
	sessions := map[string]net.Conn{}
	for {
		select {
		case <-ctx.Done():
			return

		case session := <-cs.joinCh:
			if _, ok := sessions[session.Username]; ok {
				log.Error("username already taken", slog.String("username", session.Username))
				continue
			}

			broadcast(ctx, log, sessions, []byte("* "+session.Username+" has entered the room\n"))

			users := []string{}
			for username := range sessions {
				users = append(users, username)
			}

			sessions[session.Username] = session.Connection
			if _, err := session.Connection.Write([]byte("* The room contains: " + strings.Join(users, ", ") + "\n")); err != nil {
				log.Error("failed to send users list", slog.Any("error", err))
			}

			log.Info("user joined", slog.String("username", session.Username))

		case username := <-cs.leaveCh:
			log.Info("user left", slog.String("username", username))
			delete(sessions, username)
			broadcast(ctx, log, sessions, []byte("* "+username+" has left the room\n"))

		case msg := <-cs.messageCh:
			log.Info("message received", slog.String("username", msg.Username), slog.String("message", msg.Message))
			session := sessions[msg.Username]
			delete(sessions, msg.Username)
			broadcast(ctx, log, sessions, []byte("["+msg.Username+"] "+msg.Message+"\n"))
			sessions[msg.Username] = session
		}
	}
}

func broadcast(ctx context.Context, log *slog.Logger, sessions map[string]net.Conn, msg []byte) {
	for _, conn := range sessions {
		if _, err := conn.Write(msg); err != nil {
			log.Error("failed to send message", slog.Any("error", err))
		}
	}
}
