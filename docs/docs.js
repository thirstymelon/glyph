/* Glyph Documentation Engine */

const IDX = [
  ["Overview", "index.html", "Page"],
  ["Getting started", "getting-started.html", "Page"],
  ["Beginner Tutorials", "tutorials/index.html", "Page"],
  ["Beginner Guide", "tutorials/beginner-guide.html", "Guide"],
  ["Developer Architecture", "developer-overview.html", "Architecture"],
  ["API Reference", "reference.html", "Reference"],
  ["First Program (SSD1306)", "index.html#first-program", "Overview"],
  ["Key Pillars", "index.html#pillars", "Overview"],
  ["Installation", "getting-started.html#install", "Getting started"],
  ["Project Setup", "getting-started.html#project-setup", "Getting started"],
  ["Building for RP2040", "getting-started.html#rp2040-example", "Getting started"],
  ["Lesson 1: SSD1306 Display Init", "tutorials/beginner-guide.html#l1", "Tutorials"],
  ["Lesson 2: Pixels & Out-of-Bounds Safety", "tutorials/beginner-guide.html#l2", "Tutorials"],
  ["Lesson 3: Lines & Bresenham", "tutorials/beginner-guide.html#l3", "Tutorials"],
  ["Lesson 4: Rectangles & Frames", "tutorials/beginner-guide.html#l4", "Tutorials"],
  ["Lesson 5: Circles & Gauges", "tutorials/beginner-guide.html#l5", "Tutorials"],
  ["Lesson 6: ILI9341 SPI Color TFT", "tutorials/beginner-guide.html#l6", "Tutorials"],
  ["Lesson 7: Color Shapes & Triangles", "tutorials/beginner-guide.html#l7", "Tutorials"],
  ["Lesson 8: Text & Font Overrides", "tutorials/beginner-guide.html#l8", "Tutorials"],
  ["Lesson 9: RP2040 Hardware Timer Loop", "tutorials/beginner-guide.html#l9", "Tutorials"],
  ["Layered Architecture", "developer-overview.html#architecture", "Developer"],
  ["Rendering Pipeline", "developer-overview.html#pipeline", "Developer"],
  ["Memory Model & Zero Heap", "developer-overview.html#memory-model", "Developer"],
  ["Package Responsibilities", "developer-overview.html#packages", "Developer"],
  ["SSD1306 & ILI9341 Display Drivers", "developer-overview.html#controllers", "Developer"],
  ["RP2040 Hardware Integration", "developer-overview.html#rp2040-hardware", "Developer"],
  ["Transparent Banding (Tile Streaming)", "developer-overview.html#banding", "Developer"],
  ["Hidden Damage Tracking", "developer-overview.html#damage-tracking", "Developer"],
  ["Desktop Simulator Engine", "developer-overview.html#simulator", "Developer"],
  ["SSD1306 API", "reference.html#ssd1306", "Reference"],
  ["ILI9341 API", "reference.html#ili9341", "Reference"],
  ["Colors & Math Utilities", "reference.html#colors", "Reference"],
  ["Types Reference", "reference.html#types", "Reference"]
];

const $ = s => document.querySelector(s);
const $$ = s => [...document.querySelectorAll(s)];
const R = document.body.dataset.r || "";

const ADA_RE = /(--[^\n]*)|("(?:[^"\\]|\\.)*"|'[^'\n]*')|\b(16#[0-9a-fA-F_]+#|0x[0-9a-fA-F_]+|\d[\d_]*(?:\.\d+)?)\b|\b(with|use|procedure|function|is|begin|end|package|renames|type|subtype|record|null|if|then|else|elsif|loop|while|for|in|reverse|case|when|return|constant|out|aliased|access|body|new|generic|range|others|array|of|mod|and|or|not|xor)\b|\b(True|False|Positive|Natural|Integer|Float|Character|String|Boolean|UInt8|UInt16|UInt32|RGB565|Point|Line|Rectangle|Circle|Triangle|Font|Display_T|Framebuffer|Tile_Stream|Direct_Stream)\b|([A-Za-z_][A-Za-z0-9_]*)(?=\s*\()|(:=|=>|\.\.|\/=|=|<=|>=|\+|-|\*|\/)/g;
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

