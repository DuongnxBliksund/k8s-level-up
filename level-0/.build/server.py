import os
from http.server import BaseHTTPRequestHandler, HTTPServer

HOST = os.environ.get("BIND_HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "8080"))

FLAG = "LOOPBACK-STAYS-IN-THE-CONTAINER"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Level 0 complete. Flag: {FLAG}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"request from {self.client_address[0]}: {fmt % args}", flush=True)


print(f"server started on port {PORT}", flush=True)
HTTPServer((HOST, PORT), Handler).serve_forever()
