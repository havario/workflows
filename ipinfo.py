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
            response = {'code': 1, 'client_ip': 'Unknown'}

            if x_forwarded_for:
                for ip in [ip.strip() for ip in x_forwarded_for.split(',')]:
                    try:
                        ipaddress.ip_address(ip)
                        response = {'code': 0, 'client_ip': ip}
                        break
                    except ValueError:
                        continue
            else:
                if self.client_address and self.client_address[0]:
                    try:
                        ipaddress.ip_address(self.client_address[0])
                        response = {'code': 0, 'client_ip': self.client_address[0]}
                    except ValueError:
                        pass

            # 准备 JSON 响应
            response_body = json.dumps(response).encode('utf-8')

            # 发送响应
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', len(response_body))
            self.end_headers()
            self.wfile.write(response_body)

        except (BrokenPipeError, ConnectionError):
            # 客户端断开连接，静默处理
            pass
        except Exception:
            response = {'code': 2, 'client_ip': 'Unknown'}
            response_body = json.dumps(response).encode('utf-8')
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', len(response_body))
            self.end_headers()
            self.wfile.write(response_body)

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def run_server(port=8000):
    if is_port_in_use(port):
        print(f'Port {port} is already in use. Please choose another port.')
        return

    server_address = ('', port)
    httpd = socketserver.ThreadingTCPServer(server_address, RequestHandler)
    httpd.allow_reuse_address = True
    httpd.timeout = 5  # 设置超时以防止连接挂起

    def signal_handler(sig, frame):
        print('Shutting down server')
        httpd.server_close()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    print('ipinfo server running')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print('Shutting down server')
        httpd.server_close()

if __name__ == '__main__':
    run_server()