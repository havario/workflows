package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
)

type ApiResponse struct {
	Success bool             `json:"success"`
	IP      string           `json:"ip"`
	MtGeo   *MeituanGeoData  `json:"mt_geo"`
	IPSB    *IpSbGeoData     `json:"ipsb"`
}

type MeituanGeoData struct {
	Lat      float64 `json:"lat"`
	Lng      float64 `json:"lng"`
	Country  string  `json:"country"`
	Province string  `json:"province"`
	City     string  `json:"city"`
	District string  `json:"district"`
	Detail   string  `json:"detail"`
}

type IpSbGeoData struct {
	ISP             string  `json:"isp"`
	Organization    string  `json:"organization"`
	ASN             string  `json:"asn"`
	ASNOrganization string  `json:"asn_organization"`
	Country         string  `json:"country"`
	CountryCode     string  `json:"country_code"`
	Region          string  `json:"region"`
	RegionCode      string  `json:"region_code"`
	City            string  `json:"city"`
	Latitude        float64 `json:"latitude"`
	Longitude       float64 `json:"longitude"`
}

func fetchJsonFromApi(apiUrl string, target interface{}) error {
	httpResponse, err := http.Get(apiUrl)
	if err != nil {
		return err
	}
	defer httpResponse.Body.Close()

	bodyBytes, err := io.ReadAll(httpResponse.Body)
	if err != nil {
		return err
	}

	return json.Unmarshal(bodyBytes, target)
}

func rootRequestHandler(responseWriter http.ResponseWriter, request *http.Request) {
	if request.Method != "POST" {
		http.ServeFile(responseWriter, request, "index.html")
		return
	}

	request.ParseForm()
	queriedIP := request.FormValue("ip")

	if queriedIP == "" {
		json.NewEncoder(responseWriter).Encode(ApiResponse{Success: false})
		return
	}

	meituanApiUrl := "https://apimobile.meituan.com/locate/v2/ip/loc?rgeo=true&ip=" + url.QueryEscape(queriedIP)

	var meituanRawResponse map[string]interface{}
	if err := fetchJsonFromApi(meituanApiUrl, &meituanRawResponse); err != nil {
		json.NewEncoder(responseWriter).Encode(ApiResponse{Success: false})
		return
	}

	meituanData := meituanRawResponse["data"].(map[string]interface{})
	meituanReverseGeo := meituanData["rgeo"].(map[string]interface{})

	latitude := meituanData["lat"].(float64)
	longitude := meituanData["lng"].(float64)

	meituanCityApiUrl := fmt.Sprintf(
		"https://apimobile.meituan.com/group/v1/city/latlng/%f,%f?tag=0",
		latitude, longitude,
	)

	var meituanCityRawResponse map[string]interface{}
	fetchJsonFromApi(meituanCityApiUrl, &meituanCityRawResponse)

	cityDetail := ""
	if meituanCityRawResponse["data"] != nil {
		if dataMap, ok := meituanCityRawResponse["data"].(map[string]interface{}); ok {
			if val, ok := dataMap["detail"].(string); ok {
				cityDetail = val
			}
		}
	}

	meituanGeoData := &MeituanGeoData{
		Lat:      latitude,
		Lng:      longitude,
		Country:  meituanReverseGeo["country"].(string),
		Province: meituanReverseGeo["province"].(string),
		City:     meituanReverseGeo["city"].(string),
		District: meituanReverseGeo["district"].(string),
		Detail:   cityDetail,
	}

	ipSbApiUrl := "https://api.ip.sb/geoip/" + url.QueryEscape(queriedIP)

	var ipSbRawResponse map[string]interface{}
	ipSbData := &IpSbGeoData{}

	if fetchJsonFromApi(ipSbApiUrl, &ipSbRawResponse) == nil {
		ipSbData.ISP, _ = ipSbRawResponse["isp"].(string)
		ipSbData.Organization, _ = ipSbRawResponse["organization"].(string)
		ipSbData.ASN, _ = ipSbRawResponse["asn"].(string)
		ipSbData.ASNOrganization, _ = ipSbRawResponse["asn_organization"].(string)
		ipSbData.Country, _ = ipSbRawResponse["country"].(string)
		ipSbData.CountryCode, _ = ipSbRawResponse["country_code"].(string)
		ipSbData.Region, _ = ipSbRawResponse["region"].(string)
		ipSbData.RegionCode, _ = ipSbRawResponse["region_code"].(string)
		ipSbData.City, _ = ipSbRawResponse["city"].(string)
		ipSbData.Latitude, _ = ipSbRawResponse["latitude"].(float64)
		ipSbData.Longitude, _ = ipSbRawResponse["longitude"].(float64)
	}

	finalResponse := ApiResponse{
		Success: true,
		IP:      queriedIP,
		MtGeo:   meituanGeoData,
		IPSB:    ipSbData,
	}

	responseWriter.Header().Set("Content-Type", "application/json")
	json.NewEncoder(responseWriter).Encode(finalResponse)
}

func main() {
	http.HandleFunc("/", rootRequestHandler)

	log.Println("Go backend server is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