$$('pre').forEach(p => {
  const c = p.querySelector('code');
  if (!c) return;
  const raw = c.textContent;
  const isSh = p.classList.contains('sh');
  const isRaw = p.classList.contains('raw');
  let title = 'main.adb';

  const m = raw.match(/\b(?:procedure|package(?:\s+body)?)\s+([A-Za-z0-9_\.]+)/);
  if (m) {
    const parts = m[1].split('.');
    const name = parts[parts.length - 1].toLowerCase();
    title = raw.includes('package body') || raw.includes('procedure') ? name + '.adb' : name + '.ads';
  } else if (isSh) {
    title = 'Terminal — zsh';
  } else if (isRaw) {
    title = 'config.toml';
  } else if (raw.includes('project') || raw.includes('alire.toml')) {
    title = 'alire.toml';
  }

  if (!isSh && !isRaw) {
    const hl = esc(raw).replace(ADA_RE, (match, cm, st, nu, kw, ty, fn, op) =>
      cm ? `<span class="c">${cm}</span>` :
      st ? `<span class="s">${st}</span>` :
      nu ? `<span class="n">${nu}</span>` :
      kw ? `<span class="k">${kw}</span>` :
      ty ? `<span class="t">${ty}</span>` :
      fn ? `<span class="f">${fn}</span>` :
      op ? `<span class="o">${op}</span>` : match
    );
    const lines = hl.split('\n');
    c.innerHTML = lines.map(l => `<span class="line">${l || ' '}</span>`).join('');
  } else if (isSh) {
    c.innerHTML = esc(raw).replace(/(#[^\n]*)|("(?:[^"\\]|\\.)*")|(--?[a-zA-Z0-9_-]+)|\b(alr|gprbuild|git|cd|elf2uf2-rs|cp|mkdir|rm)\b|\b(build|run|exec|with|init)\b/g, (match, cm, st, fl, cmd, sc) =>
      cm ? `<span class="c">${cm}</span>` :
      st ? `<span class="s">${st}</span>` :
      fl ? `<span class="flg">${fl}</span>` :
      cmd ? `<span class="cmd">${cmd}</span>` :
      sc ? `<span class="sc">${sc}</span>` : match
    );
  }

  const bar = document.createElement('div');
  bar.className = 'mac-bar';
  bar.innerHTML = `<div class="mac-dots"><span class="mac-dot r"></span><span class="mac-dot y"></span><span class="mac-dot g"></span></div><div class="mac-title">${title}</div><button class="cb" type="button">Copy</button>`;
  const btn = bar.querySelector('.cb');
  btn.onclick = () => navigator.clipboard.writeText(raw).then(() => {
    btn.textContent = 'Copied';
    setTimeout(() => btn.textContent = 'Copy', 1200);
  });
  p.prepend(bar);
});

// Auto-generate Sticky Table of Contents
const tocEl = $('#toc');
if (tocEl) {
  const hs = $$('article h2');
  if (hs.length > 1) {
    tocEl.innerHTML = '<b>ON THIS PAGE</b>' + hs.map(h => `<a href="#${h.id}">${h.textContent}</a>`).join('');
    const o = new IntersectionObserver(e => e.forEach(x => {
      if (x.isIntersecting) {
        $$('#toc a').forEach(a => a.classList.toggle('on', a.hash === '#' + x.target.id));
      }
    }), { rootMargin: '-20% 0px -70% 0px' });
    hs.forEach(h => o.observe(h));
  }
}

// Mobile Menu
const mbBtn = $('#mb');
if (mbBtn) {
  mbBtn.onclick = () => document.body.classList.toggle('open');
}

// Search Palette Modal
const P = $('#pal'), pi = $('#pi'), pl = $('#pl'), sk = $('#sk');
if (P && pi && pl) {
  let cur = [], sel = 0;
  const pr = () => {
    const q = pi.value.toLowerCase();
    cur = IDX.filter(i => (i[0] + ' ' + i[2]).toLowerCase().includes(q)).slice(0, 9);
    sel = Math.min(sel, Math.max(cur.length - 1, 0));
    pl.innerHTML = cur.map((c, i) => `<a href="${R + c[1]}" class="${i === sel ? 'on' : ''}">${c[0]}<small>${c[2]}</small></a>`).join('');
  };
  const op = v => {
    P.classList.toggle('on', v);
    if (v) { pi.value = ''; sel = 0; pr(); pi.focus(); }
  };
  if (sk) sk.onclick = () => op(true);
  P.onclick = e => e.target === P && op(false);
  pi.oninput = () => { sel = 0; pr(); };

  addEventListener('keydown', e => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      op(true);
    } else if (e.key === 'Escape') {
      op(false);
    } else if (P.classList.contains('on')) {
      if (e.key === 'ArrowDown') {
        sel = Math.min(sel + 1, cur.length - 1);
        pr();
      } else if (e.key === 'ArrowUp') {
        sel = Math.max(sel - 1, 0);
        pr();
      } else if (e.key === 'Enter' && cur[sel]) {
        location.href = R + cur[sel][1];
      }
    }
  });
}

// Lesson Complete Tracker
const ds = $$('.done');
if (ds.length) {
  let S = {};
  try { S = JSON.parse(localStorage.glyphDone || '{}'); } catch (e) {}
  const up = () => {
    const n = ds.filter(d => d.classList.contains('on')).length;
    const pc = $('#pc'), pb = $('#pb');
    if (pc) pc.textContent = n + ' / ' + ds.length + ' lessons complete';
    if (pb) pb.style.width = (n / ds.length * 100) + '%';
    try { localStorage.glyphDone = JSON.stringify(S); } catch (e) {}
  };
  ds.forEach((d, i) => {
    d.classList.toggle('on', !!S[i]);
    d.textContent = S[i] ? '✓ Completed' : 'Mark complete';
    d.onclick = () => {
      S[i] = !S[i];
      d.classList.toggle('on', S[i]);
      d.textContent = S[i] ? '✓ Completed' : 'Mark complete';
      up();
    };
  });
  up();
}
