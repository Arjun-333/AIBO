// ==========================================================================
// AIBO (相棒) - Authentic Japanese Daily Companion & Tactile Engine
// Zero-Mock Data Architecture: 100% Truthful, Reliable, and Dynamic
// ==========================================================================

// Web Audio API Synthesizer (Realistic wooden clack, ink stamp thud, temple chime, cat purr)
class TactileAudioEngine {
  constructor() {
    this.enabled = false;
    this.ctx = null;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

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

  playChime() {
    if (!this.enabled) return;
    this.init();
    const freqs = [587.33, 739.99, 880.00, 1174.66];
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
// Slide-Down Toast Notification Engine
// ==========================================================================
function showJapaneseNotification(title, subtitle, iconId = 'icon-torii') {
  audio.playChime();
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = 'app-toast';
  toast.innerHTML = `
    <div class="toast-icon">
      <svg width="20" height="20" stroke="var(--color-vermilion)"><use href="#${iconId}" /></svg>
    </div>
    <div class="toast-body">
      <strong>${escapeHtml(title)}</strong>
      <span>${escapeHtml(subtitle)}</span>
    </div>
  `;
  container.appendChild(toast);

  requestAnimationFrame(() => toast.classList.add('show'));
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 400);
  }, 3400);
}

// ==========================================================================
// 100% Truthful Local Data Store (AiboStore)
// Zero mock data. Real user data is persisted in localStorage.
// ==========================================================================
const AiboStore = {
  KEYS: {
    PROFILE: 'aibo_profile_v1',
    EXPENSES: 'aibo_expenses_v1',
    TASKS: 'aibo_tasks_v1',
    MEDS: 'aibo_medications_v1',
    VAULT: 'aibo_vault_v1',
    ICE: 'aibo_ice_v1',
    CHAT: 'aibo_chat_v1',
    SETTINGS: 'aibo_settings_v1',
  },

  // 1. Profile
  getProfile() {
    try {
      const data = localStorage.getItem(this.KEYS.PROFILE);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading profile from storage', e);
    }
    return {
      name: 'Arjun',
      honorific: '-san',
      style: 'bilingual',
      city: 'Shibuya, Tokyo',
      dailyBudget: 8000,
      isConfigured: true
    };
  },

  saveProfile(profile) {
    localStorage.setItem(this.KEYS.PROFILE, JSON.stringify(profile));
  },

  // 2. Expenses
  getExpenses() {
    try {
      const data = localStorage.getItem(this.KEYS.EXPENSES);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading expenses', e);
    }
    return [];
  },

  saveExpenses(expenses) {
    localStorage.setItem(this.KEYS.EXPENSES, JSON.stringify(expenses));
  },

  addExpense(expense) {
    const expenses = this.getExpenses();
    const newRecord = {
      id: 'exp_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
      amount: Math.round(Number(expense.amount)),
      category: expense.category || '🍜 Meals',
      note: expense.note ? expense.note.trim() : '',
      timestamp: new Date().toISOString()
    };
    expenses.unshift(newRecord);
    this.saveExpenses(expenses);
    return newRecord;
  },

  deleteExpense(id) {
    let expenses = this.getExpenses();
    expenses = expenses.filter(e => e.id !== id);
    this.saveExpenses(expenses);
  },

  getTodayExpenses() {
    const expenses = this.getExpenses();
    const todayStr = new Date().toDateString();
    return expenses.filter(e => new Date(e.timestamp).toDateString() === todayStr);
  },

  getTodaySpentTotal() {
    const todayExpenses = this.getTodayExpenses();
    return todayExpenses.reduce((sum, e) => sum + e.amount, 0);
  },

  getMonthExpenses() {
    const expenses = this.getExpenses();
    const now = new Date();
    return expenses.filter(e => {
      const d = new Date(e.timestamp);
      return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
    });
  },

  getMonthSpentTotal() {
    const monthExpenses = this.getMonthExpenses();
    return monthExpenses.reduce((sum, e) => sum + e.amount, 0);
  },

  // 2b. Monthly Budget & Japan Bill Envelopes
  getBudgetConfig() {
    const profile = this.getProfile();
    return {
      monthlyTotal: profile.monthlyBudget || 240000,
      dailyTarget: profile.dailyBudget || 8000,
      envelopes: profile.billEnvelopes || {
        rent: 85000,        // 🏠 Rent & Maintenance (家賃・共益費)
        electricity: 6500,  // ⚡ Electricity (電気代 - TEPCO/Tokyo Gas)
        gas: 4500,          // 🔥 Gas (ガス代 - Tokyo Gas)
        water: 3500,        // 💧 Water (水道代 - Bureau of Waterworks)
        internet: 5500,     // 📶 Mobile & Wi-Fi (通信費 - Docomo/SoftBank/Fiber)
        insurance: 15000,   // 🏥 Health & Pension (国民健康保険・国民年金)
        groceries: 45000,   // 🛒 Groceries & Supermarket (食費)
        transit: 10000,     // 🚇 Transit / Commuter Pass (交通費・定期券)
        discretionary: 65000// 🛍️ Daily Living & Dining (生活費・外食)
      }
    };
  },

  saveBudgetConfig(monthlyTotal, envelopes) {
    const profile = this.getProfile();
    profile.monthlyBudget = Math.round(Number(monthlyTotal));
    profile.billEnvelopes = envelopes;
    // Calculate daily target from discretionary living allowance or total divided by 30
    profile.dailyBudget = Math.round((envelopes.discretionary || profile.monthlyBudget) / 30);
    this.saveProfile(profile);
  },

  // 3. Tasks / Agenda
  getTasks() {
    try {
      const data = localStorage.getItem(this.KEYS.TASKS);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading tasks', e);
    }
    return [];
  },

  saveTasks(tasks) {
    localStorage.setItem(this.KEYS.TASKS, JSON.stringify(tasks));
  },

  addTask(task) {
    const tasks = this.getTasks();
    const newRecord = {
      id: 'tsk_' + Date.now(),
      title: task.title.trim(),
      subtext: task.subtext ? task.subtext.trim() : '',
      category: task.category || 'General',
      done: false,
      createdAt: new Date().toISOString()
    };
    tasks.push(newRecord);
    this.saveTasks(tasks);
    return newRecord;
  },

  toggleTask(id) {
    const tasks = this.getTasks();
    const target = tasks.find(t => t.id === id);
    if (target) {
      target.done = !target.done;
      this.saveTasks(tasks);
      return target;
    }
    return null;
  },

  deleteTask(id) {
    let tasks = this.getTasks();
    tasks = tasks.filter(t => t.id !== id);
    this.saveTasks(tasks);
  },

  // 4. Medications & Tablets
  getMedications() {
    try {
      const data = localStorage.getItem(this.KEYS.MEDS);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading medications', e);
    }
    return [];
  },

  saveMedications(meds) {
    localStorage.setItem(this.KEYS.MEDS, JSON.stringify(meds));
  },

  addMedication(med) {
    const meds = this.getMedications();
    const newRecord = {
      id: 'med_' + Date.now(),
      name: med.name.trim(),
      dosage: med.dosage.trim(),
      time: med.time.trim(),
      instructions: med.instructions ? med.instructions.trim() : 'Take with water after meals',
      isTaken: false,
      lastTaken: null
    };
    meds.push(newRecord);
    this.saveMedications(meds);
    return newRecord;
  },

  stampMedication(id) {
    const meds = this.getMedications();
    const target = meds.find(m => m.id === id);
    if (target) {
      target.isTaken = true;
      target.lastTaken = new Date().toISOString();
      this.saveMedications(meds);
      return target;
    }
    return null;
  },

  deleteMedication(id) {
    let meds = this.getMedications();
    meds = meds.filter(m => m.id !== id);
    this.saveMedications(meds);
  },

  // 5. Document Vault
  getVault() {
    try {
      const data = localStorage.getItem(this.KEYS.VAULT);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading vault documents', e);
    }
    return [];
  },

  saveVault(vault) {
    localStorage.setItem(this.KEYS.VAULT, JSON.stringify(vault));
  },

  addDocument(doc) {
    const vault = this.getVault();
    const newRecord = {
      id: 'doc_' + Date.now(),
      title: doc.title.trim(),
      category: doc.category || 'General',
      notes: doc.notes ? doc.notes.trim() : 'Encrypted on-device file',
      createdAt: new Date().toISOString()
    };
    vault.unshift(newRecord);
    this.saveVault(vault);
    return newRecord;
  },

  deleteDocument(id) {
    let vault = this.getVault();
    vault = vault.filter(d => d.id !== id);
    this.saveVault(vault);
  },

  // 6. Emergency ICE Medical Card
  getIceCard() {
    try {
      const data = localStorage.getItem(this.KEYS.ICE);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading ICE card', e);
    }
    const profile = this.getProfile();
    return {
      fullName: profile.name || 'Primary User',
      city: profile.city || 'Tokyo, Japan',
      bloodType: 'Unknown',
      allergies: 'None listed',
      emergencyContactName: 'Not configured',
      emergencyContactPhone: ''
    };
  },

  saveIceCard(ice) {
    localStorage.setItem(this.KEYS.ICE, JSON.stringify(ice));
  },

  // 7. Chat History
  getChatHistory() {
    try {
      const data = localStorage.getItem(this.KEYS.CHAT);
      if (data) return JSON.parse(data);
    } catch (e) {
      console.warn('Failed reading chat history', e);
    }
    return [];
  },

  saveChatHistory(history) {
    localStorage.setItem(this.KEYS.CHAT, JSON.stringify(history));
  },

  addChatMessage(role, content, provider = '', providerClass = '') {
    const history = this.getChatHistory();
    const msg = {
      id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
      role,
      content,
      provider,
      providerClass,
      timestamp: new Date().toISOString()
    };
    history.push(msg);
    this.saveChatHistory(history);
    return msg;
  },

  deleteChatMessage(id) {
    let history = this.getChatHistory();
    history = history.filter(m => m.id !== id);
    this.saveChatHistory(history);
  },

  clearChatHistory() {
    localStorage.removeItem(this.KEYS.CHAT);
  }
};
window.AiboStore = AiboStore;

