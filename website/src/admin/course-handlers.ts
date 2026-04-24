/**
 * Course content handlers for teacher dashboard
 * Handles vocabulary, lessons, audio, examples, export, and settings
 */

import { Hono } from 'hono';
import { getCookie, setCookie, deleteCookie } from 'hono/cookie';
import { adminHTML } from './admin-page';

type Env = {
  ASSETS: KVNamespace;
  DB: D1Database;
  COURSE_DATA: R2Bucket;
  TEACHER_JWT_SECRET: string;
  ADMIN_EMAIL: string;
  GOOGLE_CLIENT_ID: string;
  GOOGLE_CLIENT_SECRET: string;
  ENVIRONMENT: string;
};

// Sample vocabulary data (in production, this would come from D1/R2)
const sampleVocabulary = [
  { id: '001', lao: 'ໂ', romanization: 'o', definition: 'Circle / O', category: 'vowels', audioStatus: 'recorded', exampleCount: 3 },
  { id: '002', lao: 'ເ', romanization: 'e', definition: 'Short e sound', category: 'vowels', audioStatus: 'pending', exampleCount: 2 },
  { id: '003', lao: 'ແ', romanization: 'ee', definition: 'Long ee sound', category: 'vowels', audioStatus: 'recorded', exampleCount: 4 },
  { id: '004', lao: 'ໄ', romanization: 'ai', definition: 'ai vowel combination', category: 'vowels', audioStatus: 'pending', exampleCount: 1 },
  { id: '005', lao: 'ໂ', romanization: 'aw', definition: 'aw vowel combination', category: 'vowels', audioStatus: 'recorded', exampleCount: 2 },
];

