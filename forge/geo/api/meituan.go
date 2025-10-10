package api

import (
	"encoding/json"
	"fmt"
	"geo/model"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

const (
	ipLocAPI  = "https://apimobile.meituan.com/locate/v2/ip/loc?rgeo=true&ip="
	latlngAPI = "https://apimobile.meituan.com/group/v1/city/latlng/"
)

// MeituanGeo 美团定位服务
type MeituanGeo struct {
	client *http.Client
}

// NewMeituanGeo 创建定位器
func NewMeituanGeo() *MeituanGeo {
	return &MeituanGeo{client: &http.Client{Timeout: 10 * time.Second}}
}

// GetLocation 获取ip定位和城市信息
func (m *MeituanGeo) GetLocation(ip string) (*model.LocationResponse, error) {
	//验证IP非私有
	if !isValidPublicIP(ip) {
		return nil, fmt.Errorf("invalid or private IP")
	}
	// 调用第一个api获取ip经纬度
	apiURL := ipLocAPI + url.QueryEscape(ip)
	resp, err := m.client.Get(apiURL)
	if err != nil {
		return nil, fmt.Errorf("IP API failed: %v", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read IP response failed: %v", err)
	}
	var ipLoc model.IPLocResponse
	if err := json.Unmarshal(body, &ipLoc); err != nil {
		return nil, fmt.Errorf("parse IP response failed: %v", err)
	}
	// 调用第二个api获取城市信息
	latlngURL := fmt.Sprintf("%s%.1f,%.1f?tag=0", latlngAPI, ipLoc.Data.Lat, ipLoc.Data.Lng)
	resp, err = m.client.Get(latlngURL)
	if err != nil {
		return nil, fmt.Errorf("city API failed: %v", err)
	}
	defer resp.Body.Close()
	body, err = io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read city response failed: %v", err)
	}
	var city model.CityResponse
	if err := json.Unmarshal(body, &city); err != nil {
		return nil, fmt.Errorf("parse city response failed: %v", err)
	}
	// 组合结果
	return &model.LocationResponse{
		IP:       ip,
		Country:  city.Data.Country,
		Province: city.Data.Province,
		City:     city.Data.City,
		District: city.Data.District,
		AreaName: city.Data.AreaName,
		Detail:   city.Data.Detail,
		Lat:      ipLoc.Data.Lat,
		Lng:      ipLoc.Data.Lng,
	}, nil
}

// isValidPublicIP 验证ip非私有
func isValidPublicIP(ip string) bool {
	parts := strings.Split(ip, ".")
	if len(parts) != 4 {
		return false
	}
	b1, err := strconv.Atoi(parts[0])
	if err != nil {
		return false
	}
	if b1 == 10 {
		return false
	}
	if b1 == 172 {
		b2, err := strconv.Atoi(parts[1])
		if err != nil {
			return false
		}
		if b2 >= 16 && b2 <= 31 {
			return false
		}
	}
	if b1 == 192 && parts[1] == "168" {
		return false
	}
	return true
}
