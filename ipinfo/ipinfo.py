import http.server
import socketserver
import ipaddress
import json

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # 获取 X-Forwarded-For 头部
        x_forwarded_for = self.headers.get('X-Forwarded-For')
        
        if x_forwarded_for:
            # X-Forwarded-For 可能包含多个 IP 地址，第一个通常是客户端真实 IP
            ip_list = [ip.strip() for ip in x_forwarded_for.split(',')]
            try:
                # 验证并返回第一个有效 IP
                for ip in ip_list:
                    ipaddress.ip_address(ip)
                    client_ip = ip
                    break
            except ValueError:
                client_ip = 'Unknown'
        else:
            # 回退到直接连接的 IP
            client_ip = self.client_address[0] or 'Unknown'

        # 准备 JSON 响应
        response = {'client_ip': client_ip}
        response_body = json.dumps(response).encode('utf-8')

        # 发送响应
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(response_body))
        self.end_headers()
        self.wfile.write(response_body)

def run_server(port=8000):
    server_address = ('', port)
    httpd = socketserver.TCPServer(server_address, RequestHandler)
    print(f'Server running on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()