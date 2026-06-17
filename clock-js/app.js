// ============================================
// 🌬️ Timer - Амьсгалын дасгал
// JavaScript - бүх логик
// ============================================

// ---------- ТӨЛӨВ ----------
let state = {
  // Тохиргоо
  cycleCount: 3,
  finishMinutes: 5,

  // Циклүүд
  cycles: [],           // [{name, duration}, ...]
  currentCycleIndex: 0, // Одоо засварлаж буй цикл

  // Дасгал
  isRunning: false,
  currentPhase: 'idle', // idle | speaking | counting
  phaseSecondsLeft: 0,
  totalTimeRemaining: 0,
  currentCycleNum: 0,

  // Таймерууд
  phaseTimer: null,
  mainTimer: null,
};

// ---------- DOM ЭЛЕМЕНТҮҮД ----------
const $ = (id) => document.getElementById(id);

// ---------- АЛХАМ ШИЛЖҮҮЛЭХ ----------
function showStep(stepNum) {
  document.querySelectorAll('.step').forEach(el => el.classList.remove('active'));
  $(`step${stepNum}`).classList.add('active');
}

// ---------- АЛХАМ 1: ЭХЛЭЛ ТОХИРГОО ----------
function changeValue(id, delta) {
  const input = $(id);
  let val = parseInt(input.value) + delta;
  val = Math.max(parseInt(input.min), Math.min(parseInt(input.max), val));
  input.value = val;
}

function goToStep2() {
  state.cycleCount = parseInt($('cycleCount').value);
  state.finishMinutes = parseInt($('finishMinutes').value);

  if (state.cycleCount < 1) { alert('Циклийн тоо хамгийн багадаа 1 байх ёстой'); return; }
  if (state.finishMinutes < 1) { alert('Дуусах хугацаа хамгийн багадаа 1 минут байх ёстой'); return; }

  // Циклүүдийг үүсгэх
  state.cycles = [];
  for (let i = 0; i < state.cycleCount; i++) {
    state.cycles.push({ name: `Цикл ${i + 1}`, duration: 5 });
  }
  state.currentCycleIndex = 0;

  renderCycleSetup();
  showStep(2);
}

// ---------- АЛХАМ 2: ЦИКЛ ТОХИРУУЛАХ ----------
function renderCycleSetup() {
  // Хуудас заагч
  const indicator = $('pageIndicator');
  indicator.innerHTML = '';
  for (let i = 0; i < state.cycles.length; i++) {
    const dot = document.createElement('div');
    dot.className = 'page-dot' + (i === state.currentCycleIndex ? ' active' : '');
    indicator.appendChild(dot);
  }

  // Циклийн карт
  const cycle = state.cycles[state.currentCycleIndex];
  $('cycleNumber').textContent = state.currentCycleIndex + 1;
  $('cycleName').value = cycle.name;
  $('cycleDuration').value = cycle.duration;

  // Товчнууд
  $('prevBtn').style.display = state.currentCycleIndex > 0 ? 'block' : 'none';
  $('nextBtn').textContent = state.currentCycleIndex < state.cycles.length - 1 ? 'Дараах →' : '▶ Эхлэх';
}

function saveCurrentCycle() {
  state.cycles[state.currentCycleIndex].name = $('cycleName').value.trim() || `Цикл ${state.currentCycleIndex + 1}`;
  state.cycles[state.currentCycleIndex].duration = parseInt($('cycleDuration').value) || 5;
}

function changeCycleDuration(delta) {
  const input = $('cycleDuration');
  let val = parseInt(input.value) + delta;
  val = Math.max(1, Math.min(600, val));
  input.value = val;
}

function prevCycle() {
  saveCurrentCycle();
  state.currentCycleIndex--;
  renderCycleSetup();
}

function nextCycle() {
  saveCurrentCycle();

  if (state.currentCycleIndex < state.cycles.length - 1) {
    state.currentCycleIndex++;
    renderCycleSetup();
  } else {
    // Бүх цикл бэлэн - дасгал эхлүүлэх
    startBreathing();
  }
}

// ---------- АЛХАМ 3: ДАСГАЛ ----------
function startBreathing() {
  state.totalTimeRemaining = state.finishMinutes * 60;
  state.currentCycleNum = 0;
  state.currentCycleIndex = 0;
  state.isRunning = false;

  // Циклийн жагсаалт харуулах
  renderCycleList();

  showStep(3);
  updateDisplay();
}

function renderCycleList() {
  const list = $('cycleList');
  list.innerHTML = '<h4>📋 Циклүүд</h4>';
  state.cycles.forEach((cycle, i) => {
    const item = document.createElement('div');
    item.className = 'cycle-item';
    item.innerHTML = `
      <div class="cycle-index">${i + 1}</div>
      <span class="cycle-name">${cycle.name}</span>
      <span class="cycle-duration">${cycle.duration}с</span>
    `;
    list.appendChild(item);
  });
}

function toggleBreathing() {
  if (state.isRunning) {
    stopBreathing();
  } else {
    beginBreathing();
  }
}

