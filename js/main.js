/* ============================================================
   ROUNDS ACADEMY — Main JavaScript
============================================================ */

(function () {
  'use strict';

  /* ── Navbar scroll ──────────────────────────────────────── */
  const navbar = document.getElementById('navbar');
  if (navbar) {
    const onScroll = () => {
      navbar.classList.toggle('scrolled', window.scrollY > 50);
    };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll(); // run once on load
  }

  /* ── Mobile menu ────────────────────────────────────────── */
  const toggle   = document.getElementById('nav-toggle');
  const mobileMenu = document.getElementById('mobile-menu');
  if (toggle && mobileMenu) {
    toggle.addEventListener('click', () => {
      const isOpen = mobileMenu.classList.toggle('open');
      toggle.classList.toggle('open', isOpen);
      document.body.style.overflow = isOpen ? 'hidden' : '';
    });
    // close on link click
    mobileMenu.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        mobileMenu.classList.remove('open');
        toggle.classList.remove('open');
        document.body.style.overflow = '';
      });
    });
  }

  /* ── Scroll reveal (IntersectionObserver) ───────────────── */
  const revealEls = document.querySelectorAll('.reveal, .reveal-left, .reveal-right');
  if (revealEls.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.1, rootMargin: '0px 0px -36px 0px' });
    revealEls.forEach(el => io.observe(el));
  }

  /* ── Counter animation ──────────────────────────────────── */
  function animateCount(el) {
    const target   = +el.dataset.count;
    const suffix   = el.dataset.suffix || '';
    const duration = 1600;
    const start    = performance.now();
    const step = (now) => {
      const p = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      el.textContent = Math.floor(eased * target) + suffix;
      if (p < 1) requestAnimationFrame(step);
    };
    requestAnimationFrame(step);
  }

  const statItems = document.querySelectorAll('.stat-item');
  if (statItems.length) {
    const counterIO = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          const num = e.target.querySelector('.stat-number[data-count]');
          if (num) animateCount(num);
          counterIO.unobserve(e.target);
        }
      });
    }, { threshold: 0.5 });
    statItems.forEach(el => counterIO.observe(el));
  }

  /* ── Contact form ───────────────────────────────────────── */
  const form = document.querySelector('.contact-form');
  if (form) {
    form.addEventListener('submit', async function (e) {
      e.preventDefault();

      /* validate every required field */
      const required = this.querySelectorAll('[required]');
      let valid = true;
      required.forEach(field => {
        field.classList.remove('field-error');
        if (!field.value.trim()) {
          field.classList.add('field-error');
          field.addEventListener('input', () => field.classList.remove('field-error'), { once: true });
          valid = false;
        }
      });
      if (!valid) return;

      const btn       = this.querySelector('[type="submit"]');
      const successEl = this.querySelector('.form-success');
      const origText  = btn.textContent;
      btn.textContent = '...';
      btn.disabled    = true;

      try {
        const res = await fetch(this.action, {
          method:  'POST',
          body:    new FormData(this),
          headers: { 'Accept': 'application/json' }
        });
        if (res.ok) {
          this.reset();
          btn.style.display = 'none';
          if (successEl) successEl.style.display = 'block';
        } else {
          throw new Error('server error');
        }
      } catch (_) {
        btn.textContent = origText;
        btn.disabled    = false;
      }
    });
  }

  /* ── Back to top ────────────────────────────────────────── */
  const backTop = document.getElementById('back-top');
  if (backTop) {
    window.addEventListener('scroll', () => {
      backTop.classList.toggle('visible', window.scrollY > 400);
    }, { passive: true });
    backTop.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
  }

  /* ── Active nav link ────────────────────────────────────── */
  const path = window.location.pathname.replace(/\/$/, '') || '/';
  document.querySelectorAll('.nav-links a, .mobile-menu a').forEach(a => {
    const href = a.getAttribute('href') || '';
    // exact or trailing match
    if (href && (path.endsWith(href) || path.endsWith(href.replace(/^\.\.\//, '')))) {
      a.classList.add('active');
    }
  });

  /* ── Videos: autoplay on scroll, pause when out of view ────── */
  const videos = document.querySelectorAll('video');
  if (videos.length) {
    videos.forEach(v => {
      v.muted      = true;   // required by browsers for autoplay
      v.controls   = true;
      v.playsInline = true;
      v.preload    = 'none'; // don't fetch until actually visible
    });

    const videoIO = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.play().catch(() => {});
        } else {
          e.target.pause();
        }
      });
    }, { threshold: 0.4 }); // play when 40% of the video is visible

    videos.forEach(v => videoIO.observe(v));
  }

  /* ── About "Ler mais" toggle ────────────────────────────── */
  /* ── About "Ler mais" toggle ────────────────────────────── */
  const aboutBtn     = document.getElementById('about-more-btn');
  const aboutContent = document.getElementById('about-more-content');
  if (aboutBtn && aboutContent) {
    aboutBtn.addEventListener('click', function () {
      const isOpen = aboutContent.classList.toggle('open');
      aboutBtn.classList.toggle('open', isOpen);
      aboutBtn.textContent = isOpen ? 'Ler menos' : 'Ler mais';
    });
  }

  /* ── Schedule day tabs (mobile) ─────────────────────────── */
  const schedTabs = document.querySelectorAll('.sched-tab');
  if (schedTabs.length) {
    const todayIdx = (new Date().getDay() + 6) % 7;
    schedTabs.forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.sched-day-panel').forEach(p => p.classList.remove('active'));
    const todayTab   = document.querySelector('.sched-tab[data-day="'   + todayIdx + '"]');
    const todayPanel = document.querySelector('.sched-day-panel[data-day="' + todayIdx + '"]');
    if (todayTab)   { todayTab.classList.add('active', 'today'); }
    if (todayPanel) { todayPanel.classList.add('active'); }

    schedTabs.forEach(tab => {
      tab.addEventListener('click', function () {
        schedTabs.forEach(t => t.classList.remove('active'));
        document.querySelectorAll('.sched-day-panel').forEach(p => p.classList.remove('active'));
        this.classList.add('active');
        document.querySelector('.sched-day-panel[data-day="' + this.dataset.day + '"]').classList.add('active');
      });
    });
  }

})();
