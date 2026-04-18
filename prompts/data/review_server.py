#!/usr/bin/env python3
"""
Image Review Server for Lao Vocabulary
A simple HTTP server to review generated images.

Usage: python3 review_server.py [port]

Navigate to: http://localhost:8000
"""

import http.server
import socketserver
import os
import json
import re
from urllib.parse import parse_qs, urlparse

PORT = 8000

# Directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WORDS_DIR = os.path.join(BASE_DIR, 'step5_individual_words')
OUTPUTS_DIR = os.path.join(BASE_DIR, 'outputs')

# Get list of word files sorted
def get_sorted_word_files():
    files = []
    for f in os.listdir(WORDS_DIR):
        if f.endswith('.json'):
            files.append(f)
    files.sort(key=lambda x: (int(re.search(r'prompt_(\d+)_of_100_(\d+)', x).group(1)), 
                              int(re.search(r'prompt_(\d+)_of_100_(\d+)', x).group(2))))
    return files

# HTML template
HTML = '''<!DOCTYPE html>
<html>
<head>
    <title>Lao Image Review</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0; 
            padding: 20px;
            background: #1a1a2e;
            color: #eee;
            min-height: 100vh;
        }
        .container { max-width: 900px; margin: 0 auto; }
        h1 { 
            color: #e94560;
            text-align: center;
            margin-bottom: 10px;
        }
        .progress { 
            text-align: center; 
            color: #888;
            margin-bottom: 20px;
        }
        .nav-bar {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        .nav-btn {
            padding: 10px 20px;
            background: #16213e;
            color: #eee;
            border: 1px solid #0f3460;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        .nav-btn:hover { background: #0f3460; }
        .nav-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .card {
            background: #16213e;
            border-radius: 10px;
            padding: 20px;
            border: 1px solid #0f3460;
        }
        .header {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .word-info {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .lao-word {
            font-size: 72px;
            text-align: center;
            color: #e94560;
            font-weight: bold;
        }
        .romanization {
            font-size: 24px;
            text-align: center;
            color: #888;
        }
        .definition-en {
            font-size: 18px;
            text-align: center;
            color: #ccc;
            margin-top: 10px;
            padding: 10px;
            background: rgba(255,255,255,0.05);
            border-radius: 5px;
        }
        .filename {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
        .prompt-box {
            background: #0f3460;
            border-radius: 5px;
            padding: 15px;
            font-size: 14px;
            line-height: 1.6;
        }
        .prompt-label {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #888;
            font-size: 12px;
            margin-bottom: 5px;
        }
        .copy-btn {
            background: #4ecca3;
            color: #1a1a2e;
            border: none;
            padding: 5px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            font-weight: bold;
            transition: all 0.2s;
        }
        .copy-btn:hover {
            background: #3db892;
            transform: scale(1.05);
        }
        .copy-btn.copied {
            background: #e94560;
        }
        .image-section {
            text-align: center;
            margin-bottom: 20px;
        }
        .image-placeholder {
            background: #0f3460;
            border: 2px dashed #e94560;
            border-radius: 10px;
            padding: 60px;
            color: #e94560;
            font-size: 18px;
        }
        .image-placeholder.found {
            border-color: #4ecca3;
            color: #4ecca3;
        }
        img {
            max-width: 100%;
            max-height: 500px;
            border-radius: 10px;
            border: 2px solid #0f3460;
        }
        .drop-zone {
            border: 2px dashed #4ecca3;
            border-radius: 10px;
            padding: 40px;
            margin-top: 20px;
            text-align: center;
            transition: all 0.3s;
        }
        .drop-zone.dragover {
            background: rgba(78, 204, 163, 0.2);
            border-color: #fff;
        }
        .drop-zone p { margin: 0; color: #888; }
        .action-bar {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 20px;
        }
        .action-btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .good { background: #4ecca3; color: #1a1a2e; }
        .bad { background: #e94560; color: #fff; }
        .delete { background: #666; color: #fff; }
        .status {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 10px 20px;
            background: #4ecca3;
            color: #1a1a2e;
            border-radius: 5px;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .status.show { opacity: 1; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Lao Image Review</h1>
        <div class="progress" id="progress">Loading...</div>
        
        <div class="nav-bar">
            <button class="nav-btn" id="firstBtn">⏮ First</button>
            <button class="nav-btn" id="prevBtn">◀ Previous</button>
            <button class="nav-btn" id="nextBtn">Next ▶</button>
            <button class="nav-btn" id="lastBtn">⏭ Last</button>
        </div>
        
        <div class="card" id="card">
            <div class="header">
                <div class="word-info">
                    <div class="lao-word" id="laoWord">-</div>
                    <div class="romanization" id="romanization">-</div>
                    <div class="definition-en" id="definitionEn">-</div>
                    <div class="filename" id="filename">-</div>
                </div>
                <div class="prompt-box">
                    <div class="prompt-label">
                        <span>IMAGE PROMPT</span>
                        <button class="copy-btn" id="copyBtn" onclick="copyPrompt()">📋 Copy</button>
                    </div>
                    <div id="prompt">-</div>
                </div>
            </div>
            
            <div class="image-section" id="imageSection">
                <div class="image-placeholder" id="placeholder">No image found</div>
            </div>
            
            <div class="drop-zone" id="dropZone">
                <p>📸 Drag & drop an image here to upload</p>
                <p style="font-size: 12px; margin-top: 10px;">PNG, JPG, WEBP supported</p>
            </div>
            
            <div class="action-bar">
                <button class="action-btn good" id="goodBtn">✓ Good</button>
                <button class="action-btn bad" id="badBtn">✗ Bad</button>
                <button class="action-btn delete" id="deleteBtn">🗑 Delete</button>
            </div>
        </div>
    </div>
    
    <div class="status" id="status">Saved!</div>
    
    <script>
        let currentIndex = 0;
        let files = [];
        
        const laoWordEl = document.getElementById('laoWord');
        const romanizationEl = document.getElementById('romanization');
        const definitionEnEl = document.getElementById('definitionEn');
        const filenameEl = document.getElementById('filename');
        const promptEl = document.getElementById('prompt');
        const progressEl = document.getElementById('progress');
        const imageSection = document.getElementById('imageSection');
        const placeholder = document.getElementById('placeholder');
        const dropZone = document.getElementById('dropZone');
        const statusEl = document.getElementById('status');
        
        const firstBtn = document.getElementById('firstBtn');
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        const lastBtn = document.getElementById('lastBtn');
        const goodBtn = document.getElementById('goodBtn');
        const badBtn = document.getElementById('badBtn');
        const deleteBtn = document.getElementById('deleteBtn');
        
        async function loadFiles() {
            const resp = await fetch('/api/files');
            files = await resp.json();
            updateNav();
            loadCurrent();
        }
        
        function updateNav() {
            firstBtn.disabled = currentIndex === 0;
            prevBtn.disabled = currentIndex === 0;
            nextBtn.disabled = currentIndex === files.length - 1;
            lastBtn.disabled = currentIndex === files.length - 1;
            progressEl.textContent = `Image ${currentIndex + 1} of ${files.length}`;
        }
        
        function copyPrompt() {
            const promptText = document.getElementById('prompt').textContent;
            navigator.clipboard.writeText(promptText).then(() => {
                const btn = document.getElementById('copyBtn');
                btn.textContent = '✓ Copied!';
                btn.classList.add('copied');
                setTimeout(() => {
                    btn.textContent = '📋 Copy';
                    btn.classList.remove('copied');
                }, 1500);
            });
        }
        
        async function loadCurrent() {
            if (files.length === 0) return;
            
            const filename = files[currentIndex];
            const resp = await fetch(`/api/word/${encodeURIComponent(filename)}`);
            const data = await resp.json();
            
            laoWordEl.textContent = data.lao_word;
            romanizationEl.textContent = data.romanization || '-';
            definitionEnEl.textContent = data.definition_en || '-';
            filenameEl.textContent = filename;
            promptEl.textContent = data.image_prompt || '-';
            
            // Check for image
            if (data.has_image) {
                imageSection.innerHTML = `<img src="/outputs/${data.image_filename}" alt="Generated image">`;
            } else {
                imageSection.innerHTML = `<div class="image-placeholder">No image found</div>`;
            }
            
            updateNav();
        }
        
        function showStatus(msg) {
            statusEl.textContent = msg;
            statusEl.classList.add('show');
            setTimeout(() => statusEl.classList.remove('show'), 2000);
        }
        
        // Navigation
        firstBtn.addEventListener('click', () => { currentIndex = 0; loadCurrent(); });
        prevBtn.addEventListener('click', () => { if (currentIndex > 0) { currentIndex--; loadCurrent(); } });
        nextBtn.addEventListener('click', () => { if (currentIndex < files.length - 1) { currentIndex++; loadCurrent(); } });
        lastBtn.addEventListener('click', () => { currentIndex = files.length - 1; loadCurrent(); });
        
        // Keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (e.key === 'ArrowLeft') { if (currentIndex > 0) { currentIndex--; loadCurrent(); } }
            if (e.key === 'ArrowRight') { if (currentIndex < files.length - 1) { currentIndex++; loadCurrent(); } }
            if (e.key === 'g') goodBtn.click();
            if (e.key === 'b') badBtn.click();
            if (e.key === 'd') deleteBtn.click();
        });
        
        // Action buttons
        async function markImage(status) {
            if (files.length === 0) return;
            const filename = files[currentIndex];
            await fetch(`/api/mark/${encodeURIComponent(filename)}?status=${status}`, { method: 'POST' });
            showStatus(`Marked as ${status}!`);
            // Move to next
            if (currentIndex < files.length - 1) {
                currentIndex++;
                loadCurrent();
            }
        }
        
        goodBtn.addEventListener('click', () => markImage('good'));
        badBtn.addEventListener('click', () => markImage('bad'));
        
        deleteBtn.addEventListener('click', async () => {
            if (files.length === 0) return;
            const filename = files[currentIndex];
            await fetch(`/api/delete/${encodeURIComponent(filename)}`, { method: 'POST' });
            showStatus('Image deleted!');
            loadCurrent();
        });
        
        // Drag and drop
        dropZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            dropZone.classList.add('dragover');
        });
        
        dropZone.addEventListener('dragleave', () => {
            dropZone.classList.remove('dragover');
        });
        
        dropZone.addEventListener('drop', async (e) => {
            e.preventDefault();
            dropZone.classList.remove('dragover');
            
            if (files.length === 0) return;
            const filename = files[currentIndex];
            const file = e.dataTransfer.files[0];
            
            if (!file || !file.type.startsWith('image/')) {
                showStatus('Please drop an image file!');
                return;
            }
            
            const formData = new FormData();
            formData.append('image', file);
            
            const resp = await fetch(`/api/upload/${encodeURIComponent(filename)}`, {
                method: 'POST',
                body: formData
            });
            
            if (resp.ok) {
                showStatus('Image uploaded!');
                loadCurrent();
            } else {
                showStatus('Upload failed!');
            }
        });
        
        // Init
        loadFiles();
    </script>
</body>
</html>'''


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)
    
    def do_GET(self):
        parsed = urlparse(self.path)
        
        # API: Get list of word files
        if parsed.path == '/api/files':
            files = get_sorted_word_files()
            self.send_json(files)
            return
        
        # API: Get word data
        match = re.match(r'^/api/word/(.+)$', parsed.path)
        if match:
            filename = match.group(1)
            filepath = os.path.join(WORDS_DIR, filename)
            
            if not os.path.exists(filepath):
                self.send_error(404, 'File not found')
                return
            
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Check for image
            # Extract prompt number and word index from filename
            # e.g., prompt_001_of_100_1.json -> check for prompt_001_of_100_1.png/jpg/etc.
            base_name = os.path.splitext(filename)[0]
            image_filename = None
            has_image = False
            
            for ext in ['.png', '.jpg', '.jpeg', '.webp', '.gif']:
                test_name = base_name + ext
                if os.path.exists(os.path.join(OUTPUTS_DIR, test_name)):
                    image_filename = test_name
                    has_image = True
                    break
            
            data['has_image'] = has_image
            data['image_filename'] = image_filename
            self.send_json(data)
            return
        
        # Serve HTML for root
        if parsed.path == '/' or parsed.path == '/index.html':
            self.send_html(HTML)
            return
        
        # Otherwise serve files normally
        super().do_GET()
    
    def do_POST(self):
        parsed = urlparse(self.path)
        
        # API: Upload image
        match = re.match(r'^/api/upload/(.+)$', parsed.path)
        if match:
            filename = match.group(1)
            content_type = self.headers.get('Content-Type', '')
            
            # Read the image data
            content_length = int(self.headers.get('Content-Length', 0))
            image_data = self.rfile.read(content_length)
            
            # Determine extension from content type or default to .png
            ext_map = {
                'image/png': '.png',
                'image/jpeg': '.jpg',
                'image/webp': '.webp',
                'image/gif': '.gif'
            }
            ext = ext_map.get(content_type, '.png')
            
            # Save to outputs directory
            base_name = os.path.splitext(filename)[0]
            output_path = os.path.join(OUTPUTS_DIR, base_name + ext)
            
            with open(output_path, 'wb') as f:
                f.write(image_data)
            
            self.send_json({'success': True, 'filename': base_name + ext})
            return
        
        # API: Mark image
        match = re.match(r'^/api/mark/(.+)$', parsed.path)
        if match:
            filename = match.group(1)
            params = parse_qs(parsed.query)
            status = params.get('status', ['unknown'])[0]
            
            # Save mark to a status file
            marks_dir = os.path.join(BASE_DIR, 'marks')
            os.makedirs(marks_dir, exist_ok=True)
            
            mark_file = os.path.join(marks_dir, filename + '.json')
            with open(mark_file, 'w') as f:
                json.dump({'status': status, 'filename': filename}, f)
            
            self.send_json({'success': True})
            return
        
        # API: Delete image
        match = re.match(r'^/api/delete/(.+)$', parsed.path)
        if match:
            filename = match.group(1)
            base_name = os.path.splitext(filename)[0]
            
            # Delete any matching images
            for ext in ['.png', '.jpg', '.jpeg', '.webp', '.gif']:
                img_path = os.path.join(OUTPUTS_DIR, base_name + ext)
                if os.path.exists(img_path):
                    os.remove(img_path)
            
            # Also remove mark
            marks_dir = os.path.join(BASE_DIR, 'marks')
            mark_file = os.path.join(marks_dir, filename + '.json')
            if os.path.exists(mark_file):
                os.remove(mark_file)
            
            self.send_json({'success': True})
            return
        
        self.send_error(405, 'Method not allowed')
    
    def send_json(self, data):
        response = json.dumps(data)
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(response))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(response.encode())
    
    def send_html(self, html):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.send_header('Content-Length', len(html))
        self.end_headers()
        self.wfile.write(html.encode())


if __name__ == '__main__':
    # Ensure outputs directory exists
    os.makedirs(OUTPUTS_DIR, exist_ok=True)
    
    print(f"""
╔══════════════════════════════════════════════════════╗
║           Lao Image Review Server                   ║
╠══════════════════════════════════════════════════════╣
║  Navigate to: http://localhost:{PORT}                 ║
║                                                      ║
║  Controls:                                           ║
║    ◀ ▶  or Arrow Keys - Navigate                    ║
║    G - Mark Good                                     ║
║    B - Mark Bad                                      ║
║    D - Delete Image                                  ║
║    Drag & Drop - Upload new image                    ║
║                                                      ║
║  Press Ctrl+C to stop                                ║
╚══════════════════════════════════════════════════════╝
    """)
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        httpd.serve_forever()
