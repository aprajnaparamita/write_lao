#!/usr/bin/env python3
"""
Word Review Server for Write It Lao
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
COURSE_FILE = os.path.join(BASE_DIR, '..', '..', 'assets', 'vocab', 'course.json')
OUTPUTS_DIR = os.path.join(BASE_DIR, '..', '..', 'outputs')
MARKS_DIR = os.path.join(BASE_DIR, '..', '..', 'marks')

# Asset directories
ASSETS_DIR = os.path.join(BASE_DIR, '..', '..', 'assets')
VOCAB_IMAGES_DIR = os.path.join(ASSETS_DIR, 'vocab', 'images')
VOCAB_AUDIO_DIR = os.path.join(ASSETS_DIR, 'vocab', 'audio')

# Step 5 definition prompts directory (contains image prompts)
STEP5_PROMPTS_DIR = os.path.join(BASE_DIR, 'step5_definition_prompts')

# Ensure directories exist
os.makedirs(OUTPUTS_DIR, exist_ok=True)
os.makedirs(MARKS_DIR, exist_ok=True)

# Load course data
def load_course_data():
    """Load the course.json file with all word data."""
    if os.path.exists(COURSE_FILE):
        with open(COURSE_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return None

def get_sorted_words(course_data):
    """Get all words sorted by word_id."""
    words = course_data.get('words', [])
    words.sort(key=lambda x: x['word_id'])
    return words

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
        if os.path.exists(mark_file):
            os.remove(mark_file)
    else:
        with open(mark_file, 'w', encoding='utf-8') as f:
            json.dump({'status': status, 'filename': filename, 'notes': notes}, f)

def load_step5_prompts():
    """Load all step5 definition prompts to get image prompts."""
    prompts = {}
    if os.path.exists(STEP5_PROMPTS_DIR):
        for filename in os.listdir(STEP5_PROMPTS_DIR):
            if filename.endswith('.json'):
                filepath = os.path.join(STEP5_PROMPTS_DIR, filename)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    # Each file contains prompts for multiple words keyed by Lao word
                    for lao_word, word_data in data.items():
                        if 'image_prompt' in word_data:
                            prompts[lao_word] = word_data['image_prompt']
                except Exception:
                    pass
    return prompts

# Pre-load step5 prompts for image prompts
IMAGE_PROMPTS_CACHE = load_step5_prompts()
print(f"Loaded {len(IMAGE_PROMPTS_CACHE)} image prompts from step5_definition_prompts")


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
        .container { max-width: 1000px; margin: 0 auto; }
        .nav-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .progress { color: #888; margin-right: 15px; }
        .nav-btn {
            padding: 10px 16px;
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
            cursor: pointer;
        }
        .audio-btn .flag-icon:hover { opacity: 1; }
        .audio-btn.flagged .flag-icon { 
            opacity: 1; 
            color: #e94560;
            background: rgba(233, 69, 96, 0.2);
            border-radius: 3px;
            padding: 2px 4px;
        }
        .audio-btn.flagged { border-color: #e94560; }
        
        /* Tooltip for flagged audio */
        .flag-tooltip {
            position: relative;
        }
        .flag-tooltip::after {
            content: attr(data-notes);
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: #333;
            color: #fff;
            padding: 6px 10px;
            border-radius: 4px;
            font-size: 11px;
            white-space: nowrap;
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.2s;
            z-index: 100;
            margin-bottom: 5px;
        }
        .flag-tooltip:hover::after {
            opacity: 1;
            visibility: visible;
        }
        
        .prompt-section {
            background: #0f3460;
            border-radius: 8px;
            padding: 12px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            height: 100%;
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
        let words = [];
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
        const audioButtons = document.getElementById('audioButtons');
        
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
        
        async function loadWords() {
            const resp = await fetch('/api/words');
            words = await resp.json();
            updateNav();
            loadCurrent();
        }
        
        function updateNav() {
            firstBtn.disabled = currentIndex === 0;
            prevBtn.disabled = currentIndex === 0;
            nextBtn.disabled = words.length === 0 || currentIndex === words.length - 1;
            lastBtn.disabled = words.length === 0 || currentIndex === words.length - 1;
            progressEl.textContent = words.length === 0 ? 'No words' : `Word ${currentIndex + 1} of ${words.length}`;
        }
        
        async function loadCurrent() {
            if (words.length === 0) return;
            
            // Stop any playing audio
            audioElement.pause();
            isPlaying = false;
            
            const word = words[currentIndex];
            
            laoWordEl.textContent = word.lao_word || '-';
            romanizationEl.textContent = word.romanization || '-';
            definitionEnEl.textContent = word.definitions_en || word.definitions?.en || '-';
            promptTextEl.textContent = word.image_prompt || word.prompt || `Image prompt for ${word.lao_word}`;
            
            // Build audio buttons
            audioButtons.innerHTML = '';
            
            // Word audio
            if (word.audio_path) {
                const wordMark = getAudioMarkLocal(word.audio_path);
                const isFlagged = word.audio_flagged || wordMark.flagged;
                const notes = word.audio_notes || '';
                const btn = createAudioBtn(word.audio_path, 'Word', word.audio_url, isFlagged, notes);
                audioButtons.appendChild(btn);
            }
            
            // Example audio
            if (word.examples) {
                word.examples.forEach((ex, idx) => {
                    const exampleMark = getAudioMarkLocal(ex.audio_path);
                    const isFlagged = ex.flagged || exampleMark.flagged;
                    const notes = ex.notes || '';
                    const label = `Example ${idx + 1}`;
                    const btn = createAudioBtn(ex.audio_path, label, ex.audio_url, isFlagged, notes);
                    audioButtons.appendChild(btn);
                });
            }
            
            // Image
            if (word.has_image) {
                // Use cache-busting to ensure fresh image after upload
                const cacheBuster = Date.now();
                imageSection.innerHTML = `<img src="/vocab/images/${word.image_filename}?${cacheBuster}" alt="Generated image">`;
            } else {
                imageSection.innerHTML = `<div class="image-placeholder" id="placeholder">No image found</div>`;
            }
            
            updateNav();
        }
        
        function createAudioBtn(filepath, label, url, flagged, notes = '') {
            const btn = document.createElement('button');
            btn.className = 'audio-btn' + (flagged ? ' flagged' : '');
            btn.dataset.url = url;
            btn.dataset.filepath = filepath;
            btn.dataset.notes = notes || '';
            const tooltipClass = flagged && notes ? ' flag-tooltip' : '';
            btn.innerHTML = `
                <span>${label}</span>
                <span class="play-icon">▶</span>
                <span class="flag-icon${tooltipClass}" data-action="flag" ${flagged && notes ? `data-notes="${escapeHtml(notes)}"` : ''}>🚩</span>
            `;
            btn.addEventListener('click', (e) => {
                if (e.target.dataset.action === 'flag') {
                    handleFlag(filepath, btn);
                } else {
                    playAudio(url, filepath, btn);
                }
            });
            return btn;
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        function getAudioMarkLocal(filepath) {
            // Check local state first
            const btn = document.querySelector(`.audio-btn[data-filepath="${filepath}"]`);
            if (btn && btn.classList.contains('flagged')) {
                return { status: 'flagged' };
            }
            return { status: 'unchecked' };
        }
        
        function playAudio(url, filepath, btn) {
            if (currentAudioFilename === filepath && isPlaying) {
                audioElement.pause();
                return;
            }
            
            // Update all buttons to not playing
            document.querySelectorAll('.audio-btn').forEach(b => b.classList.remove('playing'));
            
            // If clicking a different audio, reload
            if (currentAudioFilename !== filepath) {
                currentAudioFilename = filepath;
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
        
        function handleFlag(filepath, btn) {
            const isFlagged = btn.classList.contains('flagged');
            
            if (isFlagged) {
                // Unflag
                saveAudioMarkLocal(filepath, 'unchecked', '');
                btn.classList.remove('flagged');
                btn.dataset.notes = '';
                // Remove tooltip from flag icon
                const flagIcon = btn.querySelector('.flag-icon');
                flagIcon.classList.remove('flag-tooltip');
                flagIcon.removeAttribute('data-notes');
                showStatus('Flag removed');
            } else {
                // Show modal
                pendingFlagFilename = filepath;
                pendingFlagBtn = btn;
                flagNotes.value = btn.dataset.notes || '';
                flagModal.classList.add('show');
                flagNotes.focus();
            }
        }
        
        function saveAudioMarkLocal(filepath, status, notes) {
            fetch(`/api/audio/mark/${encodeURIComponent(filepath)}?status=${status}&notes=${encodeURIComponent(notes)}`, { method: 'POST' });
        }
        
        // Modal handlers
        flagSubmit.addEventListener('click', () => {
            if (pendingFlagFilename && pendingFlagBtn) {
                const notes = flagNotes.value;
                saveAudioMarkLocal(pendingFlagFilename, 'flagged', notes);
                pendingFlagBtn.classList.add('flagged');
                pendingFlagBtn.dataset.notes = notes;
                
                // Update the flag icon with tooltip if notes exist
                const flagIcon = pendingFlagBtn.querySelector('.flag-icon');
                if (notes) {
                    flagIcon.classList.add('flag-tooltip');
                    flagIcon.setAttribute('data-notes', escapeHtml(notes));
                } else {
                    flagIcon.classList.remove('flag-tooltip');
                    flagIcon.removeAttribute('data-notes');
                }
                
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
        
        // Audio events
        audioElement.addEventListener('play', () => { isPlaying = true; });
        audioElement.addEventListener('pause', () => { isPlaying = false; });
        audioElement.addEventListener('ended', () => { 
            isPlaying = false; 
            document.querySelectorAll('.audio-btn').forEach(b => b.classList.remove('playing'));
        });
        
        function showStatus(msg) {
            statusEl.textContent = msg;
            statusEl.classList.add('show');
            setTimeout(() => statusEl.classList.remove('show'), 2000);
        }
        
        // Navigation
        firstBtn.addEventListener('click', () => { currentIndex = 0; loadCurrent(); });
        prevBtn.addEventListener('click', () => { if (currentIndex > 0) { currentIndex--; loadCurrent(); } });
        nextBtn.addEventListener('click', () => { if (currentIndex < words.length - 1) { currentIndex++; loadCurrent(); } });
        lastBtn.addEventListener('click', () => { currentIndex = words.length - 1; loadCurrent(); });
        
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
            if (words.length === 0) return;
            const word = words[currentIndex];
            await fetch(`/api/mark/${encodeURIComponent(word.word_id)}?status=${status}`, { method: 'POST' });
            showStatus(`Marked as ${status}!`);
            if (currentIndex < words.length - 1) { currentIndex++; loadCurrent(); }
        }
        
        goodBtn.addEventListener('click', () => markImage('good'));
        badBtn.addEventListener('click', () => markImage('bad'));
        
        deleteBtn.addEventListener('click', async () => {
            if (words.length === 0) return;
            const word = words[currentIndex];
            await fetch(`/api/delete/${encodeURIComponent(word.word_id)}`, { method: 'POST' });
            showStatus('Image deleted!');
            loadCurrent();
        });
        
        // Drag and drop
        dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('dragover'); });
        dropZone.addEventListener('dragleave', () => dropZone.classList.remove('dragover'));
        dropZone.addEventListener('drop', async e => {
            e.preventDefault();
            dropZone.classList.remove('dragover');
            if (words.length === 0) return;
            const word = words[currentIndex];
            const file = e.dataTransfer.files[0];
            if (!file || !file.type.startsWith('image/')) { showStatus('Please drop an image!'); return; }
            const formData = new FormData();
            formData.append('image', file);
            const resp = await fetch(`/api/upload/${encodeURIComponent(word.word_id)}`, { method: 'POST', body: formData });
            showStatus(resp.ok ? 'Image uploaded!' : 'Upload failed!');
            loadCurrent();
        });
        
        // Keyboard shortcuts
        document.addEventListener('keydown', e => {
            if (e.target.tagName === 'INPUT') return;
            
            if (e.key === 'ArrowLeft' && currentIndex > 0) { currentIndex--; loadCurrent(); }
            if (e.key === 'ArrowRight' && currentIndex < words.length - 1) { currentIndex++; loadCurrent(); }
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
        loadWords();
    </script>
</body>
</html>'''


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)
    
    def do_GET(self):
        parsed = urlparse(self.path)
        
        # API: Get all words
        if parsed.path == '/api/words':
            course_data = load_course_data()
            if not course_data:
                self.send_json({'error': 'Course data not found'})
                return
            
            words = get_sorted_words(course_data)
            
            # Process each word to add useful data
            for word in words:
                word_id = word['word_id']
                
                # Check for generated image (in outputs/ first, then original vocab/)
                image_filename = f'{word_id}.png'
                output_path = os.path.join(OUTPUTS_DIR, image_filename)
                vocab_path = os.path.join(ASSETS_DIR, 'vocab', 'images', image_filename)
                has_image = os.path.exists(output_path) or os.path.exists(vocab_path)
                word['has_image'] = has_image
                word['image_filename'] = image_filename
                
                # Add audio URLs
                if word.get('audio_path'):
                    word['audio_url'] = f'/assets/{word["audio_path"]}'
                
                for ex in word.get('examples', []):
                    if ex.get('audio_path'):
                        ex['audio_url'] = f'/assets/{ex["audio_path"]}'
                
                # Add definition_en
                if 'definitions' in word:
                    word['definitions_en'] = word['definitions'].get('en', '')
                
                # Add image prompt from step5 definitions
                lao_word = word.get('lao_word', '')
                if lao_word in IMAGE_PROMPTS_CACHE:
                    word['image_prompt'] = IMAGE_PROMPTS_CACHE[lao_word]
                
                # Add audio mark status
                if word.get('audio_path'):
                    mark = get_audio_mark(word['audio_path'])
                    word['audio_flagged'] = mark.get('status') == 'flagged'
                
                for ex in word.get('examples', []):
                    if ex.get('audio_path'):
                        mark = get_audio_mark(ex['audio_path'])
                        ex['flagged'] = mark.get('status') == 'flagged'
            
            self.send_json(words)
            return
        
        # Serve HTML for root
        if parsed.path == '/' or parsed.path == '/index.html':
            self.send_html(HTML)
            return
        
        # Serve vocab images from assets/vocab/images/
        if parsed.path.startswith('/vocab/images/'):
            image_name = unquote(parsed.path[14:])  # Remove '/vocab/images/'
            
            # Strip query string (for cache-busting)
            if '?' in image_name:
                image_name = image_name.split('?')[0]
            
            # Check assets/vocab/images/
            image_path = os.path.join(ASSETS_DIR, 'vocab', 'images', image_name)
            if os.path.exists(image_path):
                with open(image_path, 'rb') as f:
                    content = f.read()
                self.send_file(content, '.png', 'image/png')
                return
            
            # Also check relative path like 'images/w_0001.png'
            relative_path = os.path.join(ASSETS_DIR, image_name)
            if os.path.exists(relative_path):
                with open(relative_path, 'rb') as f:
                    content = f.read()
                self.send_file(content, '.png', 'image/png')
                return
            
            self.send_error(404, 'Image not found')
            return
        
        # Serve audio assets
        if parsed.path.startswith('/assets/'):
            asset_path = unquote(parsed.path[8:])  # Remove '/assets/' (8 chars)
            
            # Try direct path under assets
            full_path = os.path.join(ASSETS_DIR, asset_path)
            if os.path.exists(full_path):
                with open(full_path, 'rb') as f:
                    content = f.read()
                ext = os.path.splitext(full_path)[1].lower()
                content_types = {
                    '.m4a': 'audio/mp4',
                    '.mp3': 'audio/mpeg',
                    '.wav': 'audio/wav',
                    '.ogg': 'audio/ogg',
                    '.aac': 'audio/aac',
                }
                content_type = content_types.get(ext, 'application/octet-stream')
                self.send_file(content, ext, content_type)
                return
            
            # Try under assets/vocab/ for paths like 'audio/w_0001.m4a'
            vocab_path = os.path.join(ASSETS_DIR, 'vocab', asset_path)
            if os.path.exists(vocab_path):
                with open(vocab_path, 'rb') as f:
                    content = f.read()
                ext = os.path.splitext(vocab_path)[1].lower()
                content_types = {
                    '.m4a': 'audio/mp4',
                    '.mp3': 'audio/mpeg',
                    '.wav': 'audio/wav',
                    '.ogg': 'audio/ogg',
                    '.aac': 'audio/aac',
                }
                content_type = content_types.get(ext, 'application/octet-stream')
                self.send_file(content, ext, content_type)
                return
            
            self.send_error(404, 'File not found')
            return
        
        super().do_GET()
    
    def do_POST(self):
        parsed = urlparse(self.path)
        
        # API: Upload image
        match = re.match(r'^/api/upload/(.+)$', parsed.path)
        if match:
            word_id = unquote(match.group(1))
            
            # Read all data from the request body
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length)
            
            # Find PNG signature (89 50 4E 47) in the body
            # Multipart form data wraps the file, so we need to find the actual PNG data
            png_sig = b'\x89PNG'
            png_start = body.find(png_sig)
            
            if png_start == -1:
                # Try to find any image data
                # For JPEG: FF D8 FF
                jpeg_sig = b'\xff\xd8\xff'
                jpeg_start = body.find(jpeg_sig)
                if jpeg_start != -1:
                    image_data = body[jpeg_start:]
                    ext = '.jpg'
                else:
                    self.send_json({'error': 'No image data found'})
                    return
            else:
                image_data = body[png_start:]
                ext = '.png'
            
            # Save directly to assets/vocab/images/ (overwrite original)
            output_path = os.path.join(ASSETS_DIR, 'vocab', 'images', word_id + ext)
            with open(output_path, 'wb') as f:
                f.write(image_data)
            
            self.send_json({'success': True, 'filename': word_id + ext, 'size': len(image_data), 'path': output_path})
            return
        
        # API: Mark image
        match = re.match(r'^/api/mark/(.+)$', parsed.path)
        if match:
            word_id = unquote(match.group(1))
            params = parse_qs(parsed.query)
            status = params.get('status', ['unknown'])[0]
            
            mark_file = os.path.join(MARKS_DIR, word_id + '.json')
            with open(mark_file, 'w', encoding='utf-8') as f:
                json.dump({'status': status, 'word_id': word_id}, f)
            
            self.send_json({'success': True})
            return
        
        # API: Delete image
        match = re.match(r'^/api/delete/(.+)$', parsed.path)
        if match:
            word_id = unquote(match.group(1))
            
            for ext in ['.png', '.jpg', '.jpeg', '.webp', '.gif']:
                img_path = os.path.join(OUTPUTS_DIR, word_id + ext)
                if os.path.exists(img_path):
                    os.remove(img_path)
            
            mark_file = os.path.join(MARKS_DIR, word_id + '.json')
            if os.path.exists(mark_file):
                os.remove(mark_file)
            
            self.send_json({'success': True})
            return
        
        # API: Mark audio
        match = re.match(r'^/api/audio/mark/(.+)$', parsed.path)
        if match:
            filepath = unquote(match.group(1))
            params = parse_qs(parsed.query)
            status = params.get('status', ['unchecked'])[0]
            notes = params.get('notes', [''])[0]
            
            save_audio_mark(filepath, status, notes)
            self.send_json({'success': True, 'filename': filepath, 'status': status})
            return
        
        self.send_error(405, 'Method not allowed')
    
    def send_json(self, data):
        response = json.dumps(data, ensure_ascii=False)
        response_bytes = response.encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(response_bytes))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(response_bytes)
    
    def send_html(self, html):
        html_bytes = html.encode('utf-8')
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', len(html_bytes))
        self.end_headers()
        self.wfile.write(html_bytes)
    
    def send_file(self, content, ext, content_type):
        self.send_response(200)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', len(content))
        self.send_header('Accept-Ranges', 'bytes')
        self.end_headers()
        self.wfile.write(content)


if __name__ == '__main__':
    # Load course for info
    course = load_course_data()
    word_count = len(course.get('words', [])) if course else 0
    
    print(f"""
╔══════════════════════════════════════════════════════╗
║           Lao Review Server                      ║
╠══════════════════════════════════════════════════════╣
║  Navigate to: http://localhost:{PORT}                 ║
║                                                      ║
║  Words loaded: {word_count}                            ║
║                                                      ║
║  Features:                                          ║
║    🖼️  Image Review - Mark good/bad, drag & drop      ║
║    🎧 Audio Buttons - Listen and flag incorrect       ║
║                                                      ║
║  Controls:                                          ║
║    ← → - Navigate                                  ║
║    G - Mark Good                                     ║
║    B - Mark Bad                                      ║
║    D - Delete                                       ║
║    1, 2, 3 - Play audio clips                      ║
║    Drag & Drop - Upload image                       ║
║                                                      ║
║  Press Ctrl+C to stop                               ║
╚══════════════════════════════════════════════════════╝
    """)
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        httpd.serve_forever()