// ==========================================================================
// AIBO (相棒) - Japanese Stationery & Tactile Engine
// ==========================================================================

// Web Audio API Synthesizer (Realistic wooden clack, ink stamp thud, temple chime, cat purr)
class TactileAudioEngine {
  constructor() {
    this.enabled = true;
    this.ctx = null;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  // Wooden clack / Hyoshigi (拍子木) tactile click
  playWoodClick() {
    if (!this.enabled) return;
    this.init();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(1200, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(150, this.ctx.currentTime + 0.035);

    gain.gain.setValueAtTime(0.25, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.035);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.035);
  }

  // Deep red ink stamp thud (印鑑・押印音)
  playStampThud() {
    if (!this.enabled) return;
    this.init();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(180, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(45, this.ctx.currentTime + 0.09);

    gain.gain.setValueAtTime(0.4, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.09);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.09);
  }

  // Japanese Temple Chime / Suikinkutsu (水琴窟・風鈴)
  playChime() {
    if (!this.enabled) return;
    this.init();
    const freqs = [587.33, 739.99, 880.00, 1174.66]; // D - F# - A - D Pentatonic
    freqs.forEach((f, i) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(f, this.ctx.currentTime + i * 0.07);

      gain.gain.setValueAtTime(0.18, this.ctx.currentTime + i * 0.07);
      gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + i * 0.07 + 0.4);

      osc.connect(gain);
      gain.connect(this.ctx.destination);

      osc.start(this.ctx.currentTime + i * 0.07);
      osc.stop(this.ctx.currentTime + i * 0.07 + 0.4);
    });
  }

  // Cat Purr sound
  playCatPurr() {
    if (!this.enabled) return;
    this.init();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(75, this.ctx.currentTime);
    osc.frequency.linearRampToValueAtTime(115, this.ctx.currentTime + 0.12);
    osc.frequency.linearRampToValueAtTime(70, this.ctx.currentTime + 0.28);

    gain.gain.setValueAtTime(0.18, this.ctx.currentTime);
    gain.gain.linearRampToValueAtTime(0.01, this.ctx.currentTime + 0.28);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.28);
  }
}

const audio = new TactileAudioEngine();

// ==========================================================================
// Washi Slide-Down Notification Engine
// ==========================================================================
function showJapaneseNotification(title, messageJa, emoji = '⛩️') {
  audio.playChime();
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'app-toast';
  toast.innerHTML = `
    <div class="toast-icon">${emoji}</div>
    <div class="toast-body">
      <strong>${title}</strong>
      <span>${messageJa}</span>
    </div>
  `;
  container.appendChild(toast);

  requestAnimationFrame(() => {
    toast.classList.add('show');
  });

  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 400);
  }, 3400);
}

// ==========================================================================
// Screen Tab Navigation
// ==========================================================================
function switchTab(screenId) {
  audio.playWoodClick();
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));

  const targetScreen = document.getElementById(screenId);
  if (targetScreen) targetScreen.classList.add('active');

  const activeTab = document.querySelector(`.nav-tab[data-tab="${screenId}"]`);
  if (activeTab) activeTab.classList.add('active');

  const container = document.querySelector('.screens-container');
  if (container) container.scrollTop = 0;
}

// ==========================================================================
// Muchi Neko Interactive Mascot
// ==========================================================================
const muchiQuotes = [
  "Nya~ 今日も無事にお過ごしください (Take care today!)",
  "もちもち〜 夕方のマグネシウム錠剤をお忘れなく! 💊",
  "山手線は本日も時間通り運行中にゃ〜 🚇",
  "ゴロゴロ... 6.8kgの純粋な東京のぬくもりにゃ ✨",
  "大吉! 今日はとても縁起の良い一日になりそうにゃ ⛩️",
  "電車内ではマナーモードの設定を忘れずににゃ 📵"
];

