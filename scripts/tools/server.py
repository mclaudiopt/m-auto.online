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
BRANDS = {
    'merc': 'Mercedes', 'renault': 'Renault', 'psa': 'PSA',
    'autodata': 'Autodata', 'delphi': 'Delphi', 'ford': 'Ford',
    'gm': 'GM', 'tesla': 'TESLA', 'vw': 'VW', 'hermes': 'Hermes'
}

class MAutoHandler(http.server.SimpleHTTPRequestHandler):
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

        # Serve static files
        self.path = path if path.startswith('/') else '/' + path
        os.chdir(SCRIPT_DIR)
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

if __name__ == '__main__':
    os.chdir(SCRIPT_DIR)
    with socketserver.TCPServer(("", PORT), MAutoHandler) as httpd:
        print(f"M-Auto Server running at http://localhost:{PORT}")
        print(f"Serving from: {SCRIPT_DIR}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
