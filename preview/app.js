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
// Muchi Neko Interactive Mascot (Compact & Purposeful States)
// ==========================================================================
const muchiStateQuotes = {
  greeting: '"Okaeri, Arjun-san! Evening Magnesium dose scheduled at 8:30 PM."',
  idle: '"Shibuya weather is 18°C. Yamanote line running on standard schedule."',
  celebrate: '"Evening dose logged with Hanko seal! Great job keeping on track! ✨"',
  rest: '"Curled up for a peaceful nap on the roof tiles... Zzz 🌙"'
};

let currentMuchiState = 'greeting';

function setMuchiState(state) {
  audio.playWoodClick();
  currentMuchiState = state;
  const catQuote = document.getElementById('cat-quote');
  if (catQuote && muchiStateQuotes[state]) {
    catQuote.textContent = muchiStateQuotes[state];
  }
  document.querySelectorAll('.state-chip').forEach(c => c.classList.remove('active'));
  const activeChip = document.getElementById(`chip-${state}`);
  if (activeChip) activeChip.classList.add('active');

  const cat = document.getElementById('muchi-cat');
  if (cat) {
    cat.classList.add('jump');
    setTimeout(() => cat.classList.remove('jump'), 280);
  }
}
window.setMuchiState = setMuchiState;

function toggleMuchiCompact() {
  audio.playWoodClick();
  const banner = document.getElementById('companion-banner');
  const toggleText = document.getElementById('compact-toggle-text');
  if (banner) {
    const isCompact = banner.classList.toggle('compact-mode');
    if (toggleText) {
      toggleText.textContent = isCompact ? '+ Expand' : '— Compact';
    }
  }
}
window.toggleMuchiCompact = toggleMuchiCompact;

function triggerMuchiJump() {
  audio.playCatPurr();
  const cat = document.getElementById('muchi-cat');
  if (cat) cat.classList.add('jump');
  setTimeout(() => {
    if (cat) cat.classList.remove('jump');
  }, 280);
}
window.triggerMuchiJump = triggerMuchiJump;

function initMuchiCat() {
  // Rotate idle hints gently every 12 seconds if not resting
  setInterval(() => {
    if (currentMuchiState === 'idle') {
      const hints = [
        '"Shibuya weather is 18°C. Yamanote line running on standard schedule."',
        '"Remember to keep your phone on Manner Mode inside train cars."',
        '"7-Bank ATMs near Shibuya Station support international debit cards."'
      ];
      const q = hints[Math.floor(Math.random() * hints.length)];
      const catQuote = document.getElementById('cat-quote');
      if (catQuote) catQuote.textContent = q;
    }
  }, 12000);
}

// ==========================================================================
// Interactive Yakutai (薬袋) Medicine Envelope & Quick Stamp
// ==========================================================================
let isMedicationLogged = false;

function quickStampMedication() {
  if (isMedicationLogged) return;
  audio.playStampThud();
  isMedicationLogged = true;

  // Update Home Card
  const homeBtn = document.getElementById('home-quick-stamp-btn');
  const homeLabel = document.getElementById('home-stamp-label');
  const homeTime = document.getElementById('home-med-time');
  const routineTag = document.getElementById('routine-status-tag');

  if (homeBtn) {
    homeBtn.disabled = true;
    homeBtn.style.background = '#2E7D32';
  }
  if (homeLabel) homeLabel.textContent = 'Logged ✓ (済)';
  if (homeTime) {
    homeTime.textContent = 'Completed Just Now ✓';
    homeTime.style.color = '#2E7D32';
  }
  if (routineTag) {
    routineTag.textContent = 'Daily Routine: 3/3 Done (100%)';
    routineTag.style.background = '#E8F5E9';
    routineTag.style.color = '#2E7D32';
  }

  // Update Tablets Yakutai Screen
  const stampBtn = document.getElementById('stamp-pill-btn');
  const eveningSlot = document.getElementById('evening-slot');
  const eveningTarget = document.getElementById('evening-hanko-target');
  const stampBtnLabel = document.getElementById('stamp-btn-label');

  if (eveningTarget) {
    eveningTarget.innerHTML = `<span class="hanko-stamp-text">✓ 済</span>`;
  }
  if (eveningSlot) {
    eveningSlot.classList.remove('active-slot');
    eveningSlot.classList.add('done');
  }
  if (stampBtnLabel) {
    stampBtnLabel.textContent = 'Completed for Today (済)';
  }
  if (stampBtn) {
    stampBtn.disabled = true;
    stampBtn.style.opacity = '0.7';
  }

  // Set mascot to celebratory state
  setMuchiState('celebrate');

  // Slide-down celebration toast
  showJapaneseNotification(
    'Dose Logged: Magnesium & Zinc',
    '服用完了 (Fukuyou Kanryou) — Personal log recorded on device',
    'icon-pill'
  );
}
window.quickStampMedication = quickStampMedication;

function initYakutaiMedication() {
  const stampBtn = document.getElementById('stamp-pill-btn');
  if (stampBtn) {
    stampBtn.addEventListener('click', quickStampMedication);
  }
}