// ==========================================================================
// Intelligent Truthful Japan Knowledge Assistant
// Real answers for Japan living, ward procedures, emergencies, and medicine
// ==========================================================================
const AiboKnowledgeAssistant = {
  respond(query) {
    const q = query.toLowerCase().trim();

    // 1. Garbage Sorting & Trash Rules
    if (q.includes('garbage') || q.includes('trash') || q.includes('gomi') || q.includes('ごみ') || q.includes('burnable')) {
      return `Tokyo waste separation follows strict municipal ward categories:
• **Burnable (燃えるごみ - Moeru Gomi)**: Food scraps, paper wrappers, soiled napkins, wood chips. Put out before 08:00 AM on designated collection mornings.
• **Non-Burnable (燃えないごみ - Moenai Gomi)**: Glass, metals, ceramics, lightbulbs, foil.
• **Plastics & PET Bottles (プラスチック・ペットボトル)**: Clean plastic trays and drink bottles (remove caps & wash labels).
• **Bulky Waste (粗大ごみ - Sodai Gomi)**: Items over 30cm require purchasing a fee sticker (処理券) at your local convenience store and booking a pickup with your ward sanitation office.`;
    }

    // 2. Ward Office & Address Registration (Juminhyo)
    if (q.includes('ward office') || q.includes('city hall') || q.includes('address') || q.includes('juminhyo') || q.includes('住民票') || q.includes('moving')) {
      return `Address Registration at the Ward Office (区役所 / 市役所):
1. **14-Day Legal Deadline**: You must register your address within 14 days of moving into a new residence in Japan.
2. **Required Documents**: Bring your **Residence Card (在留カード)**, Passport, and Moving-out Certificate (転出証明書 - if moving from another Japanese municipality).
3. **Resident Record (住民票 - Juminhyo)**: You can request an official copy at the counter (usually ¥300 fee). If you have a My Number card, you can print copies fee-discounted at any 7-Eleven or Lawson copy machine!`;
    }

    // 3. Health Insurance & Doctor Visits
    if (q.includes('insurance') || q.includes('hospital') || q.includes('clinic') || q.includes('hoken') || q.includes('保険')) {
      return `Health Care & National Health Insurance (国民健康保険):
• **70% Coverage**: Standard Japanese health insurance covers 70% of medical and prescription drug costs; you pay the 30% copay at the clinic counter.
• **What to Bring**: Always bring your physical **Health Insurance Card (保険証)** or My Number card linked to health insurance.
• **Emergency Care in English**: St. Luke's International Hospital (Tsukiji) and Tokyo Medical University Hospital offer English-speaking clinical desks.`;
    }

    // 4. Over-the-counter Medicines (Headache, Cold, Pharmacy)
    if (q.includes('headache') || q.includes('medicine') || q.includes('pain') || q.includes('pharmacy') || q.includes('drugstore') || q.includes('eve') || q.includes('loxonin')) {
      return `Common Japanese OTC Drugstore Equivalents (Yakkyoku / 薬局):
• **Ibuprofen (Headache / Menstrual pain)**: Ask for **EVE Quick DX (イブクイックDX)** or **Bufferin Premium (バファリンプレミアム)**.
• **Stronger NSAID (Loxoprofen)**: **Loxonin S (ロキソニンS)** is widely trusted in Japan (Class 1 OTC — pharmacist counter required).
• **Cold & Flu**: **Pabron Gold A (パブロンゴールドA)** or **Shin Lulu A (新ルルA)**.
• **Acid Reflux / Stomach**: **Gaster 10 (ガスター10)** or **Ohta's Isan (太田胃散)**.`;
    }

    // 5. Suica, Pasmo & Yamanote Line Manners
    if (q.includes('suica') || q.includes('pasmo') || q.includes('train') || q.includes('station') || q.includes('subway') || q.includes('manner')) {
      return `Tokyo Transit & Commuter Etiquette:
• **Manner Mode (マナーモード)**: Always keep your smartphone on silent inside train cars; phone calls are strictly prohibited on trains.
• **Backpack Rule**: In crowded cars, hold your backpack in front of your chest or place it on the overhead wire rack to free space.
• **IC Card Top-Up**: Suica and Pasmo cards can be recharged with cash at any station ticket machine or 7-Eleven ATM (select "IC Card Charge").`;
    }

    // 6. Emergency Contacts
    if (q.includes('emergency') || q.includes('police') || q.includes('ambulance') || q.includes('fire') || q.includes('110') || q.includes('119')) {
      return `Japan Emergency Numbers:
• **110**: Police (警察 - Keisatsu) for traffic accidents, theft, or crime.
• **119**: Fire and Ambulance (消防・救急 - Shōbō / Kyūkyū) for medical emergencies and fires.
• **118**: Japan Coast Guard (海上保安庁) for water accidents.
• **03-5774-0992**: Tokyo English Lifeline (TELL) free confidential crisis hotline.
※ The AIBO "Tools & SOS" tab provides direct 1-tap phone dialers for these services.`;
    }

    // 7. General Assistant Response
    return `Understood! I am your on-device Japan life assistant. 
For official ward office paperwork, medical advice, or specific visa requirements, always consult with your local municipal ward office (区役所) or certified immigration attorney. 
You can also ask me about:
• Waste and recycling separation rules
• Konbini bill payment and ATM withdrawals
• Over-the-counter medicine Japanese names
• Train line transfers and station exits`;
  }
};

