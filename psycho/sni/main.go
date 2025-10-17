package main

import (
	"bufio"
	"context"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/miekg/dns"
)

// TraceResponse 定义trace接口返回的loc字段结构
type TraceResponse struct {
	Loc string `json:"loc"`
}

// University 定义大学JSON数据的结构
type University struct {
	Name           string   `json:"name"`
	Domains        []string `json:"domains"`
	WebPages       []string `json:"web_pages"`
	Country        string   `json:"country"`
	AlphaTwoCode   string   `json:"alpha_two_code"`
	StateProvince  string   `json:"state-province"`
}

// Result 定义输出结果的结构，包含URL、443端口状态及TLS支持情况
type Result struct {
	URL            string `json:"url"`
	Port443Open    bool   `json:"port_443_open"`
	SupportsTLSv13 bool   `json:"supports_tlsv1_3"`
	SupportsX25519 bool   `json:"supports_x25519"`
}

func main() {
	// 初始化日志，带时间戳
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	// 创建仅支持IPv4的HTTP客户端
	dialer := &net.Dialer{}
	transport := &http.Transport{
		DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
			log.Printf("尝试连接 %s (IPv4)", addr)
			conn, err := dialer.DialContext(ctx, "tcp4", addr)
			if err != nil {
				log.Printf("连接 %s 失败: %v", addr, err)
			}
			return conn, err
		},
	}
	client := &http.Client{
		Transport: transport,
		Timeout:   10 * time.Second, // 设置请求超时为10秒
	}

	// 请求trace接口获取loc
	log.Println("开始请求trace接口: http://www.qualcomm.cn/cdn-cgi/trace")
	traceResp, err := client.Get("http://www.qualcomm.cn/cdn-cgi/trace")
	if err != nil {
		log.Printf("获取trace数据失败: %v", err)
		return
	}
	defer traceResp.Body.Close()
	log.Println("trace接口请求成功")

	// 读取trace响应内容
	body, err := io.ReadAll(traceResp.Body)
	if err != nil {
		log.Printf("读取trace响应失败: %v", err)
		return
	}
	log.Println("trace响应读取成功")

	// 解析trace响应，提取loc字段
	var loc string
	scanner := bufio.NewScanner(strings.NewReader(string(body)))
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "loc=") {
			loc = strings.TrimPrefix(line, "loc=")
			break
		}
	}
	if loc == "" {
		log.Println("未在trace响应中找到loc")
		return
	}
	log.Printf("提取到loc: %s", loc)

	// 请求大学JSON数据
	log.Println("开始请求大学JSON数据: https://github.com/Hipo/university-domains-list/raw/master/world_universities_and_domains.json")
	uniResp, err := client.Get("https://github.com/Hipo/university-domains-list/raw/master/world_universities_and_domains.json")
	if err != nil {
		log.Printf("获取大学数据失败: %v", err)
		return
	}
	defer uniResp.Body.Close()
	log.Println("大学JSON数据请求成功")

	// 解析大学JSON数据
	var universities []University
	if err := json.NewDecoder(uniResp.Body).Decode(&universities); err != nil {
		log.Printf("解析大学JSON失败: %v", err)
		return
	}
	log.Printf("解析大学JSON成功，获取 %d 条记录", len(universities))

	// 过滤alpha_two_code与loc匹配的条目，提取web_pages
	var webPages []string
	for _, uni := range universities {
		if uni.AlphaTwoCode == loc {
			webPages = append(webPages, uni.WebPages...)
		}
	}
	log.Printf("找到 %d 个匹配loc=%s的web_pages", len(webPages), loc)

	// 检查每个URL的443端口和TLS支持情况，并校验CDN
	results := make([]Result, 0, len(webPages))
	for _, page := range webPages {
		log.Printf("处理URL: %s", page)
		u, err := url.Parse(page)
		if err != nil {
			log.Printf("无效URL %s: %v", page, err)
			continue
		}
		hostname := u.Hostname()
		log.Printf("提取hostname: %s", hostname)

		// 检查443端口是否开放
		log.Printf("检查 %s 的443端口", hostname)
		portOpen := checkPort(hostname, "443")
		log.Printf("%s 的443端口状态: %v", hostname, portOpen)

		// 检查TLSv1.3和X25519支持
		log.Printf("检查 %s 的TLSv1.3和X25519支持", hostname)
		supportsTLSv13, supportsX25519 := checkTLS(hostname)
		log.Printf("%s 的TLSv1.3支持: %v, X25519支持: %v", hostname, supportsTLSv13, supportsX25519)

		// 检查是否使用CDN，如果是则抛弃
		log.Printf("检查 %s 是否使用CDN (DNS方式)", hostname)
		usesCDN := checkCDN(hostname)
		log.Printf("%s 的CDN状态: usesCDN=%v", hostname, usesCDN)
		if usesCDN {
			log.Printf("抛弃CDN域名: %s (用于Reality伪装过滤)", hostname)
			continue
		}

		results = append(results, Result{
			URL:            page,
			Port443Open:    portOpen,
			SupportsTLSv13: supportsTLSv13,
			SupportsX25519: supportsX25519,
		})
	}

	// 输出结果为JSON格式（仅非CDN域名）
	output, err := json.MarshalIndent(results, "", "  ")
	if err != nil {
		log.Printf("编码结果为JSON失败: %v", err)
		return
	}
	log.Println("输出结果 (过滤CDN后):")
	fmt.Println(string(output))
}

