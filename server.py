#!/usr/bin/env python3
"""
Simple HTTP server for Kostki do Monopoly
Serves the dice game on localhost and network interface
"""

import http.server
import socketserver
import socket
import webbrowser
import threading
import time
import os
import sys

PORT = 8000
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def log_message(self, format, *args):
        # Custom logging format
        print(f"[{self.address_string()}] {format % args}")

def get_local_ip():
    """Get local IP address"""
    try:
        # Connect to a remote address to determine local IP
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
        return local_ip
    except Exception:
        return "127.0.0.1"

def open_browser_delayed():
    """Open browser after a short delay"""
    time.sleep(1.5)
    webbrowser.open(f'http://localhost:{PORT}')

def main():
    # Change to the script directory
    os.chdir(DIRECTORY)

    # Check if index.html exists
    if not os.path.exists('index.html'):
        print("❌ Error: index.html not found in current directory!")
        print(f"Current directory: {DIRECTORY}")
        sys.exit(1)

    # Get local IP
    local_ip = get_local_ip()

    # Create server
    try:
        with socketserver.TCPServer(("127.0.0.1", PORT), CustomHTTPRequestHandler) as httpd:
            print("🎲 Kostki do Monopoly - Server")
            print("=" * 50)
            print(f"📁 Serving directory: {DIRECTORY}")
            print(f"🌐 Local access:    http://localhost:{PORT}")
            print(f"📱 Network access:  http://{local_ip}:{PORT}")
            print("=" * 50)
            print("📋 Instructions:")
            print("   • Use localhost URL on this computer")
            print("   • Use network IP on other devices (phone/tablet)")
            print("   • Make sure devices are on the same WiFi network")
            print("   • Press Ctrl+C to stop the server")
            print("=" * 50)

            # Open browser in background thread
            browser_thread = threading.Thread(target=open_browser_delayed)
            browser_thread.daemon = True
            browser_thread.start()

            print("🚀 Server starting...")
            httpd.serve_forever()

    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"❌ Error: Port {PORT} is already in use!")
            print("Try a different port or stop the existing server.")
        else:
            print(f"❌ Error starting server: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
        print("Thanks for playing! 🎲")

if __name__ == "__main__":
    main()
