// Copyright (c) 2025 honeok <honeok@disroot.org>

package models

import (
	"fmt"

	"github.com/oschwald/geoip2-golang"
)

// GetCityName retrieves city name, handling empty values
func GetCityName(record *geoip2.City) string {
	if name, ok := record.City.Names["en"]; ok {
		return name
	}
	return ""
}

// GetRegionName retrieves region name, handling empty values
func GetRegionName(record *geoip2.City) string {
	if len(record.Subdivisions) > 0 {
		if name, ok := record.Subdivisions[0].Names["en"]; ok {
			return name
		}
	}
	return ""
}

// GetLocation retrieves coordinates in "latitude,longitude" format
func GetLocation(record *geoip2.City) string {
	return fmt.Sprintf("%f,%f", record.Location.Latitude, record.Location.Longitude)
}

// GetASN retrieves ASN information in "ASnumber organization" format
func GetASN(record *geoip2.ASN) string {
	return fmt.Sprintf("AS%d %s", record.AutonomousSystemNumber, record.AutonomousSystemOrganization)
}
