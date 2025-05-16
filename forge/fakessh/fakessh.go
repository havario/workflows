package main

import (
    "crypto/rand"
    "crypto/rsa"
    "errors"
    "fmt"
    "log"
    "math/rand"
    "net"
    "os"
    "time"

    "golang.org/x/crypto/ssh"
)

var (
    errBadPassword = errors.New("permission denied")
    serverVersions = []string{
        "SSH-2.0-OpenSSH_9.0p1 Ubuntu-4ubuntu7.3",
        "SSH-2.0-OpenSSH_9.1p1 Debian-2+deb12u2",
        "SSH-2.0-OpenSSH_9.2p1 Ubuntu-3ubuntu0.1",
        "SSH-2.0-OpenSSH_9.3p1 Debian-1+b1",
        "SSH-2.0-OpenSSH_9.4p1 Ubuntu-2ubuntu2.1",
        "SSH-2.0-OpenSSH_9.5p1 Debian-3",
        "SSH-2.0-OpenSSH_9.6p1 Ubuntu-1ubuntu3",
        "SSH-2.0-OpenSSH_9.7p1 Debian-2",
    }
)

func main() {
    if len(os.Args) > 1 {
        logPath := fmt.Sprintf("%s/fakessh-%s.log", os.Args[1], time.Now().Format("2006-01-02-15-04-05-000"))
        logFile, err := os.OpenFile(logPath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
        if err != nil {
            log.Println("Failed to open log file:", logPath, err)
            return
        }
        defer logFile.Close()
        log.SetOutput(logFile)
    }

    log.SetFlags(log.LstdFlags | log.Lmicroseconds)

    serverConfig := &ssh.ServerConfig{
        MaxAuthTries:     6,
        PasswordCallback: passwordCallback,
        ServerVersion:    serverVersions[rand.Intn(len(serverVersions))],
    }

    privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
    if err != nil {
        log.Println("Failed to generate key:", err)
        return
    }
    signer, err := ssh.NewSignerFromSigner(privateKey)
    if err != nil {
        log.Println("Failed to create signer:", err)
        return
    }
    serverConfig.AddHostKey(signer)

    listener, err := net.Listen("tcp", ":22")
    if err != nil {
        log.Println("Failed to listen:", err)
        return
    }
    defer listener.Close()

    for {
        conn, err := listener.Accept()
        if err != nil {
            log.Println("Failed to accept:", err)
            continue
        }
        go handleConn(conn, serverConfig)
    }
}

func passwordCallback(conn ssh.ConnMetadata, password []byte) (*ssh.Permissions, error) {
    serverVersion := serverVersions[rand.Intn(len(serverVersions))]
    log.Println(conn.RemoteAddr(), serverVersion, conn.User(), string(password))
    time.Sleep(100 * time.Millisecond)
    return nil, errBadPassword
}

func handleConn(conn net.Conn, serverConfig *ssh.ServerConfig) {
    defer conn.Close()
    log.Println(conn.RemoteAddr())
    ssh.NewServerConn(conn, serverConfig)
}