// Copyright (c) 2025 honeok <honeok@duck.com>

package main

import (
    "fmt"
    "github.com/gin-gonic/gin"
    "log"
    "net"
    "net/http"
    "strings"
)

func main() {
    // 关闭默认的Gin调试日志
    gin.SetMode(gin.ReleaseMode)

    // 初始化Gin路由器, 移除默认中间件
    r := gin.New()
    r.Use(gin.Recovery()) // 保留恢复中间件
    r.Use(minimalLogger()) // 添加自定义简洁日志中间件

    // 定义根路径的GET端点
    r.GET("/", func(c *gin.Context) {
        // 获取客户端IP
        clientIP := getClientIP(c)

        // 返回客户端IP
        c.String(http.StatusOK, clientIP)
    })

    // 启动服务器, 监听8080端口
    if err := r.Run(":8080"); err != nil {
        log.Fatalf("启动服务器失败: %v", err)
    }
}

// minimalLogger记录简洁的请求信息, 包含所有状态码
func minimalLogger() gin.HandlerFunc {
    return func(c *gin.Context) {
        // 处理请求
        c.Next()

        // 记录方法、路径和状态码
        log.Printf("[GIN] %s %s %d", c.Request.Method, c.Request.URL.Path, c.Writer.Status())
    }
}

// getClientIP从请求中提取客户端IP
func getClientIP(c *gin.Context) string {
    // 检查X-Forwarded-For头
    forwarded := c.GetHeader("X-Forwarded-For")
    if forwarded != "" {
        // 选取第一个有效的IP
        ips := strings.Split(forwarded, ",")
        for _, ip := range ips {
            ip = strings.TrimSpace(ip)
            if isValidIP(ip) {
                return ip
            }
        }
    }

    // 回退到直连IP
    return c.ClientIP()
}

// isValidIP 验证IP地址格式
func isValidIP(ip string) bool {
    if ip == "" {
        return false
    }
    return net.ParseIP(ip) != nil
}