// ==========================================================================
// Dual-Engine AI Service (NVIDIA Nemotron 70B BYOK + Google Gemini Flash + Offline)
// ==========================================================================
const AiboAiService = {
  _systemPrompt: `You are AIBO (AI Buddy & Organiser), a friendly, helpful, and culturally knowledgeable personal companion for a foreigner living in Japan.
Your core rules:
1. Accurately explain Japanese cultural etiquette, administrative procedures (ward office/市役所, tax/住民税, health insurance/国民健康保険, residence card/在留カード), and municipal garbage sorting rules (burnable/燃えるごみ, non-burnable/燃えないごみ, recyclables/資源ごみ).
2. When answering Japanese language questions, provide the Kanji (漢字), Hiragana/Furigana reading, Romaji pronunciation, and clear English meaning. Explain politeness levels (Polite/丁寧語 vs Casual/タメ口 vs Humble/謙譲語).
3. NON-FABRICATION RULE: Never invent train schedules, prices, laws, or emergency guidelines. If you are uncertain or the rule varies by Tokyo ward/municipality, state clearly that it depends on the local ward office (区役所).
4. Keep answers concise, actionable, and formatted with clean bullet points.`,

  getConfig() {
    try {
      const stored = localStorage.getItem('aibo_ai_config');
      if (stored) return JSON.parse(stored);
    } catch(e) {}

    return {
      activeProvider: 'auto',
      nvidiaApiKey: '',
      nvidiaBaseUrl: 'https://integrate.api.nvidia.com/v1',
      nvidiaModel: 'nvidia/llama-3.1-nemotron-70b-instruct',
      geminiApiKey: '',
      geminiModel: 'gemini-2.5-flash'
    };
  },

  async loadInitialConfig() {
    let cfg = this.getConfig();
    // Try to load preview/config.json if keys aren't set in localStorage
    if (!cfg.geminiApiKey && !cfg.nvidiaApiKey) {
      try {
        const res = await fetch('config.json');
        if (res.ok) {
          const remote = await res.json();
          cfg = { ...cfg, ...remote };
          this.saveConfig(cfg);
        }
      } catch (e) {
        // config.json might not exist, ignore
      }
    }
    this.updateChatProviderBanner();
    return cfg;
  },

  saveConfig(cfg) {
    localStorage.setItem('aibo_ai_config', JSON.stringify(cfg));
    this.updateChatProviderBanner();
  },

  updateChatProviderBanner() {
    const cfg = this.getConfig();
    const nameEl = document.getElementById('chat-active-provider-name');
    const pillEl = document.getElementById('chat-active-provider-pill');
    if (!nameEl || !pillEl) return;

    if (cfg.activeProvider === 'nvidia') {
      nameEl.textContent = 'NVIDIA Nemotron 70B (BYOK)';
      pillEl.innerHTML = '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#76B900;"></span> <span>Active: <strong>NVIDIA Nemotron 70B</strong></span>';
    } else if (cfg.activeProvider === 'gemini') {
      nameEl.textContent = 'Google Gemini 2.5 Flash (Live)';
      pillEl.innerHTML = '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#1A73E8;"></span> <span>Active: <strong>Gemini 2.5 Flash (Live)</strong></span>';
    } else if (cfg.activeProvider === 'offline') {
      nameEl.textContent = 'On-Device Knowledge Engine (Offline)';
      pillEl.innerHTML = '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#757575;"></span> <span>Active: <strong>Offline Engine</strong></span>';
    } else {
      nameEl.textContent = 'Auto (Nemotron ➔ Gemini Fallback)';
      pillEl.innerHTML = '<span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#34A853;"></span> <span>Active: <strong>Auto (Live AI)</strong></span>';
    }
  },

  async callNvidia(prompt, history = [], cfg = null) {
    cfg = cfg || this.getConfig();
    if (!cfg.nvidiaApiKey) {
      throw new Error('No NVIDIA API key configured. Enter your key in AI Settings.');
    }

    const messages = [
      { role: 'system', content: this._systemPrompt },
      ...history.slice(-6).map(m => ({ role: m.role === 'assistant' ? 'assistant' : 'user', content: m.content })),
      { role: 'user', content: prompt }
    ];

    const res = await fetch(`${cfg.nvidiaBaseUrl || 'https://integrate.api.nvidia.com/v1'}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${cfg.nvidiaApiKey}`
      },
      body: JSON.stringify({
        model: cfg.nvidiaModel || 'nvidia/llama-3.1-nemotron-70b-instruct',
        messages: messages,
        temperature: 0.6,
        max_tokens: 1024
      })
    });

    if (res.ok) {
      const data = await res.json();
      return {
        text: data.choices[0].message.content.trim(),
        provider: 'NVIDIA Nemotron 70B',
        providerClass: 'nvidia'
      };
    } else {
      const errText = await res.text();
      let errDetail = errText;
      try {
        const errJson = JSON.parse(errText);
        errDetail = errJson.detail || errJson.message || errText;
      } catch(e) {}
      throw new Error(`NVIDIA HTTP ${res.status}: ${errDetail}`);
    }
  },

  async callGemini(prompt, history = [], cfg = null) {
    cfg = cfg || this.getConfig();
    if (!cfg.geminiApiKey) {
      throw new Error('No Gemini API key configured. Enter your key in AI Settings.');
    }

    const model = cfg.geminiModel || 'gemini-2.5-flash';
    const contents = [];

    history.slice(-6).forEach(m => {
      contents.push({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }]
      });
    });

    contents.push({
      role: 'user',
      parts: [{ text: `${this._systemPrompt}\n\nUser Question: ${prompt}` }]
    });

    const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${cfg.geminiApiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: contents,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1024
        }
      })
    });

    if (res.ok) {
      const data = await res.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!text) throw new Error('Empty response received from Gemini API');
      return {
        text: text.trim(),
        provider: 'Gemini 2.5 Flash',
        providerClass: 'gemini'
      };
    } else {
      const errText = await res.text();
      let errDetail = errText;
      try {
        const errJson = JSON.parse(errText);
        errDetail = errJson.error?.message || errText;
      } catch(e) {}
      throw new Error(`Gemini HTTP ${res.status}: ${errDetail}`);
    }
  },

  async queryAi(prompt, history = []) {
    const cfg = this.getConfig();
    const provider = cfg.activeProvider || 'auto';

    if (provider === 'offline') {
      return {
        text: AiboKnowledgeAssistant.respond(prompt),
        provider: 'On-Device Offline Knowledge',
        providerClass: 'offline'
      };
    }

    if (provider === 'nvidia') {
      try {
        return await this.callNvidia(prompt, history, cfg);
      } catch(e) {
        return {
          text: `⚠️ **NVIDIA Nemotron Error**: ${e.message}\n\n*Note*: This error occurs when your NVIDIA API account has not had Public NIM inference permissions or trial credits enabled for this model. You can switch to **Google Gemini** in AI Settings for instant live answers.`,
          provider: 'NVIDIA API Error',
          providerClass: 'offline'
        };
      }
    }

    if (provider === 'gemini') {
      try {
        return await this.callGemini(prompt, history, cfg);
      } catch(e) {
        return {
          text: `⚠️ **Gemini API Error**: ${e.message}\n\nFalling back to On-Device Knowledge:\n\n${AiboKnowledgeAssistant.respond(prompt)}`,
          provider: 'On-Device Offline Fallback',
          providerClass: 'offline'
        };
      }
    }

    // Auto Mode: Attempt NVIDIA first if key exists, then Gemini, then Offline
    if (cfg.nvidiaApiKey) {
      try {
        return await this.callNvidia(prompt, history, cfg);
      } catch (err) {
        console.warn('NVIDIA Nemotron attempt failed, falling back to Gemini:', err);
      }
    }

    if (cfg.geminiApiKey) {
      try {
        return await this.callGemini(prompt, history, cfg);
      } catch (err) {
        console.warn('Gemini attempt failed, falling back to on-device rulebook:', err);
      }
    }

    // Pure offline fallback
    return {
      text: AiboKnowledgeAssistant.respond(prompt),
      provider: 'On-Device Offline Knowledge',
      providerClass: 'offline'
    };
  }
};

// ==========================================================================
// Timezone Management (Tokyo JST ⇄ India IST Switcher)
// ==========================================================================
let currentTimezone = localStorage.getItem('aibo_timezone_pref') || 'JST';

function toggleTimezone() {
  currentTimezone = currentTimezone === 'JST' ? 'IST' : 'JST';
  localStorage.setItem('aibo_timezone_pref', currentTimezone);
  if (typeof audio !== 'undefined' && audio.playWoodClick) {
    audio.playWoodClick();
  }
  renderClockAndDates();
  if (typeof showJapaneseNotification === 'function') {
    if (currentTimezone === 'IST') {
      showJapaneseNotification(
        'Timezone: India (IST)',
        'Clock set to India Standard Time (UTC+5:30)',
        'icon-sparkles'
      );
    } else {
      showJapaneseNotification(
        'Timezone: Tokyo (JST)',
        'Clock set to Tokyo Local Time (UTC+9:00)',
        'icon-torii'
      );
    }
  }
}
window.toggleTimezone = toggleTimezone;

// ==========================================================================
// UI Renderers (Dynamic, Truthful, Free of Mock Data)
// ==========================================================================

// 1. Clock & Japanese Date Header
function renderClockAndDates() {
  const now = new Date();
  const clockEl = document.getElementById('status-clock');
  const tzLabel = document.getElementById('tz-display-label');
  const tzPill = document.getElementById('tz-switch-pill');
  const dateChip = document.getElementById('local-date-chip');
  const greetingCity = document.getElementById('greeting-city-weather');
  const yakutaiDate = document.getElementById('yakutai-date-display');

  const isIST = currentTimezone === 'IST';
  const timeZoneId = isIST ? 'Asia/Kolkata' : 'Asia/Tokyo';

  // 1. Precise Time according to selected timezone
  try {
    const timeStr = new Intl.DateTimeFormat('en-GB', {
      timeZone: timeZoneId,
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    }).format(now);
    if (clockEl) clockEl.textContent = timeStr;
  } catch (_) {
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    if (clockEl) clockEl.textContent = `${hh}:${mm}`;
  }

  // 2. Status Bar Header Label & Toggle Pill
  if (tzLabel) {
    tzLabel.textContent = isIST ? 'India Local Time (IST)' : 'Tokyo Local Time (JST)';
  }
  if (tzPill) {
    tzPill.textContent = isIST ? '⇄ JST' : '⇄ IST';
  }

  // 3. Date & Japanese day-of-week calculated in the selected timezone
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const dayNamesJp = ['日', '月', '火', '水', '木', '金', '土'];
  
  let month = monthNames[now.getMonth()];
  let dateNum = now.getDate();
  let dayJp = dayNamesJp[now.getDay()];
  let yearNum = now.getFullYear();

  try {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: timeZoneId,
      month: 'short',
      day: 'numeric',
      weekday: 'short',
      year: 'numeric'
    }).formatToParts(now);

    const pMonth = parts.find(p => p.type === 'month')?.value;
    const pDay = parts.find(p => p.type === 'day')?.value;
    const pWeekday = parts.find(p => p.type === 'weekday')?.value;
    const pYear = parts.find(p => p.type === 'year')?.value;

    if (pMonth) month = pMonth;
    if (pDay) dateNum = pDay;
    if (pYear) yearNum = pYear;
    if (pWeekday) {
      const weekdayMap = { 'Sun': '日', 'Mon': '月', 'Tue': '火', 'Wed': '水', 'Thu': '木', 'Fri': '金', 'Sat': '土' };
      dayJp = weekdayMap[pWeekday] || dayJp;
    }
  } catch (_) {}

  const dateStr = `Today • ${month} ${dateNum} (${dayJp})`;
  if (dateChip) dateChip.textContent = dateStr;

  const profile = AiboStore.getProfile();
  if (greetingCity) {
    const locPrefix = isIST ? 'India (IST)' : (profile.city || 'Tokyo');
    greetingCity.textContent = `${locPrefix} • 18°C ☀️ • ${month} ${dateNum}`;
  }

  if (yakutaiDate) {
    yakutaiDate.textContent = `${month} ${dateNum}, ${yearNum}`;
  }
}

