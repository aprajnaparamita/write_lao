#!/usr/bin/env python3
"""
Image and Audio Review Server for Lao Vocabulary
A simple HTTP server to review generated images and audio files.

Usage: python3 review_server.py [port]

Navigate to: http://localhost:8000

Features:
- Review generated images, mark as good/bad, drag & drop uploads
- Listen to audio clips directly on the word card
- Flag incorrect audio with notes
"""

import http.server
import socketserver
import os
import json
import re
from urllib.parse import parse_qs, urlparse, unquote

PORT = 8000

# Directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WORDS_DIR = os.path.join(BASE_DIR, 'step5_individual_words')
OUTPUTS_DIR = os.path.join(BASE_DIR, 'outputs')
MARKS_DIR = os.path.join(BASE_DIR, 'marks')

# Audio directories
AUDIO_DIR = os.path.join(BASE_DIR, '..', '..', 'assets', 'audio')
VOCAB_AUDIO_DIR = os.path.join(BASE_DIR, '..', '..', 'assets', 'vocab', 'audio')

# Ensure directories exist
os.makedirs(OUTPUTS_DIR, exist_ok=True)
os.makedirs(MARKS_DIR, exist_ok=True)


def get_sorted_word_files():
    """Get list of word files sorted by prompt number."""
    files = []
    for f in os.listdir(WORDS_DIR):
        if f.endswith('.json'):
            files.append(f)
    files.sort(key=lambda x: (
        int(re.search(r'prompt_(\d+)_of_100_(\d+)', x).group(1)),
        int(re.search(r'prompt_(\d+)_of_100_(\d+)', x).group(2))
    ))
    return files


def get_audio_files():
    """Get all audio files from both directories."""
    files = []
    for directory in [AUDIO_DIR, VOCAB_AUDIO_DIR]:
        if os.path.exists(directory):
            for f in os.listdir(directory):
                if f.endswith(('.m4a', '.mp3', '.wav', '.ogg', '.aac')):
                    rel_path = os.path.relpath(os.path.join(directory, f), os.path.join(BASE_DIR, '..', '..', 'assets'))
                    files.append({
                        'filename': f,
                        'relative_path': rel_path,
                        'url': f'/assets/{rel_path}',
                        'source': 'vocab' if 'vocab' in rel_path else 'main'
                    })
    files.sort(key=lambda x: x['filename'])
    return files


