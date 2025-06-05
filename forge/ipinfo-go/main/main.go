// Copyright (c) 2025 honeok <honeok@disroot.org>

package main

import (
	"ipinfo/handlers"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize GeoIP service
	geoIPService, err := handlers.NewGeoIPService("GeoLite2-City.mmdb", "GeoLite2-Country.mmdb", "GeoLite2-ASN.mmdb")
	if err != nil {
		log.Fatal("Failed to initialize GeoIP service:", err)
	}
	defer geoIPService.Close()

	// Create Gin router
	r := gin.Default()

	// Register routes
	handlers.RegisterRoutes(r, geoIPService)

	// Start server on port 8080
	if err := r.Run(":8080"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