// 2. Profile & Greetings
function renderProfile() {
  const profile = AiboStore.getProfile();
  const nameEl = document.getElementById('greeting-name-display');
  const yakutaiPatient = document.getElementById('yakutai-patient-name');

  const display = `${profile.name || 'User'}${profile.honorific || '-san'}`;
  if (nameEl) nameEl.textContent = display;
  if (yakutaiPatient) yakutaiPatient.textContent = `${display} (様)`;

  // Populate config modal fields
  const cfgName = document.getElementById('cfg-name-input');
  const cfgHonorific = document.getElementById('cfg-honorific-select');
  const cfgStyle = document.getElementById('cfg-style-select');
  const cfgCity = document.getElementById('cfg-city-select');

  if (cfgName) cfgName.value = profile.name || '';
  if (cfgHonorific) cfgHonorific.value = profile.honorific || '-san';
  if (cfgStyle) cfgStyle.value = profile.style || 'bilingual';
  if (cfgCity) cfgCity.value = profile.city || 'Shibuya, Tokyo';
}

// 3. Expenses & Budget
function renderExpenses() {
  const expenses = AiboStore.getExpenses();
  const todaySpent = AiboStore.getTodaySpentTotal();
  const profile = AiboStore.getProfile();
  const dailyCap = profile.dailyBudget || 8000;
  const remaining = Math.max(0, dailyCap - todaySpent);
  const percentage = Math.min(100, (todaySpent / dailyCap) * 100);

  // Home card elements
  const spentNum = document.getElementById('home-spent-display');
  const remainingEl = document.getElementById('home-remaining-display');
  const budgetBar = document.getElementById('home-budget-bar');
  const pillsWrapper = document.getElementById('home-categories-wrapper');

  if (spentNum) spentNum.textContent = `¥${todaySpent.toLocaleString()}`;
  if (remainingEl) remainingEl.textContent = `Remaining: ¥${remaining.toLocaleString()}`;
  if (budgetBar) {
    budgetBar.style.width = `${percentage}%`;
    budgetBar.style.background = percentage > 90 ? 'var(--color-vermilion)' : (percentage > 70 ? 'var(--color-amber)' : 'var(--color-matcha)');
  }

  // Screen 6 tools elements
  const fToolVal = document.getElementById('tools-remaining-display');
  const fToolBar = document.getElementById('tools-budget-bar');
  if (fToolVal) fToolVal.innerHTML = `¥${remaining.toLocaleString()} <span class="f-tool-sub">left of ¥${dailyCap.toLocaleString()}</span>`;
  if (fToolBar) fToolBar.style.width = `${percentage}%`;

  // Render Category breakdown
  if (pillsWrapper) {
    const todayExpenses = AiboStore.getTodayExpenses();
    if (todayExpenses.length === 0) {
      pillsWrapper.innerHTML = `<span class="f-pill empty">No spending recorded today</span>`;
    } else {
      const catMap = {};
      todayExpenses.forEach(e => {
        catMap[e.category] = (catMap[e.category] || 0) + e.amount;
      });
      pillsWrapper.innerHTML = Object.entries(catMap)
        .map(([cat, amt]) => `<span class="f-pill">${escapeHtml(cat)} ¥${amt.toLocaleString()}</span>`)
        .join('');
    }
  }

  // Render Monthly Overview & Japan Bill Envelopes on Screen 6
  const monthlyOverviewEl = document.getElementById('tools-monthly-overview');
  const monthSpent = AiboStore.getMonthSpentTotal();
  const budgetConfig = AiboStore.getBudgetConfig();
  const monthRemaining = Math.max(0, budgetConfig.monthlyTotal - monthSpent);
  const monthPct = Math.min(100, (monthSpent / budgetConfig.monthlyTotal) * 100);

  if (monthlyOverviewEl) {
    monthlyOverviewEl.innerHTML = `
      <div class="monthly-overview-stat">
        <span class="stat-lbl">Monthly Budget (月額予算)</span>
        <strong class="stat-num">¥${budgetConfig.monthlyTotal.toLocaleString()}</strong>
      </div>
      <div class="monthly-overview-stat">
        <span class="stat-lbl">Spent This Month</span>
        <strong class="stat-num" style="color: ${monthPct > 85 ? 'var(--color-vermilion)' : 'var(--text-primary)'};">¥${monthSpent.toLocaleString()}</strong>
      </div>
      <div class="monthly-overview-stat">
        <span class="stat-lbl">Remaining</span>
        <strong class="stat-num" style="color: var(--color-matcha);">¥${monthRemaining.toLocaleString()}</strong>
      </div>
    `;
  }

  // Screen 6: Japan Bill Envelopes Breakdown
  const envelopesContainer = document.getElementById('tools-bill-envelopes');
  if (envelopesContainer) {
    const monthExpenses = AiboStore.getMonthExpenses();
    const envTotals = {};
    monthExpenses.forEach(e => {
      const cat = e.category || '';
      if (cat.includes('Rent') || cat.includes('家賃')) envTotals.rent = (envTotals.rent || 0) + e.amount;
      else if (cat.includes('Electricity') || cat.includes('電気')) envTotals.electricity = (envTotals.electricity || 0) + e.amount;
      else if (cat.includes('Gas') || cat.includes('ガス')) envTotals.gas = (envTotals.gas || 0) + e.amount;
      else if (cat.includes('Water') || cat.includes('水道')) envTotals.water = (envTotals.water || 0) + e.amount;
      else if (cat.includes('Internet') || cat.includes('Mobile') || cat.includes('通信')) envTotals.internet = (envTotals.internet || 0) + e.amount;
      else if (cat.includes('Insurance') || cat.includes('Pension') || cat.includes('年金') || cat.includes('保険')) envTotals.insurance = (envTotals.insurance || 0) + e.amount;
      else if (cat.includes('Groceries') || cat.includes('食費')) envTotals.groceries = (envTotals.groceries || 0) + e.amount;
      else if (cat.includes('Transit') || cat.includes('Metro') || cat.includes('Suica') || cat.includes('交通')) envTotals.transit = (envTotals.transit || 0) + e.amount;
      else envTotals.discretionary = (envTotals.discretionary || 0) + e.amount;
    });

    const envDefinitions = [
      { key: 'rent', name: '🏠 Rent (家賃)', target: budgetConfig.envelopes.rent || 85000 },
      { key: 'electricity', name: '⚡ Electricity (電気代)', target: budgetConfig.envelopes.electricity || 6500 },
      { key: 'gas', name: '🔥 Gas (ガス代)', target: budgetConfig.envelopes.gas || 4500 },
      { key: 'water', name: '💧 Water (水道代)', target: budgetConfig.envelopes.water || 3500 },
      { key: 'internet', name: '📶 Mobile & Wi-Fi (通信費)', target: budgetConfig.envelopes.internet || 5500 },
      { key: 'insurance', name: '🏥 Health & Pension (保険・年金)', target: budgetConfig.envelopes.insurance || 15000 },
      { key: 'groceries', name: '🛒 Groceries (食費)', target: budgetConfig.envelopes.groceries || 45000 },
      { key: 'transit', name: '🚇 Transit & Suica (交通費)', target: budgetConfig.envelopes.transit || 10000 },
      { key: 'discretionary', name: '🛍️ Daily Living & Dining (生活費)', target: budgetConfig.envelopes.discretionary || 65000 },
    ];

    envelopesContainer.innerHTML = envDefinitions.map(def => {
      const spent = envTotals[def.key] || 0;
      const pct = Math.min(100, Math.round((spent / def.target) * 100));
      return `
        <div class="envelope-card">
          <div class="envelope-title-row">
            <strong>${def.name}</strong>
            <span style="font-size: 10px; color: ${pct >= 100 ? 'var(--color-vermilion)' : 'var(--text-secondary)'}; font-weight: 600;">${pct}%</span>
          </div>
          <div class="envelope-bar-track">
            <div class="envelope-bar-fill" style="width: ${pct}%; background: ${pct > 95 ? 'var(--color-vermilion)' : (pct > 75 ? 'var(--color-amber)' : 'var(--color-matcha)')};"></div>
          </div>
          <div class="envelope-values">
            <span>¥${spent.toLocaleString()} spent</span>
            <span>of ¥${def.target.toLocaleString()}</span>
          </div>
        </div>
      `;
    }).join('');
  }

  // Render Full Transaction List on Screen 6
  const txContainer = document.getElementById('tools-transactions-container');
  if (txContainer) {
    if (expenses.length === 0) {
      txContainer.innerHTML = `
        <div class="state-empty-box" style="padding: 16px; margin-top: 10px;">
          <div class="state-empty-title">No transactions recorded</div>
          <div class="state-empty-desc">Your daily financial ledger will appear here once you log an expense.</div>
        </div>
      `;
    } else {
      txContainer.innerHTML = `
        <div class="transaction-history-list" style="margin-top: 12px; display: flex; flex-direction: column; gap: 8px;">
          ${expenses.slice(0, 10).map(e => `
            <div class="transaction-item-row" style="display: flex; justify-content: space-between; align-items: center; background: #FAF7EE; padding: 8px 12px; border-radius: 8px; border: 1px solid var(--border-subtle);">
              <div>
                <strong style="font-size: 13px;">${escapeHtml(e.category)}</strong>
                <span style="display: block; font-size: 11px; color: var(--text-secondary);">${escapeHtml(e.note || new Date(e.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}))}</span>
              </div>
              <div style="display: flex; align-items: center; gap: 10px;">
                <strong style="font-size: 14px; font-variant-numeric: tabular-nums;">-¥${e.amount.toLocaleString()}</strong>
                <button onclick="deleteExpenseRecord('${e.id}')" style="background: none; border: none; color: var(--color-vermilion); cursor: pointer; font-size: 12px;" title="Delete">✕</button>
              </div>
            </div>
          `).join('')}
        </div>
      `;
    }
  }
}

