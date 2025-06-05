// Copyright (c) 2025 honeok <honeok@disroot.org>

package handlers

import (
	"ipinfo/geoip"
	"ipinfo/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GeoIPService encapsulates GeoIP service
type GeoIPService struct {
	GeoIP *geoip.GeoIP
}

// NewGeoIPService initializes GeoIP service
func NewGeoIPService(cityDBPath, countryDBPath, asnDBPath string) (*GeoIPService, error) {
	geoIP, err := geoip.NewGeoIP(cityDBPath, countryDBPath, asnDBPath)
	if err != nil {
		return nil, err
	}
	return &GeoIPService{GeoIP: geoIP}, nil
}

// Close closes GeoIP databases
func (s *GeoIPService) Close() {
	s.GeoIP.Close()
}

// RegisterRoutes registers all routes
func RegisterRoutes(r *gin.Engine, service *GeoIPService) {
	r.GET("/", service.handleIP)
	r.GET("/ip", service.handleIP)
	r.GET("/city", service.handleCity)
	r.GET("/region", service.handleRegion)
	r.GET("/country", service.handleCountry)
	r.GET("/loc", service.handleLocation)
	r.GET("/postal", service.handlePostal)
	r.GET("/timezone", service.handleTimezone)
	r.GET("/asn", service.handleASN)
	r.GET("/json", service.handleJSON)
	r.GET("/favicon.ico", service.handleFavicon)
}

// handleIP handles / and /ip routes, returns IP as plain text
func (s *GeoIPService) handleIP(c *gin.Context) {
	clientIP, _, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, clientIP)
}

// handleCity handles /city route, returns city name as plain text
func (s *GeoIPService) handleCity(c *gin.Context) {
	_, cityRecord, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, models.GetCityName(cityRecord))
}

// handleRegion handles /region route, returns region name as plain text
func (s *GeoIPService) handleRegion(c *gin.Context) {
	_, cityRecord, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, models.GetRegionName(cityRecord))
}

// handleCountry handles /country route, returns country code as plain text
func (s *GeoIPService) handleCountry(c *gin.Context) {
	_, _, countryRecord, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, countryRecord.Country.IsoCode)
}

// handleLocation handles /loc route, returns coordinates as plain text
func (s *GeoIPService) handleLocation(c *gin.Context) {
	_, cityRecord, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, models.GetLocation(cityRecord))
}

// handlePostal handles /postal route, returns postal code as plain text
func (s *GeoIPService) handlePostal(c *gin.Context) {
	_, cityRecord, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, cityRecord.Postal.Code)
}

// handleTimezone handles /timezone route, returns timezone as plain text
func (s *GeoIPService) handleTimezone(c *gin.Context) {
	_, cityRecord, _, _, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, cityRecord.Location.TimeZone)
}

// handleASN handles /asn route, returns ASN info as plain text
func (s *GeoIPService) handleASN(c *gin.Context) {
	_, _, _, asnRecord, _, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.String(http.StatusBadRequest, "Error: %s", err.Error())
		return
	}
	c.String(http.StatusOK, models.GetASN(asnRecord))
}

// handleJSON handles /json route, returns full info as JSON with non-empty fields only
func (s *GeoIPService) handleJSON(c *gin.Context) {
	clientIP, cityRecord, countryRecord, asnRecord, hostname, err := s.GeoIP.GetIPInfo(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Build response data, only include non-empty fields
	ipInfo := map[string]interface{}{
		"ip":  clientIP,
		"loc": models.GetLocation(cityRecord),
	}

	// Include fields only if non-empty
	if hostname != "" {
		ipInfo["hostname"] = hostname
	}
	if city := models.GetCityName(cityRecord); city != "" {
		ipInfo["city"] = city
	}
	if region := models.GetRegionName(cityRecord); region != "" {
		ipInfo["region"] = region
	}
	if countryRecord.Country.IsoCode != "" {
		ipInfo["country"] = countryRecord.Country.IsoCode
	}
	if cityRecord.Postal.Code != "" {
		ipInfo["postal"] = cityRecord.Postal.Code
	}
	if cityRecord.Location.TimeZone != "" {
		ipInfo["timezone"] = cityRecord.Location.TimeZone
	}
	if asn := models.GetASN(asnRecord); asn != "" {
		ipInfo["asn"] = asn
	}

	c.JSON(http.StatusOK, ipInfo)
}

// handleFavicon handles /favicon.ico route, returns favicon.ico file
func (s *GeoIPService) handleFavicon(c *gin.Context) {
	c.File("favicon.ico")
}
