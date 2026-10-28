import os
import pathlib
from http.server import BaseHTTPRequestHandler, HTTPServer

GREETING = os.environ.get("GREETING", "hello")
VISITS = pathlib.Path("/data/visits.txt")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        count = int(VISITS.read_text()) + 1 if VISITS.exists() else 1
        VISITS.parent.mkdir(parents=True, exist_ok=True)
        VISITS.write_text(str(count))
        body = f"{GREETING} from {os.uname().nodename}, visit {count}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"request from {self.client_address[0]}: {fmt % args}", flush=True)


print("training app listening on 0.0.0.0:8000", flush=True)
HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