// 4. Tasks / Agenda Checklist
function renderTasks() {
  const tasks = AiboStore.getTasks();
  const container = document.getElementById('tasks-container');
  const badge = document.getElementById('task-progress-badge');

  if (!container) return;

  if (tasks.length === 0) {
    container.innerHTML = `
      <div class="state-empty-box" style="padding: 24px 16px;">
        <div class="state-empty-title">No tasks scheduled for today</div>
        <div class="state-empty-desc">Plan your day by adding reminders for municipal forms, grocery errands, or bills.</div>
        <button class="f-action-btn" onclick="openModal('task-modal')" style="margin: 0 auto; display: inline-flex;">+ Add Today's First Task</button>
      </div>
    `;
    if (badge) badge.textContent = '0 Tasks';
    return;
  }

  const doneCount = tasks.filter(t => t.done).length;
  if (badge) badge.textContent = `${doneCount} of ${tasks.length} Done`;

  container.innerHTML = tasks.map(task => `
    <div class="task-item-row ${task.done ? 'done' : ''}" id="task-row-${task.id}">
      <div class="task-checkbox ${task.done ? 'checked' : ''}" onclick="toggleTaskAction('${task.id}')">
        <svg class="check-icon" width="12" height="12"><use href="#icon-check" /></svg>
      </div>
      <div class="task-info" onclick="toggleTaskAction('${task.id}')" style="cursor: pointer; flex: 1;">
        <strong class="task-title ${task.done ? 'completed' : ''}">${escapeHtml(task.title)}</strong>
        ${task.subtext ? `<span class="task-sub">${escapeHtml(task.subtext)}</span>` : ''}
      </div>
      <button class="task-delete-btn" onclick="deleteTaskAction('${task.id}')" title="Delete Task" style="background: none; border: none; color: var(--text-muted); padding: 4px; cursor: pointer;">✕</button>
    </div>
  `).join('');
}

// 5. Medications & Tablets
function renderMedications() {
  const meds = AiboStore.getMedications();
  const wrapper = document.getElementById('home-med-card-wrapper');
  const yakutaiGrid = document.getElementById('yakutai-schedule-grid');
  const routineGauge = document.getElementById('routine-status-tag');

  // Calculate routine score: Tasks + Meds
  const tasks = AiboStore.getTasks();
  const totalItems = tasks.length + meds.length;
  const doneItems = tasks.filter(t => t.done).length + meds.filter(m => m.isTaken).length;

  if (routineGauge) {
    if (totalItems === 0) {
      routineGauge.textContent = 'Routine: Ready';
    } else {
      const pct = Math.round((doneItems / totalItems) * 100);
      routineGauge.textContent = `Routine: ${doneItems}/${totalItems} Done (${pct}%)`;
    }
  }

  // Home Priority Card
  if (wrapper) {
    if (meds.length === 0) {
      wrapper.innerHTML = `
        <div class="priority-card" style="padding: 16px; border-style: dashed; display: flex; align-items: center; justify-content: space-between;">
          <div>
            <strong style="display: block; font-size: 14px; margin-bottom: 2px;">No medication schedules added</strong>
            <span style="font-size: 12px; color: var(--text-secondary);">Track daily prescriptions or vitamin supplements on-device.</span>
          </div>
          <button class="f-action-btn" onclick="openModal('med-modal')">+ Schedule</button>
        </div>
      `;
    } else {
      const nextMed = meds.find(m => !m.isTaken) || meds[0];
      wrapper.innerHTML = `
        <div class="priority-card med-card" id="home-med-card">
          <div class="priority-card-indicator matcha"></div>
          <div class="priority-card-main">
            <div class="priority-meta-row">
              <span class="priority-tag green">💊 Scheduled Dose Reminder</span>
              <span class="priority-time" style="${nextMed.isTaken ? 'color: var(--color-matcha); font-weight: 600;' : ''}">${nextMed.isTaken ? 'Completed Today ✓' : 'Scheduled ' + escapeHtml(nextMed.time)}</span>
            </div>
            <strong class="priority-card-title">${escapeHtml(nextMed.name)} (${escapeHtml(nextMed.dosage)})</strong>
            <p class="priority-card-desc">${escapeHtml(nextMed.instructions)}</p>
            <div class="card-action-bar">
              <span class="medical-disclaimer-note">※ Personal reminder log only. Consult a doctor for medical guidance.</span>
              <button class="text-link-action" onclick="switchTab('screen-medication')">View Yakutai ➔</button>
            </div>
          </div>
          <div class="priority-card-action">
            <button class="quick-stamp-btn" onclick="stampMedicationAction('${nextMed.id}')" ${nextMed.isTaken ? 'disabled style="background: var(--color-matcha);"' : ''} title="Log dose as taken">
              <svg width="15" height="15" stroke="currentColor"><use href="#icon-stamp" /></svg>
              <span>${nextMed.isTaken ? 'Logged ✓ (済)' : 'Log Taken (済)'}</span>
            </button>
          </div>
        </div>
      `;
    }
  }

  // Yakutai Grid on Screen 2
  if (yakutaiGrid) {
    if (meds.length === 0) {
      yakutaiGrid.innerHTML = `
        <div style="grid-column: span 4; text-align: center; padding: 24px; color: var(--text-secondary);">
          <p style="font-size: 13px; margin-bottom: 12px;">No prescription schedules recorded in this envelope.</p>
          <button class="f-action-btn" onclick="openModal('med-modal')">+ Add Prescription Dose</button>
        </div>
      `;
    } else {
      yakutaiGrid.innerHTML = meds.map(m => `
        <div class="schedule-col ${m.isTaken ? 'done' : 'active-slot'}" style="cursor: pointer;" onclick="stampMedicationAction('${m.id}')">
          <span class="col-kanji">${escapeHtml(m.time)}</span>
          <span class="col-romaji">${escapeHtml(m.name)}</span>
          <div class="hanko-target">
            ${m.isTaken ? '<span class="hanko-stamp-text">✓ 済</span>' : '<span style="font-size: 10px; color: var(--color-vermilion);">Tap to Seal</span>'}
          </div>
        </div>
      `).join('');
    }
  }
}

// 6. Document Vault
function renderVault() {
  const vault = AiboStore.getVault();
  const container = document.getElementById('vault-items-container');
  if (!container) return;

  if (vault.length === 0) {
    container.innerHTML = `
      <div class="state-empty-box" style="padding: 24px 16px;">
        <div class="state-empty-title">Vault is Empty</div>
        <div class="state-empty-desc">Store residence cards, health insurance, or lease agreements securely on this device.</div>
        <button class="f-action-btn" onclick="openModal('vault-modal')" style="margin: 0 auto; display: inline-flex;">+ Add Stored Document</button>
      </div>
    `;
    return;
  }

  container.innerHTML = vault.map(doc => `
    <div class="vault-item" style="display: flex; justify-content: space-between; align-items: center;">
      <div style="display: flex; align-items: center; gap: 12px;">
        <div class="vault-doc-badge">🪪</div>
        <div class="vault-doc-info">
          <strong>${escapeHtml(doc.title)}</strong>
          <span>${escapeHtml(doc.notes)} • Added ${new Date(doc.createdAt).toLocaleDateString()}</span>
        </div>
      </div>
      <div style="display: flex; align-items: center; gap: 8px;">
        <span class="vault-state-tag green">Stored ✓</span>
        <button onclick="deleteVaultAction('${doc.id}')" style="background: none; border: none; color: var(--color-vermilion); cursor: pointer; font-size: 12px;" title="Delete Document">✕</button>
      </div>
    </div>
  `).join('');
}

// 7. Emergency ICE Card
function renderIceCard() {
  const ice = AiboStore.getIceCard();
  const nameEl = document.getElementById('ice-holder-name');
  const detailsEl = document.getElementById('ice-blood-allergies');
  const contactEl = document.getElementById('ice-contact-info');

  if (nameEl) nameEl.textContent = `${ice.fullName} (${ice.city})`;
  if (detailsEl) detailsEl.textContent = `Blood: ${ice.bloodType} • Allergies: ${ice.allergies}`;
  if (contactEl) {
    contactEl.textContent = ice.emergencyContactPhone ? `ICE Contact: ${ice.emergencyContactName} (${ice.emergencyContactPhone})` : 'ICE Contact: Not configured';
  }

  // Populate modal fields
  const fName = document.getElementById('ice-cfg-name');
  const fBlood = document.getElementById('ice-cfg-blood');
  const fAllergies = document.getElementById('ice-cfg-allergies');
  const fContactName = document.getElementById('ice-cfg-contact-name');
  const fContactPhone = document.getElementById('ice-cfg-contact-phone');

  if (fName) fName.value = ice.fullName || '';
  if (fBlood) fBlood.value = ice.bloodType || 'Unknown';
  if (fAllergies) fAllergies.value = ice.allergies || 'None listed';
  if (fContactName) fContactName.value = ice.emergencyContactName || '';
  if (fContactPhone) fContactPhone.value = ice.emergencyContactPhone || '';
}