async function beginBreathing() {
  if (state.isRunning) return;

  state.isRunning = true;
  state.currentCycleIndex = 0;
  state.currentCycleNum = 0;
  state.totalTimeRemaining = state.finishMinutes * 60;

  $('startBtn').textContent = '⏹ Зогсоох';
  $('startBtn').classList.add('running');

  // Нийт хугацааны таймер
  state.mainTimer = setInterval(() => {
    if (state.totalTimeRemaining > 0) {
      state.totalTimeRemaining--;
      updateDisplay();
    }
  }, 1000);

  // Циклүүдийг ажиллуулах
  while (state.isRunning) {
    if (state.totalTimeRemaining <= 0) break;

    const cycle = state.cycles[state.currentCycleIndex];
    state.currentCycleNum = state.currentCycleIndex + 1;

    // 1. Циклийн нэр харуулах
    setPhase('speaking', 0);
    $('phaseBadge').textContent = `🔄 ${cycle.name}`;
    await delay(1000);
    if (!state.isRunning) break;

    // 2. Секунд тоолох
    await startCountPhase(cycle.duration);
    if (!state.isRunning) break;

    // 3. Дараагийн цикл
    state.currentCycleIndex = (state.currentCycleIndex + 1) % state.cycles.length;
  }

  stopBreathing(true);
}

function startCountPhase(duration) {
  return new Promise((resolve) => {
    setPhase('counting', duration);
    playBeep();

    let remaining = duration;
    state.phaseTimer = setInterval(() => {
      remaining--;
      state.phaseSecondsLeft = remaining;
      updateDisplay();

      if (remaining <= 0) {
        clearInterval(state.phaseTimer);
        state.phaseTimer = null;
        playBeepEnd();
        resolve();
      }
    }, 1000);
  });
}

function setPhase(phase, seconds) {
  state.currentPhase = phase;
  state.phaseSecondsLeft = seconds;

  const circle = $('circle');
  circle.className = 'circle';
  if (phase === 'speaking') circle.classList.add('speaking');
  if (phase === 'counting') circle.classList.add('counting');

  updateDisplay();
}

function stopBreathing(completed = false) {
  if (state.phaseTimer) { clearInterval(state.phaseTimer); state.phaseTimer = null; }
  if (state.mainTimer) { clearInterval(state.mainTimer); state.mainTimer = null; }

  state.isRunning = false;
  if (completed) {
    state.currentPhase = 'idle';
    playBeepComplete();
  }

  $('startBtn').textContent = '▶ Эхлэх';
  $('startBtn').classList.remove('running');
  $('circle').className = 'circle';
  updateDisplay();
}

function resetToStep1() {
  stopBreathing();
  showStep(1);
}

// ---------- ДЭЛГЭЦ ШИНЭЧЛЭХ ----------
function updateDisplay() {
  // Фазын текст
  const phaseTexts = {
    'speaking': '🎙️ Цикл зарлаж байна...',
    'counting': '⏱️ Тоолж байна...',
    'idle': state.isRunning ? '' : 'Бэлэн',
  };
  $('phaseText').textContent = phaseTexts[state.currentPhase] || '';

  // Секунд
  $('secondsDisplay').textContent = state.phaseSecondsLeft > 0 ? state.phaseSecondsLeft : '';

  // Прогресс бар
  const progress = state.finishMinutes > 0
    ? ((state.finishMinutes * 60 - state.totalTimeRemaining) / (state.finishMinutes * 60)) * 100
    : 0;
  $('progressFill').style.width = `${Math.min(progress, 100)}%`;

  // Статистик
  $('cycleStats').textContent = `Цикл: ${state.currentCycleNum} / ${state.cycles.length}`;
  const mins = Math.floor(state.totalTimeRemaining / 60);
  const secs = state.totalTimeRemaining % 60;
  $('timeStats').textContent = `Үлдсэн: ${mins}:${secs.toString().padStart(2, '0')}`;
}

// ---------- ТУСЛАХ ФУНКЦУУД ----------
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// ---------- ДУУ (Web Audio API) ----------
let audioCtx = null;

function getAudioContext() {
  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
  return audioCtx;
}

function playBeep() {
  try {
    const ctx = getAudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.frequency.value = 800;
    gain.gain.value = 0.3;
    osc.start();
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.15);
    osc.stop(ctx.currentTime + 0.15);
  } catch (e) {
    console.log('Audio not available');
  }
}

function playBeepEnd() {
  try {
    const ctx = getAudioContext();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.frequency.value = 600;
    gain.gain.value = 0.3;
    osc.start();
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.3);
    osc.stop(ctx.currentTime + 0.3);
  } catch (e) {
    console.log('Audio not available');
  }
}

function playBeepComplete() {
  // Гурван удаа дуугаргах
  for (let i = 0; i < 3; i++) {
    setTimeout(() => {
      try {
        const ctx = getAudioContext();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.frequency.value = 1000;
        gain.gain.value = 0.3;
        osc.start();
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
        osc.stop(ctx.currentTime + 0.2);
      } catch (e) {}
    }, i * 300);
  }
}
