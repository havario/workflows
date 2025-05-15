#!/usr/bin/env python3
#
# Description: Lightweight server that returns the client IP from the X-Forwarded-For header or remote address.
#
# Copyright (c) 2024-2025 honeok <honeok@duck.com>
#
# Licensed under the MIT License.
# This software is provided "as is", without any warranty.

import http.server
import socketserver
import ipaddress
import json
import socket
import signal
import sys
import time

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # 初始化响应，包含时间戳
            response = {'code': 1, 'client_ip': 'Unknown', 'timestamp': int(time.time())}
            
            # 获取 IP 候选
            ip_candidates = []
            x_forwarded_for = self.headers.get('X-Forwarded-For')
            if x_forwarded_for:
                ip_candidates.extend(ip.strip() for ip in x_forwarded_for.split(','))
            if self.client_address and self.client_address[0]:
                ip_candidates.append(self.client_address[0])

            # 验证第一个有效 IP
            for ip in ip_candidates:
                try:
                    ipaddress.ip_address(ip)
                    response['code'] = 0
                    response['client_ip'] = ip
                    break
                except ValueError:
                    continue

            # 发送响应
            response_body = json.dumps(response).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', len(response_body))
            self.end_headers()
            self.wfile.write(response_body)

        except (BrokenPipeError, ConnectionError):
            # 客户端断开连接，静默处理
            pass
        except Exception:
            response = {'code': 2, 'client_ip': 'Unknown', 'timestamp': int(time.time())}
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