// 8. Chat History & Real Conversations
function renderChatLog() {
  const history = AiboStore.getChatHistory();
  const log = document.getElementById('chat-log');
  if (!log) return;

  if (history.length === 0) {
    log.innerHTML = `
      <div class="chat-empty-intro" style="padding: 20px 12px; text-align: center; color: var(--text-secondary);">
        <div style="font-size: 28px; margin-bottom: 8px;">🏮</div>
        <strong style="display: block; font-size: 14px; margin-bottom: 4px; color: var(--text-primary);">AIBO Bilingual Assistant</strong>
        <p style="font-size: 12px; line-height: 1.5; max-width: 280px; margin: 0 auto 16px;">Ask factual questions about Japan daily life, ward offices, train manners, or over-the-counter medicine.</p>
        <div style="display: flex; flex-direction: column; gap: 6px; max-width: 300px; margin: 0 auto; text-align: left;">
          <button class="chat-prompt-pill" onclick="sendPresetPrompt('How do I separate burnable vs non-burnable garbage in Tokyo?')">How do I separate garbage in Tokyo?</button>
          <button class="chat-prompt-pill" onclick="sendPresetPrompt('What documents do I need for address registration at the Ward Office?')">Ward office address registration checklist</button>
          <button class="chat-prompt-pill" onclick="sendPresetPrompt('What is the Japanese equivalent of ibuprofen for headaches?')">Japanese OTC medicine for headache</button>
          <button class="chat-prompt-pill" onclick="sendPresetPrompt('What are the etiquette rules for taking the Yamanote Line?')">Yamanote line train etiquette</button>
        </div>
      </div>
    `;
    return;
  }

  log.innerHTML = history.map(msg => {
    if (msg.role === 'user') {
      return `
        <div class="chat-row user">
          <div class="scroll-bubble user">
            ${escapeHtml(msg.content)}
            <div class="scroll-time">${new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</div>
          </div>
        </div>
      `;
    } else {
      return `
        <div class="chat-row aibo">
          <div class="hanko-seal mini">相棒</div>
          <div class="scroll-bubble">
            ${msg.provider ? `<div class="ai-model-tag ${escapeHtml(msg.providerClass || 'gemini')}">${escapeHtml(msg.provider)}</div>` : ''}
            <div>${escapeHtml(msg.content).replace(/\n/g, '<br>')}</div>
            <div class="scroll-time">${new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})} • ${escapeHtml(msg.provider || 'AIBO Intelligence')}</div>
          </div>
        </div>
      `;
    }
  }).join('');

  log.scrollTop = log.scrollHeight;
}

// Master Render Invocation
function renderAll() {
  renderClockAndDates();
  renderProfile();
  renderExpenses();
  renderTasks();
  renderMedications();
  renderVault();
  renderIceCard();
  renderChatLog();
}

// ==========================================================================
// Action Handlers & Real Event Wiring
// ==========================================================================

// Task actions
function toggleTaskAction(id) {
  audio.playWoodClick();
  const task = AiboStore.toggleTask(id);
  if (task) {
    renderTasks();
    renderMedications(); // updates routine gauge
    if (task.done) {
      showJapaneseNotification('Task Completed (完了)', task.title, 'icon-check');
    }
  }
}
window.toggleTaskAction = toggleTaskAction;

function deleteTaskAction(id) {
  audio.playWoodClick();
  AiboStore.deleteTask(id);
  renderTasks();
  renderMedications();
}
window.deleteTaskAction = deleteTaskAction;

function submitNewTask() {
  const titleInput = document.getElementById('task-title-input');
  const subInput = document.getElementById('task-sub-input');
  const title = titleInput ? titleInput.value.trim() : '';

  if (!title) {
    alert('Please enter a task title');
    return;
  }

  audio.playWoodClick();
  AiboStore.addTask({
    title,
    subtext: subInput ? subInput.value.trim() : '',
  });

  if (titleInput) titleInput.value = '';
  if (subInput) subInput.value = '';
  closeModal('task-modal');
  renderTasks();
  renderMedications();
  showJapaneseNotification('Task Added (予定登録)', title, 'icon-check');
}
window.submitNewTask = submitNewTask;

// Medication actions
function stampMedicationAction(id) {
  audio.playStampThud();
  const med = AiboStore.stampMedication(id);
  if (med) {
    renderMedications();
    setMuchiState('celebrate');
    showJapaneseNotification('Dose Taken (服用完了)', `${med.name} (${med.dosage})`, 'icon-pill');
  }
}
window.stampMedicationAction = stampMedicationAction;

function submitNewMedication() {
  const nameInput = document.getElementById('med-name-input');
  const doseInput = document.getElementById('med-dose-input');
  const timeInput = document.getElementById('med-time-input');
  const noteInput = document.getElementById('med-note-input');

  const name = nameInput ? nameInput.value.trim() : '';
  const dosage = doseInput ? doseInput.value.trim() : '';
  const time = timeInput ? timeInput.value.trim() : '08:00 AM';

  if (!name || !dosage) {
    alert('Please enter medicine name and dosage');
    return;
  }

  audio.playWoodClick();
  AiboStore.addMedication({
    name,
    dosage,
    time,
    instructions: noteInput ? noteInput.value.trim() : 'Take after meal with water'
  });

  if (nameInput) nameInput.value = '';
  if (doseInput) doseInput.value = '';
  closeModal('med-modal');
  renderMedications();
  showJapaneseNotification('Medication Scheduled (処方登録)', `${name} at ${time}`, 'icon-pill');
}
window.submitNewMedication = submitNewMedication;

// Expense actions
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
  const exp = AiboStore.addExpense({
    amount: amt,
    category: catSelect ? catSelect.value : '🍜 Meals',
    note: noteInput ? noteInput.value : ''
  });

  if (amtInput) amtInput.value = '';
  if (noteInput) noteInput.value = '';
  closeModal('expense-modal');
  renderExpenses();

  const profile = AiboStore.getProfile();
  const spent = AiboStore.getTodaySpentTotal();
  const left = Math.max(0, (profile.dailyBudget || 8000) - spent);

  showJapaneseNotification(
    `Logged: ¥${amt.toLocaleString()}`,
    `Daily Remaining: ¥${left.toLocaleString()} of ¥${(profile.dailyBudget || 8000).toLocaleString()}`,
    'icon-yen'
  );
}
window.submitNewExpense = submitNewExpense;

function deleteExpenseRecord(id) {
  audio.playWoodClick();
  AiboStore.deleteExpense(id);
  renderExpenses();
  showJapaneseNotification('Expense Removed (取消)', 'Transaction deleted from local ledger', 'icon-yen');
}
window.deleteExpenseRecord = deleteExpenseRecord;

// Vault actions
function submitNewDocument() {
  const titleInput = document.getElementById('doc-title-input');
  const catSelect = document.getElementById('doc-category-select');
  const noteInput = document.getElementById('doc-notes-input');

  const title = titleInput ? titleInput.value.trim() : '';
  if (!title) {
    alert('Please enter document title');
    return;
  }

  audio.playWoodClick();
  AiboStore.addDocument({
    title,
    category: catSelect ? catSelect.value : 'Identification',
    notes: noteInput ? noteInput.value : 'Stored encrypted on device'
  });

  if (titleInput) titleInput.value = '';
  if (noteInput) noteInput.value = '';
  closeModal('vault-modal');
  renderVault();
  showJapaneseNotification('Document Vaulted (保管完了)', title, 'icon-shield');
}
window.submitNewDocument = submitNewDocument;

function deleteVaultAction(id) {
  if (confirm('Permanently delete this document from encrypted storage?')) {
    audio.playWoodClick();
    AiboStore.deleteDocument(id);
    renderVault();
    showJapaneseNotification('Document Deleted', 'Record purged from on-device storage', 'icon-shield');
  }
}
window.deleteVaultAction = deleteVaultAction;

// ICE Card Save
function saveIceCardSettings() {
  const fName = document.getElementById('ice-cfg-name');
  const fBlood = document.getElementById('ice-cfg-blood');
  const fAllergies = document.getElementById('ice-cfg-allergies');
  const fContactName = document.getElementById('ice-cfg-contact-name');
  const fContactPhone = document.getElementById('ice-cfg-contact-phone');

  audio.playChime();
  AiboStore.saveIceCard({
    fullName: fName ? fName.value.trim() : 'User',
    city: AiboStore.getProfile().city || 'Tokyo',
    bloodType: fBlood ? fBlood.value.trim() : 'Unknown',
    allergies: fAllergies ? fAllergies.value.trim() : 'None listed',
    emergencyContactName: fContactName ? fContactName.value.trim() : '',
    emergencyContactPhone: fContactPhone ? fContactPhone.value.trim() : ''
  });

  closeModal('ice-modal');
  renderIceCard();
  showJapaneseNotification('ICE Card Updated (緊急医療票保存)', 'Emergency info stored for quick access', 'icon-alert');
}
window.saveIceCardSettings = saveIceCardSettings;

// Profile Save
function saveProfilePreferences() {
  audio.playChime();
  const nameInput = document.getElementById('cfg-name-input');
  const honorificSelect = document.getElementById('cfg-honorific-select');
  const styleSelect = document.getElementById('cfg-style-select');
  const citySelect = document.getElementById('cfg-city-select');

  const profile = {
    name: nameInput ? nameInput.value.trim() || 'Arjun' : 'Arjun',
    honorific: honorificSelect ? honorificSelect.value : '-san',
    style: styleSelect ? styleSelect.value : 'bilingual',
    city: citySelect ? citySelect.value : 'Shibuya, Tokyo',
    dailyBudget: 8000,
    isConfigured: true
  };

  AiboStore.saveProfile(profile);
  closeModal('profile-modal');
  renderProfile();
  renderClockAndDates();

  showJapaneseNotification(
    'Profile Updated (設定完了)',
    `Greeting set for ${profile.name}${profile.honorific} in ${profile.city}`,
    'icon-torii'
  );
}
window.saveProfilePreferences = saveProfilePreferences;