function initMuchiCat() {
  const cat = document.getElementById('muchi-cat');
  const catSky = document.querySelector('.cat-scene-artisan');
  const catQuote = document.getElementById('cat-quote');

  function jump() {
    audio.playCatPurr();
    if (cat) cat.classList.add('jump');
    if (catQuote) {
      const q = muchiQuotes[Math.floor(Math.random() * muchiQuotes.length)];
      catQuote.textContent = q;
    }
    setTimeout(() => {
      if (cat) cat.classList.remove('jump');
    }, 280);
  }

  if (cat) cat.addEventListener('click', jump);
  if (catSky) catSky.addEventListener('click', (e) => {
    if (e.target !== cat && !cat.contains(e.target)) jump();
  });
}

// ==========================================================================
// Interactive Yakutai (薬袋) Medicine Envelope
// ==========================================================================
function initYakutaiMedication() {
  const stampBtn = document.getElementById('stamp-pill-btn');
  const eveningSlot = document.getElementById('evening-slot');
  const eveningTarget = document.getElementById('evening-hanko-target');
  const summaryCount = document.getElementById('pill-summary-count');
  const stampBtnLabel = document.getElementById('stamp-btn-label');

  if (stampBtn) {
    stampBtn.addEventListener('click', () => {
      audio.playStampThud();

      // Stamp the vermilion Hanko seal into the slot
      if (eveningTarget) {
        eveningTarget.innerHTML = `<span class="hanko-stamp-text">済</span>`;
      }
      if (eveningSlot) {
        eveningSlot.classList.remove('active-slot');
        eveningSlot.classList.add('done');
      }
      if (summaryCount) {
        summaryCount.textContent = '全服用済 ✓';
        summaryCount.classList.remove('highlight');
        summaryCount.style.color = '#3D5A35'; // matcha green
      }
      if (stampBtnLabel) {
        stampBtnLabel.textContent = '本日服用完了 (All Doses Taken ✓)';
      }
      stampBtn.disabled = true;
      stampBtn.style.opacity = '0.7';
      stampBtn.style.cursor = 'default';

      // Slide-down celebration toast
      showJapaneseNotification(
        '【調剤記録】夕食後薬 押印完了',
        '服用済（マグネシウム・亜鉛）— お疲れ様でした！',
        '💊'
      );
    });
  }
}

// Drugstore Locator
function locatePharmacy(chainName) {
  audio.playWoodClick();
  showJapaneseNotification(
    `最寄りの${chainName}を探索`,
    '徒歩圏内の店舗（免税・調剤対応）へ案内します',
    '📍'
  );
  setTimeout(() => {
    switchTab('screen-map');
    // Align compass to pharmacy
    const needle = document.getElementById('compass-needle');
    if (needle) needle.style.transform = 'translate(-50%, -50%) rotate(72deg)';
  }, 700);
}

// ==========================================================================
// Omikuji Fortune Draw
// ==========================================================================
function initOmikuji() {
  const btn = document.getElementById('omikuji-btn');
  const fortunes = [
    { title: '【大吉】 運気最高潮', desc: '相棒の加護あり。東京での手続きや道中すべて順調に進みます。' },
    { title: '【中吉】 平穏無事', desc: '穏やかな良き日。新宿・渋谷の散策に適しています。' },
    { title: '【吉】 健康第一', desc: 'お薬とビタミンをしっかり摂り、水分補給を怠りなく。' }
  ];

  if (btn) {
    btn.addEventListener('click', () => {
      const f = fortunes[Math.floor(Math.random() * fortunes.length)];
      showJapaneseNotification(f.title, f.desc, '⛩️');
    });
  }
}

// ==========================================================================
// Interactive Train Ticket (硬券 - Kōken)
// ==========================================================================
function initTicketInteractions() {
  const ticket = document.getElementById('koken-ticket');
  if (ticket) {
    ticket.addEventListener('click', () => {
      audio.playWoodClick();
      showJapaneseNotification(
        'JR山手線 硬券乗車票',
        '渋谷駅 ➔ 新宿駅（平常運転・遅延なし）',
        '🎫'
      );
    });
  }
}

