// ===== SCROLL PROGRESS BAR =====
const progressBar = document.getElementById('scroll-progress');
window.addEventListener('scroll', () => {
  const scrolled = window.scrollY;
  const total = document.documentElement.scrollHeight - window.innerHeight;
  progressBar.style.width = (scrolled / total * 100) + '%';
}, { passive: true });

// ===== NAVBAR =====
const navbar = document.getElementById('navbar');
window.addEventListener('scroll', () => {
  navbar.classList.toggle('scrolled', window.scrollY > 60);
  updateActiveNav();
}, { passive: true });

// Mobile nav toggle
const navToggle = document.getElementById('navToggle');
const navLinks  = document.getElementById('navLinks');
navToggle.addEventListener('click', () => {
  const isOpen = navLinks.classList.toggle('open');
  navToggle.classList.toggle('open');
  navToggle.setAttribute('aria-expanded', isOpen);
});
navLinks.querySelectorAll('a').forEach(a => {
  a.addEventListener('click', () => {
    navLinks.classList.remove('open');
    navToggle.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
  });
});

// Active nav link on scroll
function updateActiveNav() {
  const sections = document.querySelectorAll('section[id]');
  const navItems = document.querySelectorAll('.nav-links a');
  let current = '';
  sections.forEach(section => {
    if (window.scrollY >= section.offsetTop - 130) {
      current = section.getAttribute('id');
    }
  });
  navItems.forEach(a => {
    a.classList.toggle('active', a.getAttribute('href') === '#' + current);
  });
}

// ===== TYPING ANIMATION =====
const roles = [
  'Senior Web Engineer',
  'Laravel Developer',
  'Full-Stack Engineer',
  'API Integration Expert',
  'AI-Powered Developer',
];
let roleIdx = 0, charIdx = 0, typing = true;
const typingEl = document.getElementById('typingText');

function typeStep() {
  if (!typingEl) return;
  const target = roles[roleIdx];
  if (typing) {
    typingEl.textContent = target.slice(0, ++charIdx);
    if (charIdx === target.length) {
      typing = false;
      setTimeout(typeStep, 2200);
    } else {
      setTimeout(typeStep, 72);
    }
  } else {
    typingEl.textContent = target.slice(0, --charIdx);
    if (charIdx === 0) {
      typing = true;
      roleIdx = (roleIdx + 1) % roles.length;
      setTimeout(typeStep, 300);
    } else {
      setTimeout(typeStep, 38);
    }
  }
}
setTimeout(typeStep, 1200);

// ===== FADE-UP ANIMATIONS =====
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.fade-up').forEach(el => observer.observe(el));

// ===== ANIMATED COUNTERS =====
const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.querySelectorAll('.count-num[data-count]').forEach(el => {
        animateCount(el);
      });
      counterObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.3 });

document.querySelectorAll('.about-counters').forEach(el => counterObserver.observe(el));

function animateCount(el) {
  const target = parseInt(el.dataset.count, 10);
  const duration = 1400;
  const start = performance.now();
  function step(now) {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    el.textContent = Math.floor(eased * target);
    if (progress < 1) requestAnimationFrame(step);
    else el.textContent = target;
  }
  requestAnimationFrame(step);
}

// ===== IMAGE FALLBACKS =====
const avatarImg = document.getElementById('heroAvatarImg');
if (avatarImg) {
  avatarImg.addEventListener('error', () => { avatarImg.style.display = 'none'; });
}

const aboutImg = document.getElementById('aboutImg');
if (aboutImg) {
  aboutImg.addEventListener('error', () => {
    aboutImg.style.display = 'none';
    const ph = document.getElementById('aboutImgPlaceholder');
    if (ph) ph.style.display = 'flex';
  });
}

// ===== PARTICLES =====
(function spawnParticles() {
  const container = document.getElementById('particles');
  if (!container) return;
  for (let i = 0; i < 24; i++) {
    const p = document.createElement('div');
    p.className = 'particle';
    p.style.left = Math.random() * 100 + '%';
    const size = (Math.random() * 2.5 + 1) + 'px';
    p.style.width = size;
    p.style.height = size;
    p.style.animationDelay    = (Math.random() * 10) + 's';
    p.style.animationDuration = (Math.random() * 6 + 6) + 's';
    container.appendChild(p);
  }
})();