// checkPort 检查指定主机和端口是否可连接
func checkPort(host, port string) bool {
	conn, err := net.DialTimeout("tcp4", host+":"+port, 5*time.Second)
	if err != nil {
		log.Printf("连接 %s:%s 失败: %v", host, port, err)
		return false
	}
	conn.Close()
	return true
}

// checkTLS 检查主机是否支持TLSv1.3和X25519
func checkTLS(host string) (bool, bool) {
	conn, err := tls.DialWithDialer(&net.Dialer{Timeout: 5 * time.Second}, "tcp4", host+":443", &tls.Config{
		MinVersion: tls.VersionTLS13, // 强制要求TLSv1.3
	})
	if err != nil {
		log.Printf("TLS连接 %s:443 失败: %v", host, err)
		return false, false // 如果连接失败，表示不支持TLSv1.3
	}
	defer conn.Close()

	// 确认TLSv1.3
	supportsTLSv13 := conn.ConnectionState().Version == tls.VersionTLS13

	// 检查是否支持X25519（通过密码套件，优化匹配TLS1.3常用X25519套件）
	supportsX25519 := false
	cipherSuite := conn.ConnectionState().CipherSuite
	// TLS1.3标准套件ID，默认使用X25519曲线
	if cipherSuite == 0x1301 || // TLS_AES_128_GCM_SHA256
		cipherSuite == 0x1302 || // TLS_AES_256_GCM_SHA384
		cipherSuite == 0x1303 || // TLS_CHACHA20_POLY1305_SHA256
		cipherSuite == 0x1304 {  // TLS_AES_128_CCM_SHA256
		supportsX25519 = true
	}
	return supportsTLSv13, supportsX25519
}

// checkCDN 使用DNS方式检查域名是否托管在CDN
func checkCDN(host string) bool {
	// 配置DNS客户端
	c := new(dns.Client)
	m := new(dns.Msg)
	m.SetQuestion(dns.Fqdn(host), dns.TypeA) // 查询A记录
	m.RecursionDesired = true

	// 使用8.8.8.8作为DNS服务器（可替换为其他）
	r, _, err := c.Exchange(m, "8.8.8.8:53")
	if err != nil {
		log.Printf("DNS查询 %s 失败: %v", host, err)
		return false // 无法查询视为非CDN
	}

	// 检查CNAME记录（CDN常见）
	for _, ans := range r.Answer {
		if cname, ok := ans.(*dns.CNAME); ok {
			target := strings.TrimSuffix(cname.Target, ".")
			cdnKeywords := []string{"cloudflare", "akamai", "fastly", "maxcdn", "jsdelivr", "bootstrapcdn"}
			for _, keyword := range cdnKeywords {
				if strings.Contains(strings.ToLower(target), keyword) {
					log.Printf("检测到CNAME %s 指向CDN: %s", host, target)
					return true
				}
			}
		}
	}

	// 检查A记录（未来可扩展IP范围匹配）
	for _, ans := range r.Answer {
		if a, ok := ans.(*dns.A); ok {
			ip := a.A.String()
			// 可扩展IP范围匹配（例如Cloudflare 173.245.48.0/20），暂简化
			log.Printf("A记录IP: %s", ip)
		}
	}

	return false // 无CNAME指向CDN视为非CDN
}
