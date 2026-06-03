#!/usr/bin/env python3
"""HTTP server with S3 API endpoint for M-Auto Backend"""
import http.server
import socketserver
import os
import json
import subprocess
from urllib.parse import urlparse, parse_qs
from pathlib import Path

PORT = 3001
SCRIPT_DIR = Path(__file__).parent
REPO_DIR = Path('D:/Tutorials/m-auto.online')
BRANDS = {
    'merc': 'Daimler', 'renault': 'Renault', 'psa': 'PSA',
    'autodata': 'Autodata', 'delphi': 'Delphi', 'ford': 'Ford',
    'gm': 'GM', 'tesla': 'TESLA', 'vw': 'VW', 'hermes': 'Hermes'
}

class MAutoHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == '/api/save-names':
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            try:
                names = json.loads(body)
                names_path = REPO_DIR / 'friendlynames.json'
                with open(names_path, 'w', encoding='utf-8') as f:
                    json.dump(names, f, indent=2, ensure_ascii=False)
                # Auto commit + push (fire and forget)
                subprocess.Popen(
                    ['git', '-C', str(REPO_DIR), 'add', 'friendlynames.json'],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.Popen(
                    ['git', '-C', str(REPO_DIR), 'commit', '-m', 'friendlynames: auto-save'],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                subprocess.Popen(
                    ['git', '-C', str(REPO_DIR), 'push'],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'ok': True, 'pushed': True}).encode())
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode())
            return

        self.send_response(404)
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        # API endpoint for S3 files
        if path == '/api/s3-files':
            query = parse_qs(parsed.query)
            brand_key = query.get('brand', [None])[0]

            if not brand_key or brand_key not in BRANDS:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Invalid brand'}).encode())
                return

            brand_label = BRANDS[brand_key]
            self.get_s3_files(brand_label)
            return

        # SSE endpoint for renew script execution
        if path == '/api/renew':
            query = parse_qs(parsed.query)
            brand_key = query.get('brand', [None])[0]
            if not brand_key or brand_key not in BRANDS:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Invalid brand'}).encode())
                return
            self.stream_renew(brand_key)
            return

        # Serve static files
        self.path = path if path.startswith('/') else '/' + path
        os.chdir(SCRIPT_DIR)
        # Force no-cache for HTML/JS files
        if self.path.endswith('.html') or self.path.endswith('.js'):
            self.send_response(200)
            self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
            self.send_header('Pragma', 'no-cache')
            self.send_header('Expires', '0')
            content = Path(self.path.lstrip('/')).read_bytes()
            self.send_header('Content-Type', 'text/html; charset=utf-8' if self.path.endswith('.html') else 'application/javascript')
            self.send_header('Content-Length', str(len(content)))
            self.end_headers()
            self.wfile.write(content)
            return
        super().do_GET()

    def get_s3_files(self, brand_label):
        """Get files from S3 via rclone"""
        try:
            cmd = f'rclone ls r2-mauto:m-auto-software/{brand_label}'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)

            files = []
            if result.returncode == 0 and result.stdout:
                import re
                for line in result.stdout.strip().split('\n'):
                    if line.strip():
                        # Format: "  size  path/to/file"
                        # Extract path after the first number
                        match = re.match(r'^\s*\d+\s+(.+)$', line)
                        if match:
                            filepath = match.group(1)
                            # Only include files, skip directories
                            if '.' in filepath.split('/')[-1]:
                                files.append({'name': f'{brand_label}/{filepath}', 'path': filepath})

            response = {'files': files, 'expires': None}
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode())

    def stream_renew(self, brand_key):
        """Run renew-s3-direct.ps1 and stream output as SSE"""
        script = SCRIPT_DIR / 'renew-s3-direct.ps1'
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Connection', 'keep-alive')
        self.end_headers()

        def send_event(data):
            msg = f'data: {json.dumps(data)}\n\n'
            self.wfile.write(msg.encode('utf-8'))
            self.wfile.flush()

        try:
            cmd = ['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass',
                   '-Command', f"& '{str(script)}' -brand {brand_key} *>&1"]
            flags = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                    stdin=subprocess.DEVNULL, text=True,
                                    encoding='utf-8', errors='replace', creationflags=flags)
            for line in iter(proc.stdout.readline, ''):
                send_event({'line': line.rstrip('\r\n')})
            proc.wait()
            send_event({'done': True, 'status': 'ok' if proc.returncode == 0 else 'err'})
        except Exception as e:
            send_event({'err': str(e), 'done': True, 'status': 'err'})

if __name__ == '__main__':
    os.chdir(SCRIPT_DIR)
    with socketserver.TCPServer(("", PORT), MAutoHandler) as httpd:
        print(f"M-Auto Server running at http://localhost:{PORT}")
        print(f"Serving from: {SCRIPT_DIR}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