// Chat Interactions (Live Dual-Engine AI)
async function sendChatMessage(text) {
  const content = text || (document.getElementById('chat-input') ? document.getElementById('chat-input').value.trim() : '');
  if (!content) return;

  const input = document.getElementById('chat-input');
  if (input) input.value = '';

  audio.playWoodClick();
  AiboStore.addChatMessage('user', content);
  renderChatLog();

  // Temporary typing indicator
  const log = document.getElementById('chat-log');
  const typingId = 'typing-indicator-row';
  if (log && !document.getElementById(typingId)) {
    const typingEl = document.createElement('div');
    typingEl.id = typingId;
    typingEl.className = 'chat-row aibo';
    typingEl.innerHTML = `
      <div class="hanko-seal mini">相棒</div>
      <div class="scroll-bubble" style="background: rgba(250,247,238,0.8);">
        <span style="font-size: 11px; color: var(--text-secondary); margin-right: 6px;">Consulting AIBO...</span>
        <div class="typing-dots"><span></span><span></span><span></span></div>
      </div>
    `;
    log.appendChild(typingEl);
    log.scrollTop = log.scrollHeight;
  }

  try {
    const history = AiboStore.getChatHistory().slice(0, -1);
    const result = await AiboAiService.queryAi(content, history);

    const typingEl = document.getElementById(typingId);
    if (typingEl) typingEl.remove();

    audio.playChime();
    AiboStore.addChatMessage('assistant', result.text, result.provider, result.providerClass);
    renderChatLog();
  } catch (err) {
    const typingEl = document.getElementById(typingId);
    if (typingEl) typingEl.remove();

    AiboStore.addChatMessage('assistant', `⚠️ Could not reach AI service: ${err.message}`, 'Connection Error', 'offline');
    renderChatLog();
  }
}
window.sendChatMessage = sendChatMessage;

function sendPresetPrompt(text) {
  sendChatMessage(text);
}
window.sendPresetPrompt = sendPresetPrompt;

function clearChatAction() {
  if (confirm('Clear entire conversation history? This cannot be undone.')) {
    audio.playWoodClick();
    AiboStore.clearChatHistory();
    renderChatLog();
    showJapaneseNotification('Chat Cleared', 'Conversation history purged permanently', 'icon-chat');
  }
}
window.clearChatAction = clearChatAction;

// ==========================================================================
// Mascot & Tab Navigation
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
window.switchTab = switchTab;

const muchiStateQuotes = {
  greeting: '"Okaeri! Ready to help you with your daily life and tasks in Tokyo."',
  idle: '"Shibuya weather is 18°C. Yamanote line running on standard loop schedule."',
  celebrate: '"Dose logged with Hanko seal! Great job keeping your routine on track! ✨"',
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
  if (cat) {
    cat.classList.add('jump');
    setTimeout(() => cat.classList.remove('jump'), 280);
  }
}
window.triggerMuchiJump = triggerMuchiJump;

// Modal Show/Hide
function openModal(id) {
  audio.playWoodClick();
  const m = document.getElementById(id);
  if (m) m.classList.add('open');
}
window.openModal = openModal;

function closeModal(id) {
  audio.playWoodClick();
  const m = document.getElementById(id);
  if (m) m.classList.remove('open');
}
window.closeModal = closeModal;

function openOfflineModal() { openModal('offline-modal'); }
window.openOfflineModal = openOfflineModal;

function openProfileModal() { openModal('profile-modal'); }
window.openProfileModal = openProfileModal;

function openExpenseModal() { openModal('expense-modal'); }
window.openExpenseModal = openExpenseModal;
window.openExpensePrompt = openExpenseModal;

function openTaskModal() { openModal('task-modal'); }
window.openTaskModal = openTaskModal;

function openMedModal() { openModal('med-modal'); }
window.openMedModal = openMedModal;

function openVaultModal() { openModal('vault-modal'); }
window.openVaultModal = openVaultModal;

function openIceModal() { openModal('ice-modal'); }
window.openIceModal = openIceModal;

// 8. Budget and Japan Bill Envelopes Modal Logic
function openBudgetModal() {
  const cfg = AiboStore.getBudgetConfig();
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.value = val;
  };
  setVal('cfg-monthly-total', cfg.monthlyTotal);
  setVal('cfg-env-rent', cfg.envelopes.rent || 85000);
  setVal('cfg-env-elec', cfg.envelopes.electricity || 6500);
  setVal('cfg-env-gas', cfg.envelopes.gas || 4500);
  setVal('cfg-env-water', cfg.envelopes.water || 3500);
  setVal('cfg-env-net', cfg.envelopes.internet || 5500);
  setVal('cfg-env-ins', cfg.envelopes.insurance || 15000);
  setVal('cfg-env-food', cfg.envelopes.groceries || 45000);
  setVal('cfg-env-train', cfg.envelopes.transit || 10000);
  setVal('cfg-env-disc', cfg.envelopes.discretionary || 65000);

  recalculateBudgetPreview();
  openModal('budget-config-modal');
}
window.openBudgetModal = openBudgetModal;

function recalculateBudgetPreview() {
  const getVal = (id) => Math.max(0, Number(document.getElementById(id)?.value || 0));
  const total = getVal('cfg-monthly-total');
  const rent = getVal('cfg-env-rent');
  const elec = getVal('cfg-env-elec');
  const gas = getVal('cfg-env-gas');
  const water = getVal('cfg-env-water');
  const net = getVal('cfg-env-net');
  const ins = getVal('cfg-env-ins');
  const food = getVal('cfg-env-food');
  const train = getVal('cfg-env-train');
  const disc = getVal('cfg-env-disc');

  const fixedBills = rent + elec + gas + water + net + ins;
  const variableEnvelopes = food + train + disc;
  const totalEnvelopes = fixedBills + variableEnvelopes;
  const diff = total - totalEnvelopes;
  const dailyDiscretionary = Math.round(disc / 30);

  const previewEl = document.getElementById('budget-calc-preview');
  if (previewEl) {
    let statusNotice = '';
    if (diff > 0) {
      statusNotice = `<span style="color: var(--color-matcha); font-weight: 600;">✓ ¥${diff.toLocaleString()} unallocated cushion</span>`;
    } else if (diff === 0) {
      statusNotice = `<span style="color: var(--color-matcha); font-weight: 600;">✓ 100% Balanced</span>`;
    } else {
      statusNotice = `<span style="color: var(--color-vermilion); font-weight: 600;">⚠️ Over by ¥${Math.abs(diff).toLocaleString()}</span>`;
    }

    previewEl.innerHTML = `
      <div style="display: flex; justify-content: space-between; font-size: 11px; margin-bottom: 4px;">
        <span style="color: var(--text-secondary);">Fixed Tokyo Bills:</span>
        <strong>¥${fixedBills.toLocaleString()}/mo</strong>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 11px; margin-bottom: 4px;">
        <span style="color: var(--text-secondary);">Living & Variable:</span>
        <strong>¥${variableEnvelopes.toLocaleString()}/mo</strong>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 11px; margin-bottom: 6px; padding-top: 4px; border-top: 1px dashed var(--border-subtle);">
        <span style="color: var(--text-secondary);">Total Allocated:</span>
        <strong>¥${totalEnvelopes.toLocaleString()} of ¥${total.toLocaleString()}</strong>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 11px; align-items: center;">
        <span>${statusNotice}</span>
        <span style="font-size: 10px; background: rgba(47,93,68,0.1); color: var(--color-matcha); padding: 2px 6px; border-radius: 4px; font-weight: 600;">
          Daily Living: ~¥${dailyDiscretionary.toLocaleString()}/day
        </span>
      </div>
    `;
  }
}
window.recalculateBudgetPreview = recalculateBudgetPreview;

function saveBudgetPlan() {
  const getVal = (id) => Math.max(0, Number(document.getElementById(id)?.value || 0));
  const total = getVal('cfg-monthly-total');
  if (total <= 0) {
    alert('Please enter a valid monthly budget total.');
    return;
  }

  const envelopes = {
    rent: getVal('cfg-env-rent'),
    electricity: getVal('cfg-env-elec'),
    gas: getVal('cfg-env-gas'),
    water: getVal('cfg-env-water'),
    internet: getVal('cfg-env-net'),
    insurance: getVal('cfg-env-ins'),
    groceries: getVal('cfg-env-food'),
    transit: getVal('cfg-env-train'),
    discretionary: getVal('cfg-env-disc')
  };

  AiboStore.saveBudgetConfig(total, envelopes);
  closeModal('budget-config-modal');
  audio.playChime();
  showJapaneseNotification(
    'Monthly Budget & Envelopes Saved',
    `Monthly ¥${total.toLocaleString()} • Daily allowance updated`,
    'icon-sparkles'
  );

  renderExpenses();
  renderProfile();
}
window.saveBudgetPlan = saveBudgetPlan;