// ==========================================================================
// Daily Focus Tasks Interactivity
// ==========================================================================
function toggleTask(taskId) {
  audio.playWoodClick();
  const box = document.getElementById(`${taskId}-box`);
  const title = document.getElementById(`${taskId}-title`);
  const row = box ? box.closest('.task-item-row') : null;

  if (box && title && row) {
    const isDone = row.classList.toggle('done');
    box.classList.toggle('checked', isDone);
    title.classList.toggle('completed', isDone);
    updateTaskProgress();
  }
}
window.toggleTask = toggleTask;

function updateTaskProgress() {
  const total = document.querySelectorAll('.task-item-row').length;
  const done = document.querySelectorAll('.task-item-row.done').length;
  const badge = document.getElementById('task-progress-badge');
  if (badge) {
    badge.textContent = `${done} of ${total} Done`;
  }
}

// ==========================================================================
// Modal Controllers (Offline Truth, Profile Customizer, Expense Log)
// ==========================================================================
function openModal(modalId) {
  audio.playWoodClick();
  const m = document.getElementById(modalId);
  if (m) m.classList.add('open');
}
window.openModal = openModal;

function closeModal(modalId) {
  audio.playWoodClick();
  const m = document.getElementById(modalId);
  if (m) m.classList.remove('open');
}
window.closeModal = closeModal;

function openOfflineModal() {
  openModal('offline-modal');
}
window.openOfflineModal = openOfflineModal;

function openProfileModal() {
  openModal('profile-modal');
}
window.openProfileModal = openProfileModal;

function openExpenseModal() {
  openModal('expense-modal');
}
window.openExpenseModal = openExpenseModal;
window.openExpensePrompt = openExpenseModal;

// Profile Preferences Save
function saveProfilePreferences() {
  audio.playChime();
  const nameInput = document.getElementById('cfg-name-input');
  const honorificSelect = document.getElementById('cfg-honorific-select');
  const styleSelect = document.getElementById('cfg-style-select');
  const citySelect = document.getElementById('cfg-city-select');

  const name = nameInput ? nameInput.value.trim() || 'Arjun' : 'Arjun';
  const honorific = honorificSelect ? honorificSelect.value : '-san';
  const style = styleSelect ? styleSelect.value : 'bilingual';
  const city = citySelect ? citySelect.value : 'Shibuya, Tokyo';

  // Update Greeting Display
  const nameDisplay = document.getElementById('greeting-name-display');
  if (nameDisplay) {
    nameDisplay.textContent = `${name}${honorific}`;
  }

  // Update Weather Subtitle with real local date
  const now = new Date();
  const dateStr = now.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  const cityWeather = document.getElementById('greeting-city-weather');
  if (cityWeather) {
    cityWeather.textContent = `${city} • 18°C ☀️ • ${dateStr}`;
  }

  closeModal('profile-modal');
  showJapaneseNotification(
    'Profile Updated (設定完了)',
    `Greeting set for ${name}${honorific} in ${city}`,
    'icon-torii'
  );
}
window.saveProfilePreferences = saveProfilePreferences;

// Expense Logger
let totalDailySpent = 3250;
const dailyBudgetCap = 8000;

function submitNewExpense() {
  const amtInput = document.getElementById('exp-amount-input');
  const catSelect = document.getElementById('exp-category-select');
  const noteInput = document.getElementById('exp-note-input');

  const amt = parseInt(amtInput ? amtInput.value : '0', 10);
  if (isNaN(amt) || amt <= 0) {
    alert('Please enter a valid Yen amount (¥)');
    return;
  }

  audio.playStampThud();
  totalDailySpent += amt;
  const remaining = Math.max(0, dailyBudgetCap - totalDailySpent);
  const percentage = Math.min(100, (totalDailySpent / dailyBudgetCap) * 100);

  // Update Home Card Display
  const spentDisplay = document.getElementById('home-spent-display');
  const budgetBar = document.getElementById('home-budget-bar');
  if (spentDisplay) spentDisplay.textContent = `¥${totalDailySpent.toLocaleString()}`;
  if (budgetBar) budgetBar.style.width = `${percentage}%`;

  // Reset & Close
  if (amtInput) amtInput.value = '';
  if (noteInput) noteInput.value = '';
  closeModal('expense-modal');

  showJapaneseNotification(
    `Logged: ¥${amt.toLocaleString()}`,
    `Daily Remaining: ¥${remaining.toLocaleString()} of ¥${dailyBudgetCap.toLocaleString()}`,
    'icon-yen'
  );
}
window.submitNewExpense = submitNewExpense;

// Emergency 110 / 119 Simulator
function triggerEmergencyCall(number) {
  audio.playChime();
  const desc = number === '110' ? 'Japan Police (警察)' : 'Ambulance & Fire (救急・消防)';
  showJapaneseNotification(
    `Emergency Call: ${number}`,
    `Dialing ${desc} • English operator assistance supported`,
    'icon-alert'
  );
}
window.triggerEmergencyCall = triggerEmergencyCall;

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
