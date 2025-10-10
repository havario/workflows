package handler

import (
	"geo/api"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/ulule/limiter/v3"
	mgin "github.com/ulule/limiter/v3/drivers/middleware/gin"
	memory "github.com/ulule/limiter/v3/drivers/store/memory"
)

// RateLimitMiddleware 频率限制中间件
func RateLimitMiddleware() gin.HandlerFunc {
	rate := limiter.Rate{Period: time.Minute, Limit: 60}
	store := memory.NewStore()
	instance := limiter.New(store, rate)
	return mgin.NewMiddleware(instance)
}

// Index 处理主页请求
func Index(c *gin.Context) {
	//解析IP
	ip := getIP(c)
	if ip == "" || !api.IsValidPublicIP(ip) {
		if c.GetHeader("User-Agent") == "" {
			c.JSON(http.StatusOK, gin.H{"code": 1, "message": "error"})
		} else {
			c.HTML(http.StatusOK, "index.html", gin.H{"Error": "Location failed"})
		}
		return
	}
	//调用API
	mg := api.NewMeituanGeo()
	loc, err := mg.GetLocation(ip)
	if err != nil {
		if c.GetHeader("User-Agent") == "" {
			c.JSON(http.StatusOK, gin.H{"code": 1, "message": "error"})
		} else {
			c.HTML(http.StatusOK, "index.html", gin.H{"Error": "Location failed"})
		}
		return
	}
	//根据UA分流
	if c.GetHeader("User-Agent") == "" {
		loc.Code = 0
		c.JSON(http.StatusOK, loc)
	} else {
		c.HTML(http.StatusOK, "index.html", loc)
	}
}

// getIP 解析请求头获取IP
func getIP(c *gin.Context) string {
	if ip := c.GetHeader("X-Forwarded-For"); ip != "" {
		parts := strings.Split(ip, ",")
		return strings.TrimSpace(parts[0])
	}
	if ip := c.GetHeader("CF-Connecting-IP"); ip != "" {
		return ip
	}
	if ip := c.GetHeader("EO-Connecting-IP"); ip != "" {
		return ip
	}
	if ip := c.GetHeader("DO-Connecting-IP"); ip != "" {
		return ip
	}
	if ip := c.GetHeader("X-Real-IP"); ip != "" {
		return ip
	}
	return ""
}
