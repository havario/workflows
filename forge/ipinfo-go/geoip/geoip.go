// Copyright (c) 2025 honeok <honeok@disroot.org>

package geoip

import (
	"fmt"
	"net"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/oschwald/geoip2-golang"
)

// GeoIP encapsulates GeoIP2 database operations
type GeoIP struct {
	cityDB    *geoip2.Reader
	countryDB *geoip2.Reader
	asnDB     *geoip2.Reader
}

// NewGeoIP initializes GeoIP databases
func NewGeoIP(cityDBPath, countryDBPath, asnDBPath string) (*GeoIP, error) {
	cityDB, err := geoip2.Open(cityDBPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open city database: %w", err)
	}
	countryDB, err := geoip2.Open(countryDBPath)
	if err != nil {
		cityDB.Close()
		return nil, fmt.Errorf("failed to open country database: %w", err)
	}
	asnDB, err := geoip2.Open(asnDBPath)
	if err != nil {
		cityDB.Close()
		countryDB.Close()
		return nil, fmt.Errorf("failed to open ASN database: %w", err)
	}
	return &GeoIP{
		cityDB:    cityDB,
		countryDB: countryDB,
		asnDB:     asnDB,
	}, nil
}

// Close closes all GeoIP databases
func (g *GeoIP) Close() {
	g.cityDB.Close()
	g.countryDB.Close()
	g.asnDB.Close()
}

// GetIPInfo retrieves IP and GeoIP information
func (g *GeoIP) GetIPInfo(c *gin.Context) (string, *geoip2.City, *geoip2.Country, *geoip2.ASN, string, error) {
	// Get client IP from X-Forwarded-For or CF-Connecting-IP for proxies like Cloudflare
	clientIP := c.GetHeader("CF-Connecting-IP")
	if clientIP == "" {
		clientIP = c.GetHeader("X-Forwarded-For")
		if clientIP != "" {
			// X-Forwarded-For may contain multiple IPs, take the first one
			clientIP = strings.Split(clientIP, ",")[0]
			clientIP = strings.TrimSpace(clientIP)
		}
	}
	if clientIP == "" {
		clientIP = c.ClientIP()
	}
	if clientIP == "" {
		return "", nil, nil, nil, "", fmt.Errorf("unable to get client IP")
	}

	// Parse IP address
	ip := net.ParseIP(clientIP)
	if ip == nil {
		return "", nil, nil, nil, "", fmt.Errorf("invalid IP address: %s", clientIP)
	}

	// DNS reverse lookup for hostname
	hostname := ""
	hostnames, err := net.LookupAddr(clientIP)
	if err == nil && len(hostnames) > 0 {
		hostname = hostnames[0]
	}

	// Query GeoIP City information
	cityRecord, err := g.cityDB.City(ip)
	if err != nil {
		return "", nil, nil, nil, "", fmt.Errorf("failed to lookup city: %w", err)
	}

	// Query GeoIP Country information
	countryRecord, err := g.countryDB.Country(ip)
	if err != nil {
		return "", nil, nil, nil, "", fmt.Errorf("failed to lookup country: %w", err)
	}

	// Query ASN information
	asnRecord, err := g.asnDB.ASN(ip)
	if err != nil {
		return "", nil, nil, nil, "", fmt.Errorf("failed to lookup ASN: %w", err)
	}

	return clientIP, cityRecord, countryRecord, asnRecord, hostname, nil
}
