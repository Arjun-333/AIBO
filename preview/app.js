// ==========================================================================
// AIBO (相棒) - Japanese Stationery & Tactile Engine
// English-Primary Edition with Japanese Accents & Vector SVGs
// ==========================================================================

// Web Audio API Synthesizer (Realistic wooden clack, ink stamp thud, temple chime, cat purr)
class TactileAudioEngine {
  constructor() {
    // Sound is opt-in so the preview never surprises users in public or at work.
    this.enabled = false;
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

  // Wooden clack / Hyoshigi tactile click
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

  // Deep red ink stamp thud (押印音)
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

  // Japanese Temple Chime
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
// Slide-Down Notification Engine with Custom Vector SVGs
// ==========================================================================
function showJapaneseNotification(title, subtitle, iconId = 'icon-torii') {
  audio.playChime();
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'app-toast';
  toast.innerHTML = `
    <div class="toast-icon">
      <svg width="20" height="20" stroke="var(--shu-vermilion)"><use href="#${iconId}" /></svg>
    </div>
    <div class="toast-body">
      <strong>${title}</strong>
      <span>${subtitle}</span>
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
  '"Nya~ Gambatte kudasai! (Have a great day in Tokyo!)"',
  '"Mochi-mochi! Don\'t forget your evening tablet! (お薬)"',
  '"The JR Yamanote Line is running on time today~"',
  '"Purrr... 6.8 kg of pure Shibuya rooftop fluff!"',
  '"Daikichi (大吉)! Great blessing awaits you today!"',
  '"Tip: Remember to keep your phone on Manner Mode on the subway!"'
];

function triggerMuchiJump() {
  audio.playCatPurr();
  const cat = document.getElementById('muchi-cat');
  const catQuote = document.getElementById('cat-quote');
  if (cat) cat.classList.add('jump');
  if (catQuote) {
    const q = muchiQuotes[Math.floor(Math.random() * muchiQuotes.length)];
    catQuote.textContent = q;
  }
  setTimeout(() => {
    if (cat) cat.classList.remove('jump');
  }, 280);
}
window.triggerMuchiJump = triggerMuchiJump;

function initMuchiCat() {
  // The scene wrapper owns the interaction so a tap on the cat is not fired twice.
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
        eveningTarget.innerHTML = `<span class="hanko-stamp-text">✓ 済</span>`;
      }
      if (eveningSlot) {
        eveningSlot.classList.remove('active-slot');
        eveningSlot.classList.add('done');
      }
      if (summaryCount) {
        summaryCount.textContent = 'All Taken ✓';
        summaryCount.classList.remove('highlight');
        summaryCount.style.color = '#3D5A35'; // matcha green
      }
      if (stampBtnLabel) {
        stampBtnLabel.textContent = 'Completed for Today (済)';
      }
      stampBtn.disabled = true;
      stampBtn.style.opacity = '0.7';
      stampBtn.style.cursor = 'default';

      // Slide-down celebration toast
      showJapaneseNotification(
        'Dose Logged: Magnesium & Zinc',
        '服用完了 (Fukuyou Kanryou) — Great job taking care of your health!',
        'icon-pill'
      );
    });
  }
}

// Drugstore Locator
function locatePharmacy(chainName) {
  audio.playWoodClick();
  showJapaneseNotification(
    `Locating Nearest ${chainName}`,
    '最寄り店舗を検索中 (Directing to Radar Compass)',
    'icon-pin'
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
    { title: 'Daikichi (大吉) • Great Fortune', desc: 'Blessed journey today! All Tokyo travels and tasks will go smoothly.' },
    { title: 'Chukichi (中吉) • Moderate Blessing', desc: 'A peaceful, pleasant day. Great time to explore Harajuku or Shinjuku.' },
    { title: 'Shokichi (小吉) • Small Fortune', desc: 'Health first! Stay hydrated and take your daily vitamins on schedule.' }
  ];

  if (btn) {
    btn.addEventListener('click', () => {
      const f = fortunes[Math.floor(Math.random() * fortunes.length)];
      showJapaneseNotification(f.title, f.desc, 'icon-torii');
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
        'JR Yamanote Line Ticket (山手線)',
        'Shibuya ➔ Shinjuku • Normal service on all lines',
        'icon-train'
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
          Understood! (Hai - はい). I can help you plan your day in Japan. This is a demo response; your personal data remains on-device in the real app.
          <div class="scroll-time">Just now • Demo response</div>
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
        'Bilingual Voice Recognition Active',
        'Listening in English & 日本語 (Offline STT)',
        'icon-mic'
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
  const frameText = document.getElementById('frame-btn-text');
  const frame = document.getElementById('phone-frame');
  if (frameBtn && frame) {
    frameBtn.addEventListener('click', () => {
      audio.playWoodClick();
      const isFull = frame.classList.toggle('fullview');
      if (frameText) {
        frameText.textContent = isFull ? 'View: Full Width' : 'View: Phone Frame';
      }
    });
  }

  // Sound Toggle
  const soundBtn = document.getElementById('toggle-sound-btn');
  const soundText = document.getElementById('sound-btn-text');
  if (soundBtn) {
    soundBtn.addEventListener('click', () => {
      audio.enabled = !audio.enabled;
      audio.playWoodClick();
      if (soundText) {
        soundText.textContent = audio.enabled ? 'Audio: ON' : 'Audio: OFF';
      }
    });
  }
}

// Give card-like preview controls keyboard access as well as pointer access.
function initKeyboardInteractions() {
  const selectors = '.cat-scene-wrapper, .metric-pill-item, .toolbelt-card, .pharmacy-ticket, .koken-ticket';
  document.querySelectorAll(selectors).forEach((element) => {
    element.setAttribute('role', 'button');
    element.setAttribute('tabindex', '0');
    element.addEventListener('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        element.click();
      }
    });
  });
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
  initKeyboardInteractions();

  // Welcome Slide-down Toast
  setTimeout(() => {
    showJapaneseNotification(
      'Welcome to AIBO (ようこそ 相棒へ)',
      'Your English & Japanese daily companion is ready',
      'icon-torii'
    );
  }, 500);
});

// Daily Phrase Pronunciation & Audio Trigger
function playDailyPhraseSound() {
  audio.playChime();
  showJapaneseNotification(
    'Konbini Phrase: "Fukuro wa daijōbu desu"',
    'Say this when the cashier asks "Fukuro wa go-riyou desu ka?"',
    'icon-sound'
  );
}