def get_audio_mark(filename):
    """Get the mark status for an audio file."""
    mark_file = os.path.join(MARKS_DIR, 'audio_' + filename + '.json')
    if os.path.exists(mark_file):
        with open(mark_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {'status': 'unchecked', 'filename': filename, 'notes': ''}


def save_audio_mark(filename, status, notes=''):
    """Save the mark status for an audio file."""
    mark_file = os.path.join(MARKS_DIR, 'audio_' + filename + '.json')
    if status == 'unchecked' and notes == '':
        # Remove the file if resetting to unchecked
        if os.path.exists(mark_file):
            os.remove(mark_file)
    else:
        with open(mark_file, 'w', encoding='utf-8') as f:
            json.dump({'status': status, 'filename': filename, 'notes': notes}, f)


HTML = '''<!DOCTYPE html>
<html>
<head>
    <title>Lao Review Server</title>
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
        .container { max-width: 1100px; margin: 0 auto; }
        .nav-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .progress {
            color: #888;
            margin-right: 15px;
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
            padding: 25px;
            border: 1px solid #0f3460;
            margin-bottom: 20px;
        }
        
        .card-header {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 20px;
        }
        
        .word-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .word-section {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .lao-word {
            font-size: 56px;
            color: #e94560;
            font-weight: bold;
            line-height: 1.1;
        }
        .romanization {
            font-size: 20px;
            color: #888;
        }
        .definition-en {
            font-size: 14px;
            color: #ccc;
            padding: 8px;
            background: rgba(255,255,255,0.05);
            border-radius: 5px;
        }
        
        .audio-section {
            display: flex;
            flex-direction: column;
            gap: 6px;
            justify-content: center;
        }
        
        .audio-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 10px;
            background: rgba(255,255,255,0.03);
            border: 1px solid #0f3460;
            border-radius: 6px;
            cursor: pointer;
            color: #ccc;
            font-size: 12px;
            transition: all 0.2s;
        }
        .audio-btn:hover { background: #0f3460; border-color: #4ecca3; }
        .audio-btn.playing { background: #4ecca3; color: #1a1a2e; border-color: #4ecca3; }
        .audio-btn .play-icon { margin-left: auto; font-size: 10px; }
        .audio-btn .flag-icon { 
            margin-left: 6px; 
            font-size: 11px; 
            opacity: 0.5;
        }
        .audio-btn .flag-icon:hover { opacity: 1; }
        .audio-btn.flagged .flag-icon { opacity: 1; color: #e94560; }
        
        .prompt-section {
            background: #0f3460;
            border-radius: 8px;
            padding: 12px;
        }
        .prompt-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: #888;
            font-size: 11px;
            margin-bottom: 6px;
        }
        .copy-btn {
            background: #4ecca3;
            color: #1a1a2e;
            border: none;
            padding: 4px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 11px;
            font-weight: bold;
        }
        .copy-btn:hover { background: #3db892; }
        .copy-btn.copied { background: #e94560; }
        .prompt-text {
            font-size: 13px;
            line-height: 1.5;
            color: #ccc;
        }
        
        .image-area {
            display: flex;
            gap: 20px;
            align-items: flex-start;
        }
        
        .image-section {
            flex: 1;
            text-align: center;
        }
        .image-placeholder {
            background: #0f3460;
            border: 2px dashed #e94560;
            border-radius: 10px;
            padding: 60px;
            color: #e94560;
            font-size: 18px;
        }
        .image-placeholder.has-image {
            border-color: #4ecca3;
            color: #4ecca3;
        }
        img {
            max-width: 100%;
            max-height: 400px;
            border-radius: 10px;
            border: 2px solid #0f3460;
        }
        
        .action-bar {
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-shrink: 0;
        }
        .action-btn {
            padding: 12px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .good { background: #4ecca3; color: #1a1a2e; }
        .good:hover { background: #3db892; }
        .bad { background: #e94560; color: #fff; }
        .bad:hover { background: #d63d56; }
        .delete { background: #444; color: #fff; }
        .delete:hover { background: #333; }
        
        .drop-zone {
            border: 2px dashed #4ecca3;
            border-radius: 10px;
            padding: 30px;
            margin-top: 15px;
            text-align: center;
            transition: all 0.3s;
        }
        .drop-zone.dragover { background: rgba(78, 204, 163, 0.2); border-color: #fff; }
        .drop-zone p { margin: 0; color: #888; }
        .drop-zone small { font-size: 12px; color: #555; margin-top: 8px; display: block; }
        
        .status {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: all 0.2s;
        }
        .good { background: #4ecca3; color: #1a1a2e; }
        .good:hover { background: #3db892; transform: scale(1.02); }
        .bad { background: #e94560; color: #fff; }
        .bad:hover { background: #d63d56; transform: scale(1.02); }
        .delete { background: #666; color: #fff; }
        .delete:hover { background: #555; }
        
        .status {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            background: #4ecca3;
            color: #1a1a2e;
            border-radius: 5px;
            opacity: 0;
            transition: opacity 0.3s;
            font-weight: bold;
            z-index: 1000;
        }
        .status.show { opacity: 1; }
        
        .keyboard-hints {
            text-align: center;
            color: #555;
            font-size: 12px;
            margin-top: 15px;
        }
        .keyboard-hints kbd {
            background: #0f3460;
            padding: 2px 6px;
            border-radius: 3px;
            margin: 0 2px;
        }
        
        /* Modal for flag notes */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.7);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }
        .modal.show { display: flex; }
        .modal-content {
            background: #16213e;
            border-radius: 10px;
            padding: 25px;
            max-width: 400px;
            width: 90%;
            border: 1px solid #0f3460;
        }
        .modal h3 { margin: 0 0 15px 0; color: #e94560; }
        .modal input {
            width: 100%;
            padding: 12px;
            border-radius: 5px;
            border: 1px solid #0f3460;
            background: #0f3460;
            color: #eee;
            font-size: 14px;
            margin-bottom: 15px;
        }
        .modal input:focus { outline: none; border-color: #4ecca3; }
        .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; }
        .modal-btn {
            padding: 10px 20px;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-weight: bold;
        }
        .modal-cancel { background: #666; color: #fff; }
        .modal-submit { background: #e94560; color: #fff; }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav-bar">
            <span class="progress" id="progress">Loading...</span>
            <button class="nav-btn" id="firstBtn">⏮</button>
            <button class="nav-btn" id="prevBtn">◀</button>
            <button class="nav-btn" id="nextBtn">▶</button>
            <button class="nav-btn" id="lastBtn">⏭</button>
        </div>
        
        <div class="card">
            <div class="card-header">
                <div class="word-col">
                    <div class="word-section">
                        <div class="lao-word" id="laoWord">-</div>
                        <div class="romanization" id="romanization">-</div>
                        <div class="definition-en" id="definitionEn">-</div>
                    </div>
                    
                    <div class="audio-section" id="audioButtons"></div>
                </div>
                
                <div class="prompt-section">
                    <div class="prompt-header">
                        <span>IMAGE PROMPT</span>
                        <button class="copy-btn" id="copyBtn">📋 Copy</button>
                    </div>
                    <div class="prompt-text" id="promptText">-</div>
                </div>
            </div>
            
            <div class="image-area">
                <div class="image-section">
                    <div id="imageSection">
                        <div class="image-placeholder" id="placeholder">No image found</div>
                    </div>
                    
                    <div class="drop-zone" id="dropZone">
                        <p>📸 Drag & drop an image here to upload</p>
                        <small>PNG, JPG, WEBP supported</small>
                    </div>
                </div>
                
                <div class="action-bar">
                    <button class="action-btn good" id="goodBtn">✓ Good</button>
                    <button class="action-btn bad" id="badBtn">✗ Bad</button>
                    <button class="action-btn delete" id="deleteBtn">🗑</button>
                </div>
            </div>
        </div>
        
        <div class="keyboard-hints">
            <kbd>←</kbd><kbd>→</kbd> Navigate &nbsp;|&nbsp;
            <kbd>G</kbd> Good &nbsp;|&nbsp;
            <kbd>B</kbd> Bad &nbsp;|&nbsp;
            <kbd>D</kbd> Delete &nbsp;|&nbsp;
            <kbd>1</kbd><kbd>2</kbd><kbd>3</kbd> Play audio
        </div>
    </div>
    
    <div class="status" id="status">Saved!</div>
    
    <!-- Flag Modal -->
    <div class="modal" id="flagModal">
        <div class="modal-content">
            <h3>Flag Audio Issue</h3>
            <input type="text" id="flagNotes" placeholder="What's wrong? (optional)">
            <div class="modal-buttons">
                <button class="modal-btn modal-cancel" id="flagCancel">Cancel</button>
                <button class="modal-btn modal-submit" id="flagSubmit">Flag</button>
            </div>
        </div>
    </div>
    
    <audio id="audioElement" preload="auto"></audio>
    
    <script>
        let currentIndex = 0;
        let files = [];
        let currentAudioFilename = null;
        let isPlaying = false;
        
        const laoWordEl = document.getElementById('laoWord');
        const romanizationEl = document.getElementById('romanization');
        const definitionEnEl = document.getElementById('definitionEn');
        const promptTextEl = document.getElementById('promptText');
        const progressEl = document.getElementById('progress');
        const imageSection = document.getElementById('imageSection');
        const placeholder = document.getElementById('placeholder');
        const dropZone = document.getElementById('dropZone');
        const statusEl = document.getElementById('status');
        const audioRows = document.getElementById('audioRows');
        
        const firstBtn = document.getElementById('firstBtn');
        const prevBtn = document.getElementById('prevBtn');
        const nextBtn = document.getElementById('nextBtn');
        const lastBtn = document.getElementById('lastBtn');
        const goodBtn = document.getElementById('goodBtn');
        const badBtn = document.getElementById('badBtn');
        const deleteBtn = document.getElementById('deleteBtn');
        const copyBtn = document.getElementById('copyBtn');
        
        const audioElement = document.getElementById('audioElement');
        const flagModal = document.getElementById('flagModal');
        const flagNotes = document.getElementById('flagNotes');
        const flagCancel = document.getElementById('flagCancel');
        const flagSubmit = document.getElementById('flagSubmit');
        
        let pendingFlagFilename = null;
        let pendingFlagBtn = null;
        
        async function loadFiles() {
            const resp = await fetch('/api/files');
            files = await resp.json();
            updateNav();
            loadCurrent();
        }
        
        function updateNav() {
            firstBtn.disabled = currentIndex === 0;
            prevBtn.disabled = currentIndex === 0;
            nextBtn.disabled = files.length === 0 || currentIndex === files.length - 1;
            lastBtn.disabled = files.length === 0 || currentIndex === files.length - 1;
            progressEl.textContent = files.length === 0 ? 'No images' : `Image ${currentIndex + 1} of ${files.length}`;
        }
        
        async function loadCurrent() {
            if (files.length === 0) return;
            
            // Stop any playing audio
            audioElement.pause();
            isPlaying = false;
            
            const filename = files[currentIndex];
            const resp = await fetch(`/api/word/${encodeURIComponent(filename)}`);
            const data = await resp.json();
            
            laoWordEl.textContent = data.lao_word || '-';
            romanizationEl.textContent = data.romanization || '-';
            definitionEnEl.textContent = data.definition_en || '-';
            promptTextEl.textContent = data.image_prompt || '-';
            
            // Build audio buttons
            const audioButtons = document.getElementById('audioButtons');
            audioButtons.innerHTML = '';
            if (data.audio_files) {
                data.audio_files.forEach((af) => {
                    const btn = document.createElement('button');
                    btn.className = 'audio-btn' + (af.flagged ? ' flagged' : '');
                    btn.dataset.url = af.url;
                    btn.dataset.filename = af.filename;
                    btn.innerHTML = `
                        <span>${af.label}</span>
                        <span class="play-icon">▶</span>
                        <span class="flag-icon" data-action="flag">🚩</span>
                    `;
                    btn.addEventListener('click', (e) => {
                        if (e.target.dataset.action === 'flag') {
                            handleFlag(af.filename, btn);
                        } else {
                            playAudio(af.url, af.filename, btn);
                        }
                    });
                    audioButtons.appendChild(btn);
                });
            }
            
            // Image
            if (data.has_image) {
                imageSection.innerHTML = `<img src="/outputs/${data.image_filename}" alt="Generated image">`;
                placeholder.style.display = 'none';
            } else {
                imageSection.innerHTML = `<div class="image-placeholder" id="placeholder">No image found</div>`;
            }
            
            updateNav();
        }
        
        function playAudio(url, filename, btn) {
            if (currentAudioFilename === filename && isPlaying) {
                audioElement.pause();
                return;
            }
            
            // Update all buttons to not playing
            document.querySelectorAll('.audio-btn').forEach(b => b.classList.remove('playing'));
            
            // If clicking a different audio, reload
            if (currentAudioFilename !== filename) {
                currentAudioFilename = filename;
                audioElement.src = url;
                audioElement.load();
            }
            
            btn.classList.add('playing');
            const playPromise = audioElement.play();
            if (playPromise !== undefined) {
                playPromise.catch(err => {
                    console.error('Playback failed:', err);
                    showStatus('Audio failed to load');
                    btn.classList.remove('playing');
                });
            }
        }
        
        function handleFlag(filename, btn) {
            const isFlagged = btn.classList.contains('flagged');
            
            if (isFlagged) {
                // Unflag
                saveAudioMarkLocal(filename, 'unchecked', '');
                btn.classList.remove('flagged');
                showStatus('Flag removed');
            } else {
                // Show modal
                pendingFlagFilename = filename;
                pendingFlagBtn = btn;
                flagNotes.value = btn.dataset.notes || '';
                flagModal.classList.add('show');
                flagNotes.focus();
            }
        }
        
        // Modal handlers
        flagSubmit.addEventListener('click', () => {
            if (pendingFlagFilename && pendingFlagBtn) {
                saveAudioMarkLocal(pendingFlagFilename, 'flagged', flagNotes.value, pendingFlagBtn);
                pendingFlagBtn.classList.add('flagged');
                pendingFlagBtn.dataset.notes = flagNotes.value;
                showStatus('Audio flagged!');
            }
            flagModal.classList.remove('show');
            pendingFlagFilename = null;
            pendingFlagBtn = null;
        });
        
        flagCancel.addEventListener('click', () => {
            flagModal.classList.remove('show');
            pendingFlagFilename = null;
            pendingFlagBtn = null;
        });
        
        function saveAudioMarkLocal(filename, status, notes, btn) {
            fetch(`/api/audio/mark/${encodeURIComponent(filename)}?status=${status}&notes=${encodeURIComponent(notes)}`, { method: 'POST' });
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
        
        // Copy prompt
        copyBtn.addEventListener('click', () => {
            navigator.clipboard.writeText(promptTextEl.textContent).then(() => {
                copyBtn.textContent = '✓ Copied!';
                copyBtn.classList.add('copied');
                setTimeout(() => { copyBtn.textContent = '📋 Copy'; copyBtn.classList.remove('copied'); }, 1500);
            });
        });
        
        // Image actions
        async function markImage(status) {
            if (files.length === 0) return;
            const filename = files[currentIndex];
            await fetch(`/api/mark/${encodeURIComponent(filename)}?status=${status}`, { method: 'POST' });
            showStatus(`Marked as ${status}!`);
            if (currentIndex < files.length - 1) { currentIndex++; loadCurrent(); }
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
        dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('dragover'); });
        dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));
        dropZone.addEventListener('drop', async e => {
            e.preventDefault();
            dropZone.classList.remove('dragover');
            if (files.length === 0) return;
            const filename = files[currentIndex];
            const file = e.dataTransfer.files[0];
            if (!file || !file.type.startsWith('image/')) { showStatus('Please drop an image!'); return; }
            const formData = new FormData();
            formData.append('image', file);
            const resp = await fetch(`/api/upload/${encodeURIComponent(filename)}`, { method: 'POST', body: formData });
            showStatus(resp.ok ? 'Image uploaded!' : 'Upload failed!');
            loadCurrent();
        });
        
        // Keyboard shortcuts
        document.addEventListener('keydown', e => {
            if (e.target.tagName === 'INPUT') return;
            
            if (e.key === 'ArrowLeft' && currentIndex > 0) { currentIndex--; loadCurrent(); }
            if (e.key === 'ArrowRight' && currentIndex < files.length - 1) { currentIndex++; loadCurrent(); }
            if (e.key === 'g') goodBtn.click();
            if (e.key === 'b') badBtn.click();
            if (e.key === 'd') deleteBtn.click();
            
            // Audio shortcuts 1, 2, 3
            if (e.key === '1' || e.key === '2' || e.key === '3') {
                const idx = parseInt(e.key) - 1;
                const btn = document.querySelectorAll('.audio-btn')[idx];
                if (btn) btn.click();
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
        
        # API: Get word data with audio files
        match = re.match(r'^/api/word/(.+)$', parsed.path)
        if match:
            filename = match.group(1)
            filepath = os.path.join(WORDS_DIR, unquote(filename))
            
            if not os.path.exists(filepath):
                self.send_error(404, 'File not found')
                return
            
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Check for image
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
            
            # Find audio files for this word
            # Extract word ID from filename: prompt_001_of_100_1.json -> w_0001
            word_id_match = re.search(r'_(\d+)\.json$', filename)
            word_id = None
            if word_id_match:
                num = word_id_match.group(1)
                word_id = f'w_{num.zfill(4)}'
            
            audio_files = []
            if word_id:
                # Look for word.m4a, word_example1.m4a, word_example2.m4a
                audio_names = [
                    (f'{word_id}_word.m4a', 'Word'),
                    (f'{word_id}_example1.m4a', 'Example 1'),
                    (f'{word_id}_example2.m4a', 'Example 2'),
                ]
                for audio_name, label in audio_names:
                    url = None
                    # Check both directories
                    for audio_dir in [VOCAB_AUDIO_DIR, AUDIO_DIR]:
                        if os.path.exists(os.path.join(audio_dir, audio_name)):
                            rel_path = os.path.relpath(
                                os.path.join(audio_dir, audio_name),
                                os.path.join(BASE_DIR, '..', '..', 'assets')
                            )
                            url = f'/assets/{rel_path}'
                            break
                    
                    if url:
                        mark = get_audio_mark(audio_name)
                        audio_files.append({
                            'filename': audio_name,
                            'label': label,
                            'url': url,
                            'flagged': mark.get('status') == 'flagged',
                            'notes': mark.get('notes', '')
                        })
            
            data['audio_files'] = audio_files
            self.send_json(data)
            return
        
        # Serve HTML for root
        if parsed.path == '/' or parsed.path == '/index.html':
            self.send_html(HTML)
            return
        
        # Serve audio assets
        if parsed.path.startswith('/assets/'):
            asset_path = unquote(parsed.path[9:])
            
            # Check both possible asset locations
            possible_paths = [
                os.path.join(BASE_DIR, '..', '..', 'assets', asset_path),
                os.path.join(BASE_DIR, '..', 'assets', asset_path),
            ]
            
            for full_path in possible_paths:
                if os.path.exists(full_path):
                    # Serve the file directly
                    with open(full_path, 'rb') as f:
                        content = f.read()
                    
                    # Determine content type
                    ext = os.path.splitext(full_path)[1].lower()
                    content_types = {
                        '.m4a': 'audio/mp4',
                        '.mp3': 'audio/mpeg',
                        '.wav': 'audio/wav',
                        '.ogg': 'audio/ogg',
                        '.aac': 'audio/aac',
                    }
                    content_type = content_types.get(ext, 'application/octet-stream')
                    
                    self.send_response(200)
                    self.send_header('Content-Type', content_type)
                    self.send_header('Content-Length', len(content))
                    self.send_header('Accept-Ranges', 'bytes')
                    self.end_headers()
                    self.wfile.write(content)
                    return
            
            self.send_error(404, 'File not found')
            return
        
        super().do_GET()
    
    def do_POST(self):
        parsed = urlparse(self.path)
        
        # API: Upload image
        match = re.match(r'^/api/upload/(.+)$', parsed.path)
        if match:
            filename = unquote(match.group(1))
            content_type = self.headers.get('Content-Type', '')
            content_length = int(self.headers.get('Content-Length', 0))
            image_data = self.rfile.read(content_length)
            
            ext_map = {'image/png': '.png', 'image/jpeg': '.jpg', 'image/webp': '.webp', 'image/gif': '.gif'}
            ext = ext_map.get(content_type, '.png')
            base_name = os.path.splitext(filename)[0]
            output_path = os.path.join(OUTPUTS_DIR, base_name + ext)
            
            with open(output_path, 'wb') as f:
                f.write(image_data)
            
            self.send_json({'success': True, 'filename': base_name + ext})
            return
        
        # API: Mark image
        match = re.match(r'^/api/mark/(.+)$', parsed.path)
        if match:
            filename = unquote(match.group(1))
            params = parse_qs(parsed.query)
            status = params.get('status', ['unknown'])[0]
            
            mark_file = os.path.join(MARKS_DIR, filename + '.json')
            with open(mark_file, 'w', encoding='utf-8') as f:
                json.dump({'status': status, 'filename': filename}, f)
            
            self.send_json({'success': True})
            return
        
        # API: Delete image
        match = re.match(r'^/api/delete/(.+)$', parsed.path)
        if match:
            filename = unquote(match.group(1))
            base_name = os.path.splitext(filename)[0]
            
            for ext in ['.png', '.jpg', '.jpeg', '.webp', '.gif']:
                img_path = os.path.join(OUTPUTS_DIR, base_name + ext)
                if os.path.exists(img_path):
                    os.remove(img_path)
            
            mark_file = os.path.join(MARKS_DIR, filename + '.json')
            if os.path.exists(mark_file):
                os.remove(mark_file)
            
            self.send_json({'success': True})
            return
        
        # API: Mark audio
        match = re.match(r'^/api/audio/mark/(.+)$', parsed.path)
        if match:
            filename = unquote(match.group(1))
            params = parse_qs(parsed.query)
            status = params.get('status', ['unchecked'])[0]
            notes = params.get('notes', [''])[0]
            
            save_audio_mark(filename, status, notes)
            self.send_json({'success': True, 'filename': filename, 'status': status})
            return
        
        self.send_error(405, 'Method not allowed')
    
    def send_json(self, data):
        response = json.dumps(data, ensure_ascii=False)
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(response))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))
    
    def send_html(self, html):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', len(html))
        self.end_headers()
        self.wfile.write(html.encode('utf-8'))


if __name__ == '__main__':
    print(f"""
╔══════════════════════════════════════════════════════╗
║           Lao Review Server                      ║
╠══════════════════════════════════════════════════════╣
║  Navigate to: http://localhost:{PORT}                 ║
║                                                      ║
║  Features:                                          ║
║    🖼️  Image Review - Mark good/bad, drag & drop      ║
║    🎧 Audio Clips - Listen and flag incorrect        ║
║                                                      ║
║  Image Controls:                                     ║
║    ← → - Navigate                                  ║
║    G - Mark Good                                     ║
║    B - Mark Bad                                      ║
║    D - Delete                                       ║
║    Drag & Drop - Upload image                       ║
║                                                      ║
║  Audio Controls:                                     ║
║    1, 2, 3 - Play audio clips                      ║
║    Flag button - Report incorrect audio              ║
║                                                      ║
║  Press Ctrl+C to stop                               ║
╚══════════════════════════════════════════════════════╝
    """)
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        httpd.serve_forever()
