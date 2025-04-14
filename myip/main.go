// Copyright (c) 2025 honeok <honeok@duck.com>

package main

import (
	"github.com/gin-gonic/gin"
	"log"
	"net"
	"net/http"
	"strings"
)

func main() {
	// 初始化Gin路由器
	r := gin.Default()

	// 定义根路径的GET端点
	r.GET("/", func(c *gin.Context) {
		// 获取客户端 IP
		clientIP := getClientIP(c)

		// 返回客户端IP
		c.String(http.StatusOK, clientIP)
	})

	// 启动服务器, 监听8080端口
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("启动服务器失败: %v", err)
	}
}

// getClientIP从请求中提取客户端IP
func getClientIP(c *gin.Context) string {
	// 检查 X-Forwarded-For头
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

	// 回退到直接连接的IP
	return c.ClientIP()
}

// isValidIP验证IP地址格式
func isValidIP(ip string) bool {
	if ip == "" {
		return false
	}
	return net.ParseIP(ip) != nil
}