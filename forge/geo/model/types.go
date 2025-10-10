package model

// IPLocResponse 第一个api响应
type IPLocResponse struct {
	Data struct {
		Lat float64 `json:"lat"`
		Lng float64 `json:"lng"`
		IP  string  `json:"ip"`
	} `json:"data"`
}

// CityResponse 第二个api响应
type CityResponse struct {
	Data struct {
		Country  string `json:"country"`
		Province string `json:"province"`
		City     string `json:"city"`
		District string `json:"district"`
		AreaName string `json:"areaName"`
		Detail   string `json:"detail"`
	} `json:"data"`
}

// LocationResponse 最终输出结构
type LocationResponse struct {
	Code     int     `json:"code,omitempty"`
	Message  string  `json:"message,omitempty"`
	IP       string  `json:"ip"`
	Country  string  `json:"country"`
	Province string  `json:"province"`
	City     string  `json:"city"`
	District string  `json:"district"`
	AreaName string  `json:"areaName"`
	Detail   string  `json:"detail"`
	Lat      float64 `json:"lat"`
	Lng      float64 `json:"lng"`
}
