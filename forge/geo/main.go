package main

import (
	"geo/handler"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	// 加载静态文件和模板
	r.Static("/static", "./static")
	r.LoadHTMLGlob("static/templates/*")
	// 应用频率限制中间件
	r.Use(handler.RateLimitMiddleware())
	r.GET("/", handler.Index)
	r.Run(":8080")
}
