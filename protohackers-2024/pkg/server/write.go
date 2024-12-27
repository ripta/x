package server

import (
	"encoding/json"
	"net"
)

func WriteAsJSON(conn net.Conn, v interface{}) (int, error) {
	raw, err := json.Marshal(v)
	if err != nil {
		return 0, err
	}

	return conn.Write(append(raw, '\n'))
}
