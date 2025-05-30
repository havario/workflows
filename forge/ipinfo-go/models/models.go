// Copyright (c) 2025 honeok <honeok@duck.com>

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