export const courseHandlers = {
  words: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const page = parseInt(c.req.query('page') || '1');
      const search = c.req.query('search') || '';
      const category = c.req.query('category') || '';
      const status = c.req.query('status') || '';
      
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Vocabulary Words</h2>
            <div style="display: flex; gap: 0.5rem;">
              <button class="btn btn-secondary" onclick="exportCSV()">📥 Export CSV</button>
              <button class="btn btn-primary" onclick="addWord()">+ Add Word</button>
            </div>
          </div>
          
          <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap;">
            <input type="text" class="form-input" placeholder="Search words..." 
                   style="max-width: 250px;" value="${search}"
                   onkeydown="if(event.key==='Enter') searchWords(this.value)">
            
            <select class="form-input" style="max-width: 180px;" onchange="filterByCategory(this.value)">
              <option value="">All categories</option>
              <option value="vowels" ${category === 'vowels' ? 'selected' : ''}>Vowels</option>
              <option value="consonants" ${category === 'consonants' ? 'selected' : ''}>Consonants</option>
              <option value="numbers" ${category === 'numbers' ? 'selected' : ''}>Numbers</option>
              <option value="verbs" ${category === 'verbs' ? 'selected' : ''}>Verbs</option>
              <option value="nouns" ${category === 'nouns' ? 'selected' : ''}>Nouns</option>
            </select>
            
            <select class="form-input" style="max-width: 180px;" onchange="filterByStatus(this.value)">
              <option value="">All status</option>
              <option value="complete" ${status === 'complete' ? 'selected' : ''}>Complete</option>
              <option value="pending" ${status === 'pending' ? 'selected' : ''}>Pending audio</option>
              <option value="needs_review" ${status === 'needs_review' ? 'selected' : ''}>Needs review</option>
            </select>
          </div>
          
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th> Lao </th>
                  <th> Romanization </th>
                  <th> Definition </th>
                  <th> Category </th>
                  <th> Audio </th>
                  <th> Examples </th>
                  <th> Actions </th>
                </tr>
              </thead>
              <tbody>
                ${sampleVocabulary.map(word => `
                  <tr>
                    <td><span class="lao-text">${word.lao}</span></td>
                    <td>${word.romanization}</td>
                    <td>${word.definition}</td>
                    <td><span class="badge badge-neutral">${word.category}</span></td>
                    <td>
                      <span class="badge ${word.audioStatus === 'recorded' ? 'badge-success' : 'badge-warning'}">
                        ${word.audioStatus === 'recorded' ? '✓' : '⏳'} ${word.audioStatus}
                      </span>
                    </td>
                    <td>${word.exampleCount} examples</td>
                    <td>
                      <button class="btn btn-secondary btn-sm" onclick="editWord('${word.id}')">Edit</button>
                      <button class="btn btn-secondary btn-sm" onclick="previewWord('${word.id}')">Preview</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
          
          <div class="pagination">
            <button class="page-btn" disabled>◀</button>
            <button class="page-btn active">1</button>
            <button class="page-btn">2</button>
            <button class="page-btn">3</button>
            <span>...</span>
            <button class="page-btn">25</button>
            <button class="page-btn">▶</button>
          </div>
        </div>
        
        <script>
          function searchWords(query) {
            window.location.href = '/admin/words?search=' + encodeURIComponent(query);
          }
          function filterByCategory(cat) {
            const url = new URL(window.location);
            url.searchParams.set('category', cat);
            window.location.href = url.toString();
          }
          function filterByStatus(status) {
            const url = new URL(window.location);
            url.searchParams.set('status', status);
            window.location.href = url.toString();
          }
          function editWord(id) {
            window.location.href = '/admin/words/' + id;
          }
          function previewWord(id) {
            window.location.href = '/admin/words/' + id + '/preview';
          }
          function addWord() {
            window.location.href = '/admin/words/new';
          }
          function exportCSV() {
            window.location.href = '/api/export/vocabulary?format=csv';
          }
        </script>
      `;
      
      return c.html(adminHTML(content, 'Vocabulary - Write Lao Admin'));
    })
    
    .get('/:id', (c) => {
      const id = c.req.param('id');
      
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Edit Word: <span class="lao-text">${sampleVocabulary[0].lao}</span></h2>
            <button class="btn btn-secondary" onclick="history.back()">← Back</button>
          </div>
          
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
            <div>
              <div class="form-group">
                <label class="form-label">Lao Script</label>
                <input type="text" class="form-input" value="${sampleVocabulary[0].lao}" placeholder="Enter Lao text">
              </div>
              
              <div class="form-group">
                <label class="form-label">Romanization</label>
                <input type="text" class="form-input" value="${sampleVocabulary[0].romanization}" placeholder="e.g., khòò">
              </div>
              
              <div class="form-group">
                <label class="form-label">English Definition</label>
                <input type="text" class="form-input" value="${sampleVocabulary[0].definition}" placeholder="e.g., to write">
              </div>
              
              <div class="form-group">
                <label class="form-label">Category</label>
                <select class="form-input">
                  <option value="vowels" selected>Vowels</option>
                  <option value="consonants">Consonants</option>
                  <option value="numbers">Numbers</option>
                  <option value="verbs">Verbs</option>
                  <option value="nouns">Nouns</option>
                </select>
              </div>
              
              <div class="form-group">
                <label class="form-label">Tags (comma separated)</label>
                <input type="text" class="form-input" value="essential, first-100" placeholder="Add tags...">
              </div>
            </div>
            
            <div>
              <div class="panel" style="margin-bottom: 1rem;">
                <h3 style="margin-bottom: 1rem;">Audio Recording</h3>
                <div class="audio-recorder">
                  <button class="record-btn" id="recordBtn" onclick="toggleRecording()">
                    🎤
                  </button>
                  <p style="margin-top: 0.75rem; color: var(--text-muted);">
                    Click to record pronunciation
                  </p>
                  <div class="waveform" id="waveform" style="display: none;">
                    ${Array(20).fill('<div class="waveform-bar" style="animation-delay: 0.1s"></div>').join('')}
                  </div>
                  <div id="recordedAudio" style="margin-top: 1rem;"></div>
                </div>
              </div>
              
              <div class="panel">
                <h3 style="margin-bottom: 1rem;">Example Sentences</h3>
                <div id="examplesList">
                  <div style="padding: 0.75rem; background: var(--surface-2); border-radius: 8px; margin-bottom: 0.5rem;">
                    <span class="lao-text" style="font-size: 1.25rem;">ໂຕເເ</span>
                    <p style="margin-top: 0.5rem; color: var(--text-muted);">A person / person (to be)</p>
                    <button class="btn btn-secondary btn-sm" style="margin-top: 0.5rem;">Play audio</button>
                  </div>
                  <div style="padding: 0.75rem; background: var(--surface-2); border-radius: 8px; margin-bottom: 0.5rem;">
                    <span class="lao-text" style="font-size: 1.25rem;">ໂຕເເ ເປັນ ຄົນ</span>
                    <p style="margin-top: 0.5rem; color: var(--text-muted);">He/she is a person.</p>
                    <button class="btn btn-secondary btn-sm" style="margin-top: 0.5rem;">Play audio</button>
                  </div>
                </div>
                <button class="btn btn-secondary" style="width: 100%; margin-top: 0.75rem;" onclick="addExample()">+ Add Example</button>
              </div>
            </div>
          </div>
          
          <div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; padding-top: 1rem; border-top: 1px solid var(--border);">
            <button class="btn btn-secondary">Cancel</button>
            <button class="btn btn-primary" onclick="saveWord()">Save Changes</button>
          </div>
        </div>
        
        <script>
          let isRecording = false;
          let audioRecorder = null;
          
          async function toggleRecording() {
            const btn = document.getElementById('recordBtn');
            const waveform = document.getElementById('waveform');
            
            if (!isRecording) {
              try {
                audioRecorder = new AudioRecorder((blob) => {
                  const url = URL.createObjectURL(blob);
                  document.getElementById('recordedAudio').innerHTML = 
                    '<audio controls src="' + url + '" style="width: 100%;"></audio>' +
                    '<div style="display: flex; gap: 0.5rem; margin-top: 0.5rem;">' +
                    '<button class="btn btn-success btn-sm" onclick="saveAudio()">Save Recording</button>' +
                    '<button class="btn btn-secondary btn-sm" onclick="discardAudio()">Discard</button>' +
                    '</div>';
                });
                await audioRecorder.start();
                isRecording = true;
                btn.classList.add('recording');
                btn.textContent = '⏹';
                waveform.style.display = 'flex';
              } catch (err) {
                alert('Microphone access denied. Please allow microphone access.');
              }
            } else {
              audioRecorder.stop();
              isRecording = false;
              btn.classList.remove('recording');
              btn.textContent = '🎤';
              waveform.style.display = 'none';
            }
          }
          
          function saveWord() {
            showToast('Word saved successfully!');
          }
          
          function addExample() {
            window.location.href = '/admin/examples/new?wordId=${id}';
          }
        </script>
      `;
      
      return c.html(adminHTML(content, `Edit Word - Write Lao Admin`));
    }),
  
  lessons: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Alphabet Lessons</h2>
            <button class="btn btn-primary" onclick="addLesson()">+ Add Lesson</button>
          </div>
          
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th> # </th>
                  <th> Title (Lao) </th>
                  <th> Characters </th>
                  <th> Words </th>
                  <th> Status </th>
                  <th> Actions </th>
                </tr>
              </thead>
              <tbody>
                ${[1,2,3,4,5,6,7,8,9,10].map(i => `
                  <tr>
                    <td>${i}</td>
                    <td><span class="lao-text">${['ແ', 'ໂ', 'ໄ', 'ໃ', 'ໍ', 'ກ', 'ຂ', 'ຄ', 'ງ', '່'][i-1]}</span> Lesson ${i}</td>
                    <td>${[4, 5, 3, 2, 4, 6, 3, 5, 4, 6][i-1]} characters</td>
                    <td>${[12, 15, 10, 8, 14, 18, 9, 13, 11, 16][i-1]} words</td>
                    <td><span class="badge badge-success">Complete</span></td>
                    <td>
                      <button class="btn btn-secondary btn-sm">Edit</button>
                      <button class="btn btn-secondary btn-sm">Preview</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </div>
        
        <script>
          function addLesson() { window.location.href = '/admin/lessons/new'; }
        </script>
      `;
      
      return c.html(adminHTML(content, 'Lessons - Write Lao Admin'));
    }),
  
  audio: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Audio Recordings</h2>
            <div style="display: flex; gap: 0.5rem;">
              <select class="form-input" style="width: auto;">
                <option value="">All status</option>
                <option value="recorded">Recorded</option>
                <option value="pending">Pending</option>
                <option value="needs_review">Needs Review</option>
              </select>
              <button class="btn btn-secondary">📥 Export All</button>
            </div>
          </div>
          
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th> Word </th>
                  <th> Lao Script </th>
                  <th> Recording </th>
                  <th> Duration </th>
                  <th> Status </th>
                  <th> Actions </th>
                </tr>
              </thead>
              <tbody>
                ${sampleVocabulary.map((word, i) => `
                  <tr>
                    <td>${word.romanization}</td>
                    <td><span class="lao-text">${word.lao}</span></td>
                    <td>
                      ${word.audioStatus === 'recorded' ? 
                        '<audio controls style="height: 32px; width: 150px;"></audio>' : 
                        '<button class="btn btn-secondary btn-sm">🎤 Record</button>'
                      }
                    </td>
                    <td>${word.audioStatus === 'recorded' ? (i + 1) + '.2s' : '-'}</td>
                    <td><span class="badge ${word.audioStatus === 'recorded' ? 'badge-success' : 'badge-warning'}">${word.audioStatus}</span></td>
                    <td>
                      <button class="btn btn-secondary btn-sm">Play</button>
                      <button class="btn btn-secondary btn-sm">Re-record</button>
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
          
          <div style="margin-top: 2rem; padding: 2rem; background: var(--surface-2); border-radius: 12px; text-align: center;">
            <h3 style="margin-bottom: 1rem;">Quick Record</h3>
            <p style="color: var(--text-muted); margin-bottom: 1.5rem;">Select a word and record its pronunciation</p>
            
            <div style="display: flex; gap: 1rem; justify-content: center; margin-bottom: 1.5rem;">
              <select class="form-input" style="max-width: 200px;">
                <option value="">Select word...</option>
                ${sampleVocabulary.map(w => `<option value="${w.id}">${w.lao} - ${w.romanization}</option>`).join('')}
              </select>
            </div>
            
            <button class="record-btn" style="width: 100px; height: 100px; font-size: 2.5rem;">
              🎤
            </button>
            <p style="margin-top: 1rem; color: var(--text-muted); font-size: 0.875rem;">
              Press to start recording
            </p>
          </div>
        </div>
      `;
      
      return c.html(adminHTML(content, 'Audio - Write Lao Admin'));
    }),
  
  examples: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Example Sentences</h2>
            <button class="btn btn-primary" onclick="addExample()">+ Add Example</button>
          </div>
          
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th> Lao </th>
                  <th> Translation </th>
                  <th> Word </th>
                  <th> Audio </th>
                  <th> Actions </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><span class="lao-text">ໂຕເເ</span></td>
                  <td>A person, self</td>
                  <td>Word #001</td>
                  <td><span class="badge badge-success">✓</span></td>
                  <td>
                    <button class="btn btn-secondary btn-sm">Edit</button>
                    <button class="btn btn-secondary btn-sm">Play</button>
                  </td>
                </tr>
                <tr>
                  <td><span class="lao-text">ໂຕເເ ເປັ</span></td>
                  <td>He/she is</td>
                  <td>Word #001</td>
                  <td><span class="badge badge-success">✓</span></td>
                  <td>
                    <button class="btn btn-secondary btn-sm">Edit</button>
                    <button class="btn btn-secondary btn-sm">Play</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
        <script>
          function addExample() { window.location.href = '/admin/examples/new'; }
        </script>
      `;
      
      return c.html(adminHTML(content, 'Examples - Write Lao Admin'));
    }),
  
  export: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Export Course Bundle</h2>
          </div>
          
          <p style="color: var(--text-muted); margin-bottom: 1.5rem;">
            Generate and download the course content bundle for app integration.
            This includes vocabulary, lessons, examples, and audio files.
          </p>
          
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">
            <div class="panel" style="border: 2px dashed var(--border);">
              <h3 style="margin-bottom: 0.5rem;">📚 Vocabulary</h3>
              <p style="color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem;">
                500 words with definitions, romanization, and tags
              </p>
              <span class="badge badge-success">500 words</span>
            </div>
            
            <div class="panel" style="border: 2px dashed var(--border);">
              <h3 style="margin-bottom: 0.5rem;">📖 Lessons</h3>
              <p style="color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem;">
                21 alphabet lessons with character data
              </p>
              <span class="badge badge-success">21 lessons</span>
            </div>
            
            <div class="panel" style="border: 2px dashed var(--border);">
              <h3 style="margin-bottom: 0.5rem;">✏️ Examples</h3>
              <p style="color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem;">
                Example sentences with translations
              </p>
              <span class="badge badge-success">1,200+ examples</span>
            </div>
            
            <div class="panel" style="border: 2px dashed var(--border);">
              <h3 style="margin-bottom: 0.5rem;">🎤 Audio</h3>
              <p style="color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem;">
                Native speaker recordings
              </p>
              <span class="badge badge-warning">340 pending</span>
            </div>
          </div>
          
          <div style="margin-top: 2rem; padding: 1.5rem; background: var(--surface-2); border-radius: 12px;">
            <h3 style="margin-bottom: 1rem;">Export Format</h3>
            <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap;">
              <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                <input type="radio" name="format" value="json" checked> JSON Bundle (recommended)
              </label>
              <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                <input type="radio" name="format" value="csv"> CSV Export
              </label>
              <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
                <input type="radio" name="format" value="zip"> ZIP with Audio
              </label>
            </div>
            
            <div style="display: flex; gap: 0.5rem;">
              <button class="btn btn-primary" onclick="generateBundle()">📦 Generate Bundle</button>
              <button class="btn btn-secondary" onclick="previewBundle()">👁 Preview</button>
            </div>
          </div>
        </div>
        
        <div class="panel">
          <h3 style="margin-bottom: 1rem;">Recent Exports</h3>
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th> Date </th>
                  <th> Format </th>
                  <th> Size </th>
                  <th> Status </th>
                  <th> Actions </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>April 23, 2026</td>
                  <td>JSON Bundle</td>
                  <td>4.2 MB</td>
                  <td><span class="badge badge-success">Complete</span></td>
                  <td>
                    <button class="btn btn-secondary btn-sm">Download</button>
                  </td>
                </tr>
                <tr>
                  <td>April 20, 2026</td>
                  <td>ZIP with Audio</td>
                  <td>85 MB</td>
                  <td><span class="badge badge-success">Complete</span></td>
                  <td>
                    <button class="btn btn-secondary btn-sm">Download</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
        <script>
          function generateBundle() {
            showToast('Bundle generation started...');
          }
          function previewBundle() {
            window.location.href = '/admin/export/preview';
          }
        </script>
      `;
      
      return c.html(adminHTML(content, 'Export - Write Lao Admin'));
    }),
  
  settings: new Hono<{ Bindings: Env }>()
    .get('/', (c) => {
      const content = `
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Account Settings</h2>
          </div>
          
          <div class="form-group">
            <label class="form-label">Display Name</label>
            <input type="text" class="form-input" value="Teacher">
          </div>
          
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" class="form-input" value="teacher@email.com" disabled>
          </div>
          
          <div class="form-group">
            <label class="form-label">Role</label>
            <span class="badge badge-success">Admin</span>
          </div>
          
          <button class="btn btn-primary" onclick="saveSettings()">Save Settings</button>
        </div>
        
        <div class="panel">
          <div class="panel-header">
            <h2 class="panel-title">Security</h2>
          </div>
          
          <div class="form-group">
            <label class="form-label">Change Password</label>
            <input type="password" class="form-input" placeholder="Current password">
            <input type="password" class="form-input" placeholder="New password" style="margin-top: 0.5rem;">
            <input type="password" class="form-input" placeholder="Confirm new password" style="margin-top: 0.5rem;">
          </div>
          
          <button class="btn btn-secondary" onclick="changePassword()">Update Password</button>
        </div>
        
        <div class="panel" style="border-color: var(--error);">
          <h3 style="margin-bottom: 1rem; color: var(--error);">Danger Zone</h3>
          <p style="color: var(--text-muted); margin-bottom: 1rem;">
            These actions are irreversible. Proceed with caution.
          </p>
          <button class="btn btn-danger">Delete Account</button>
        </div>
        
        <script>
          function saveSettings() { showToast('Settings saved!'); }
          function changePassword() { showToast('Password updated!'); }
        </script>
      `;
      
      return c.html(adminHTML(content, 'Settings - Write Lao Admin'));
    }),
};