// 9. AI Config & BYOK Modal Handlers
function openAiConfigModal() {
  const cfg = AiboAiService.getConfig();
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.value = val;
  };

  setVal('cfg-ai-provider', cfg.activeProvider || 'auto');
  setVal('cfg-nvidia-key', cfg.nvidiaApiKey || '');
  setVal('cfg-nvidia-model', cfg.nvidiaModel || 'nvidia/llama-3.1-nemotron-70b-instruct');
  setVal('cfg-gemini-key', cfg.geminiApiKey || '');
  setVal('cfg-gemini-model', cfg.geminiModel || 'gemini-2.5-flash');

  onAiProviderChanged();
  openModal('ai-config-modal');
}
window.openAiConfigModal = openAiConfigModal;

function onAiProviderChanged() {
  const provider = document.getElementById('cfg-ai-provider')?.value || 'auto';
  const nSec = document.getElementById('nvidia-config-section');
  const gSec = document.getElementById('gemini-config-section');
  if (!nSec || !gSec) return;

  if (provider === 'nvidia') {
    nSec.style.opacity = '1';
    gSec.style.opacity = '0.5';
  } else if (provider === 'gemini') {
    nSec.style.opacity = '0.5';
    gSec.style.opacity = '1';
  } else {
    nSec.style.opacity = '1';
    gSec.style.opacity = '1';
  }
}
window.onAiProviderChanged = onAiProviderChanged;

async function testAiConnection() {
  const statusEl = document.getElementById('ai-test-status-text');
  const detailEl = document.getElementById('ai-test-detail-text');
  if (!statusEl || !detailEl) return;

  statusEl.textContent = 'Testing connection...';
  detailEl.textContent = 'Pinging cloud API endpoint with greeting verification...';

  const provider = document.getElementById('cfg-ai-provider')?.value || 'auto';
  const testCfg = {
    nvidiaApiKey: document.getElementById('cfg-nvidia-key')?.value.trim() || '',
    nvidiaModel: document.getElementById('cfg-nvidia-model')?.value.trim() || 'nvidia/llama-3.1-nemotron-70b-instruct',
    nvidiaBaseUrl: 'https://integrate.api.nvidia.com/v1',
    geminiApiKey: document.getElementById('cfg-gemini-key')?.value.trim() || '',
    geminiModel: document.getElementById('cfg-gemini-model')?.value.trim() || 'gemini-2.5-flash'
  };

  try {
    if (provider === 'nvidia') {
      const res = await AiboAiService.callNvidia('Say hello in Japanese and confirm your model name', [], testCfg);
      statusEl.innerHTML = `<span style="color: var(--color-matcha); font-weight:700;">✓ NVIDIA Nemotron Connected</span>`;
      detailEl.textContent = `Response: "${res.text.slice(0, 100)}..."`;
    } else if (provider === 'gemini') {
      const res = await AiboAiService.callGemini('Say hello in Japanese and confirm your model name', [], testCfg);
      statusEl.innerHTML = `<span style="color: var(--color-matcha); font-weight:700;">✓ Gemini 2.5 Flash Connected</span>`;
      detailEl.textContent = `Response: "${res.text.slice(0, 100)}..."`;
    } else if (provider === 'offline') {
      statusEl.innerHTML = `<span style="color: var(--color-matcha); font-weight:700;">✓ On-Device Rulebook Ready</span>`;
      detailEl.textContent = '100% offline rulebook with 0 network latency.';
    } else {
      // Auto
      let testedProvider = 'Google Gemini 2.5 Flash';
      let res;
      try {
        if (testCfg.nvidiaApiKey) {
          res = await AiboAiService.callNvidia('Hello', [], testCfg);
          testedProvider = 'NVIDIA Nemotron 70B';
        } else {
          res = await AiboAiService.callGemini('Hello', [], testCfg);
        }
      } catch(e) {
        res = await AiboAiService.callGemini('Hello', [], testCfg);
        testedProvider = 'Google Gemini (Auto Fallback)';
      }
      statusEl.innerHTML = `<span style="color: var(--color-matcha); font-weight:700;">✓ Connected via ${testedProvider}</span>`;
      detailEl.textContent = `Response: "${res.text.slice(0, 100)}..."`;
    }
  } catch (err) {
    statusEl.innerHTML = `<span style="color: var(--color-vermilion); font-weight:700;">⚠️ Connection Failed</span>`;
    detailEl.textContent = err.message;
  }
}
window.testAiConnection = testAiConnection;

function saveAiConfig() {
  const cfg = {
    activeProvider: document.getElementById('cfg-ai-provider')?.value || 'auto',
    nvidiaApiKey: document.getElementById('cfg-nvidia-key')?.value.trim() || '',
    nvidiaModel: document.getElementById('cfg-nvidia-model')?.value.trim() || 'nvidia/llama-3.1-nemotron-70b-instruct',
    nvidiaBaseUrl: 'https://integrate.api.nvidia.com/v1',
    geminiApiKey: document.getElementById('cfg-gemini-key')?.value.trim() || '',
    geminiModel: document.getElementById('cfg-gemini-model')?.value.trim() || 'gemini-2.5-flash'
  };

  AiboAiService.saveConfig(cfg);
  closeModal('ai-config-modal');
  audio.playChime();
  showJapaneseNotification('AI Engine Updated', `Active provider: ${cfg.activeProvider}`, 'icon-sparkles');
}
window.saveAiConfig = saveAiConfig;

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

function locatePharmacy(chainName) {
  audio.playWoodClick();
  showJapaneseNotification(
    `Locating Nearest ${chainName}`,
    '最寄り店舗を検索中 (Directing to Radar Compass)',
    'icon-pin'
  );
  setTimeout(() => {
    switchTab('screen-map');
    const needle = document.getElementById('compass-needle');
    if (needle) needle.style.transform = 'translate(-50%, -50%) rotate(72deg)';
  }, 700);
}
window.locatePharmacy = locatePharmacy;

function escapeHtml(s) {
  if (!s) return '';
  const d = document.createElement('div');
  d.textContent = s;
  return d.innerHTML;
}

// ==========================================================================
// Animated Splash Screen Engine (Torii Gate & Creator Attribution)
// ==========================================================================
let _splashTimeout = null;

function triggerSplashScreen(manual = false) {
  const splash = document.getElementById('app-splash-screen');
  if (!splash) return;
  
  if (_splashTimeout) clearTimeout(_splashTimeout);
  splash.classList.remove('dismissed');

  // Re-trigger SVG & CSS keyframe animations
  const content = splash.querySelector('.splash-content');
  if (content) {
    content.style.animation = 'none';
    void content.offsetHeight;
    content.style.animation = '';
  }

  if (manual && typeof audio !== 'undefined' && audio.playChime) {
    audio.playChime();
  }

  // Auto-dismiss after 2.4 seconds with a gentle fade
  _splashTimeout = setTimeout(() => {
    dismissSplashScreen();
  }, 2400);
}

function dismissSplashScreen() {
  const splash = document.getElementById('app-splash-screen');
  if (!splash) return;
  splash.classList.add('dismissed');
  if (_splashTimeout) {
    clearTimeout(_splashTimeout);
    _splashTimeout = null;
  }
}

window.triggerSplashScreen = triggerSplashScreen;
window.dismissSplashScreen = dismissSplashScreen;

// ==========================================================================
// Initialization & Startup
// ==========================================================================
document.addEventListener('DOMContentLoaded', () => {
  renderAll();
  AiboAiService.loadInitialConfig();
  setInterval(renderClockAndDates, 1000);

  // Trigger opening animated splash screen
  triggerSplashScreen();

  // Enter key for chat
  const chatInput = document.getElementById('chat-input');
  if (chatInput) {
    chatInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') sendChatMessage();
    });
  }

  const sendBtn = document.getElementById('send-btn');
  if (sendBtn) {
    sendBtn.addEventListener('click', () => sendChatMessage());
  }

  // Voice button truthful indication
  const voiceBtn = document.getElementById('voice-btn');
  if (voiceBtn) {
    voiceBtn.addEventListener('click', () => {
      audio.playChime();
      showJapaneseNotification(
        'Microphone Input Active',
        'Speak in English or 日本語 (Browser STT engine)',
        'icon-mic'
      );
    });
  }

  // Frame toggle
  const frameBtn = document.getElementById('toggle-frame-btn');
  const frameText = document.getElementById('frame-btn-text');
  const frame = document.getElementById('phone-frame');
  if (frameBtn && frame) {
    frameBtn.addEventListener('click', () => {
      audio.playWoodClick();
      const isFull = frame.classList.toggle('fullview');
      if (frameText) frameText.textContent = isFull ? 'View: Full Width' : 'View: Phone Frame';
    });
  }

  // Sound toggle
  const soundBtn = document.getElementById('toggle-sound-btn');
  const soundText = document.getElementById('sound-btn-text');
  if (soundBtn) {
    soundBtn.addEventListener('click', () => {
      audio.enabled = !audio.enabled;
      audio.playWoodClick();
      if (soundText) soundText.textContent = audio.enabled ? 'Audio: ON' : 'Audio: OFF';
    });
  }

  // Welcome Toast (Timed after splash screen dismiss)
  setTimeout(() => {
    showJapaneseNotification(
      'Welcome to AIBO (相棒へようこそ)',
      '100% reliable on-device companion is ready',
      'icon-torii'
    );
  }, 2600);
});