// ==========================================================================
// AI Assistant Chat & Voice
// ==========================================================================
function initChatEngine() {
  const sendBtn = document.getElementById('send-btn');
  const input = document.getElementById('chat-input');
  const log = document.getElementById('chat-log');
  const voiceBtn = document.getElementById('voice-btn');

  function send() {
    const text = input.value.trim();
    if (!text) return;
    audio.playWoodClick();

    // User Message
    const userRow = document.createElement('div');
    userRow.className = 'chat-row user';
    userRow.innerHTML = `
      <div class="scroll-bubble user">
        ${escapeHtml(text)}
        <div class="scroll-time">Just now</div>
      </div>
    `;
    log.appendChild(userRow);
    input.value = '';
    log.scrollTop = log.scrollHeight;

    // AIBO Response
    setTimeout(() => {
      audio.playChime();
      const aiboRow = document.createElement('div');
      aiboRow.className = 'chat-row aibo';
      aiboRow.innerHTML = `
        <div class="hanko-seal mini">相棒</div>
        <div class="scroll-bubble">
          承知いたしました（はい）。ご相談内容を確認しました。ローカル暗号化データベース（AES-256）を参照し、安全にお手伝いいたします。
          <div class="scroll-time">Just now • 筆談済</div>
        </div>
      `;
      log.appendChild(aiboRow);
      log.scrollTop = log.scrollHeight;
    }, 600);
  }

  if (sendBtn) sendBtn.addEventListener('click', send);
  if (input) {
    input.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') send();
    });
  }

  if (voiceBtn) {
    voiceBtn.addEventListener('click', () => {
      audio.playChime();
      showJapaneseNotification(
        'バイリンガル音声認識 開始',
        '日本語・English 音声入力を待機中 (Offline STT)',
        '🎙️'
      );
    });
  }
}

function escapeHtml(s) {
  const d = document.createElement('div');
  d.textContent = s;
  return d.innerHTML;
}

// ==========================================================================
// System Controls (Frame, Sound, Clock)
// ==========================================================================
function initControls() {
  // Live Clock
  const clock = document.getElementById('status-clock');
  function tick() {
    const d = new Date();
    const hh = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    if (clock) clock.textContent = `${hh}:${mm}`;
  }
  setInterval(tick, 1000);
  tick();

  // Frame Toggle
  const frameBtn = document.getElementById('toggle-frame-btn');
  const frame = document.getElementById('phone-frame');
  if (frameBtn && frame) {
    frameBtn.addEventListener('click', () => {
      audio.playWoodClick();
      const isFull = frame.classList.toggle('fullview');
      frameBtn.innerHTML = isFull
        ? '<span class="icon">📱</span> 枠: 携帯電話'
        : '<span class="icon">🖥️</span> 枠: 全画面';
    });
  }

  // Sound Toggle
  const soundBtn = document.getElementById('toggle-sound-btn');
  if (soundBtn) {
    soundBtn.addEventListener('click', () => {
      audio.enabled = !audio.enabled;
      audio.playWoodClick();
      soundBtn.innerHTML = audio.enabled
        ? '<span class="icon">🔔</span> 音声: ON'
        : '<span class="icon">🔇</span> 音声: OFF';
    });
  }
}

// ==========================================================================
// DOM Ready
// ==========================================================================
document.addEventListener('DOMContentLoaded', () => {
  initMuchiCat();
  initYakutaiMedication();
  initOmikuji();
  initTicketInteractions();
  initChatEngine();
  initControls();

  // Welcome Slide-down Toast
  setTimeout(() => {
    showJapaneseNotification(
      'ようこそ 相棒（AIBO）へ',
      '和文具・調剤薬袋・東京通勤案内 起動完了',
      '⛩️'
    );
  }, 500);
});
