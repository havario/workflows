import http.server
import socketserver
import ipaddress
import json
import socket
import signal
import sys

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # 获取 X-Forwarded-For 头部
            x_forwarded_for = self.headers.get('X-Forwarded-For')
            client_ip = 'Unknown'

            if x_forwarded_for:
                # 分割并清理 IP 列表
                ip_list = [ip.strip() for ip in x_forwarded_for.split(',')]
                for ip in ip_list:
                    try:
                        ipaddress.ip_address(ip)
                        client_ip = ip
                        break
                    except ValueError:
                        continue
            else:
                # 回退到直接连接的 IP
                client_ip = self.client_address[0] if self.client_address else 'Unknown'

            # 准备 JSON 响应
            response = {'client_ip': client_ip}
            response_body = json.dumps(response).encode('utf-8')

            # 发送响应
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', len(response_body))
            self.end_headers()
            self.wfile.write(response_body)

        except Exception as e:
            # 通用异常处理
            self.send_error(500, f'Internal Server Error: {str(e)}')

def is_port_in_use(port):
    """检查端口是否被占用"""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def run_server(port=8000):
    # 检查端口是否可用
    if is_port_in_use(port):
        print(f'Port {port} is already in use. Please choose another port.')
        return

    server_address = ('', port)
    httpd = socketserver.TCPServer(server_address, RequestHandler)

    # 处理优雅关闭
    def signal_handler(sig, frame):
        print('\nShutting down server...')
        httpd.server_close()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    print(f'Server running on port {port}...')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('\nShutting down server...')
        httpd.server_close()

if __name__ == '__main__':
    run_server()