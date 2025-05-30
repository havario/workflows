// Copyright (c) 2025 honeok <honeok@duck.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
