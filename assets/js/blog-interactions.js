(function () {
  const config = window.blogConfig || {};

  function byId(id) {
    return document.getElementById(id);
  }

  function getCssVar(name) {
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
  }

  window.toggleTheme = function toggleTheme() {
    const currentTheme = document.body.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.body.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);

    const toggleBtn = document.querySelector('.theme-toggle');
    if (toggleBtn) {
      toggleBtn.textContent = newTheme === 'dark' ? '🌙' : '☀️';
    }
  };

  document.addEventListener('DOMContentLoaded', function () {
    initTheme();
    initScrollState();
    initSearch();
    initLightbox();
    initImageSlider();
    initCodeCopy();
    initToc();
    initRandomQuote();
    initRuntime();
    initFireworks();
  });

  function initTheme() {
    const savedTheme = localStorage.getItem('theme') || 'dark';
    document.body.setAttribute('data-theme', savedTheme);

    const toggleBtn = document.querySelector('.theme-toggle');
    if (toggleBtn) {
      toggleBtn.textContent = savedTheme === 'dark' ? '🌙' : '☀️';
      toggleBtn.addEventListener('click', window.toggleTheme);
    }
  }

  function initScrollState() {
    const readingProgress = byId('readingProgress');
    const backtop = document.querySelector('[data-backtop]');
    const backtopButton = document.querySelector('[data-backtop-button]');
    const scrollQuote = document.querySelector('[data-random-quote="scroll"]');
    let scrollTicking = false;

    function updateScrollState() {
      const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
      const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const progress = height > 0 ? Math.min(winScroll / height, 1) : 0;

      if (readingProgress) {
        readingProgress.style.transform = 'scaleX(' + progress + ')';
      }

      if (backtop) {
        backtop.classList.toggle('is-visible', winScroll > 400);
      }

      if (scrollQuote) {
        scrollQuote.classList.toggle('is-visible', winScroll > 120);
      }

      scrollTicking = false;
    }

    window.addEventListener('scroll', function () {
      if (scrollTicking) {
        return;
      }
      scrollTicking = true;
      requestAnimationFrame(updateScrollState);
    }, { passive: true });

    if (backtopButton) {
      backtopButton.addEventListener('click', function () {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      });
    }

    updateScrollState();
  }

  function initRandomQuote() {
    const targets = document.querySelectorAll('[data-random-quote]');
    if (!targets.length) {
      return;
    }

    const fallback = {
      text: '何时葡萄会熟透，你要静候再静候',
      meta: ''
    };

    function setQuote(quote) {
      targets.forEach(function (target) {
        const variant = target.getAttribute('data-random-quote');
        const textEl = target.matches('[data-random-quote]') && !target.querySelector('[data-random-quote-text]')
          ? target
          : target.querySelector('[data-random-quote-text]');
        const metaEl = target.querySelector('[data-random-quote-meta]');

        if (textEl) {
          if (variant === 'hero') {
            typeHeroQuote(textEl, quote.text);
          } else {
            textEl.textContent = '“' + quote.text + '”';
          }
        }

        if (metaEl) {
          metaEl.textContent = quote.meta || '';
          metaEl.toggleAttribute('hidden', !quote.meta);
        }
      });
    }

    function typeHeroQuote(element, text) {
      const value = String(text || '');
      const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      const token = String(Date.now()) + Math.random();
      element.dataset.typingToken = token;

      element.classList.remove('is-typing', 'is-typing-done');

      if (reduceMotion || !value) {
        element.textContent = value;
        element.classList.add('is-typing-done');
        return;
      }

      let index = 0;
      const speed = Math.max(96, Math.min(150, 2600 / Math.max(value.length, 1)));

      function tick() {
        if (element.dataset.typingToken !== token) {
          return;
        }

        index += 1;
        element.textContent = value.slice(0, index);

        if (index < value.length) {
          window.setTimeout(tick, speed);
        } else {
          window.setTimeout(function () {
            if (element.dataset.typingToken !== token) {
              return;
            }
            element.classList.remove('is-typing');
            element.classList.add('is-typing-done');
          }, 680);
        }
      }

      function startTyping() {
        if (element.dataset.typingToken !== token) {
          return;
        }
        element.textContent = '';
        element.classList.add('is-typing');
        tick();
      }

      if (document.readyState === 'complete') {
        window.setTimeout(startTyping, 900);
      } else {
        window.addEventListener('load', function () {
          window.setTimeout(startTyping, 900);
        }, { once: true });
      }
    }

    function normalizeJinrishici(data) {
      return {
        text: data && data.content ? String(data.content).trim() : '',
        meta: [data && data.author, data && data.origin].filter(Boolean).join(' · ')
      };
    }

    function normalizeHitokoto(data) {
      return {
        text: data && data.hitokoto ? String(data.hitokoto).trim() : '',
        meta: [data && data.from_who, data && data.from].filter(Boolean).join(' · ')
      };
    }

    function fetchQuote() {
      const apis = [
        {
          url: 'https://v1.jinrishici.com/all.json',
          normalize: normalizeJinrishici
        },
        {
          url: 'https://v1.hitokoto.cn/?c=d&c=i&c=k&c=f&encode=json&max_length=40',
          normalize: normalizeHitokoto
        }
      ];
      const api = apis[Math.floor(Math.random() * apis.length)];

      return fetch(api.url, { cache: 'no-store' })
        .then(function (response) {
          if (!response.ok) {
            throw new Error('Random quote request failed: ' + response.status);
          }
          return response.json();
        })
        .then(function (data) {
          const quote = api.normalize(data);
          if (!quote.text) {
            throw new Error('Random quote response is empty');
          }
          return quote;
        });
    }

    fetchQuote().then(setQuote).catch(function () {
      setQuote(fallback);
    });
  }

  function initSearch() {
    if (config.enableSearch === false) {
      return;
    }

    const input = byId('search-input');
    const resultsContainer = byId('search-results');
    const searchButton = document.querySelector('[data-search-button]');
    if (!input || !resultsContainer) {
      return;
    }

    let searchDataPromise = null;

    function loadSearchData() {
      if (!searchDataPromise) {
        searchDataPromise = fetch(config.searchIndexUrl || '/index.json')
          .then(function (response) {
            if (!response.ok) {
              throw new Error('Search index request failed: ' + response.status);
            }
            return response.json();
          })
          .catch(function () {
            return [];
          });
      }
      return searchDataPromise;
    }

    function renderResults(query, items) {
      const searchTerm = query.trim().toLowerCase();
      if (!searchTerm) {
        resultsContainer.innerHTML = '';
        return;
      }

      const results = items.filter(function (item) {
        const tags = Array.isArray(item.tags) ? item.tags : [];
        return String(item.title || '').toLowerCase().includes(searchTerm) ||
          String(item.content || '').toLowerCase().includes(searchTerm) ||
          tags.some(function (tag) { return String(tag).toLowerCase().includes(searchTerm); });
      }).slice(0, 12);

      if (!results.length) {
        resultsContainer.innerHTML = '<div class="blog-search-empty">没有找到相关内容</div>';
        return;
      }

      resultsContainer.innerHTML = results.map(function (item) {
        const tags = Array.isArray(item.tags) ? item.tags : [];
        const tagHtml = tags.length
          ? '<div class="blog-search-tags">' + tags.map(function (tag) {
              return '<span>' + escapeHtml(tag) + '</span>';
            }).join('') + '</div>'
          : '';

        return '<a class="blog-search-result" href="' + escapeAttr(item.url || '#') + '">' +
          '<div class="blog-search-result-title">' + escapeHtml(item.title || '') + '</div>' +
          '<div class="blog-search-result-date">' + escapeHtml(item.date || '') + '</div>' +
          tagHtml +
        '</a>';
      }).join('');
    }

    function performSearch(query) {
      loadSearchData().then(function (items) {
        renderResults(query, items);
      });
    }

    window.performSearch = performSearch;

    input.addEventListener('focus', function () {
      resultsContainer.style.display = 'block';
      loadSearchData();
    });

    input.addEventListener('blur', function () {
      setTimeout(function () {
        resultsContainer.style.display = 'none';
      }, 200);
    });

    input.addEventListener('input', function () {
      performSearch(input.value);
    });

    if (searchButton) {
      searchButton.addEventListener('click', function () {
        performSearch(input.value);
      });
    }

    document.addEventListener('click', function (event) {
      const searchContainer = document.querySelector('.blog-search');
      if (searchContainer && !searchContainer.contains(event.target)) {
        resultsContainer.style.display = 'none';
      }
    });
  }

  function initLightbox() {
    if (config.enableImageLightbox === false) {
      return;
    }

    const lightbox = byId('lightbox');
    const lightboxImage = byId('lightboxImage');
    const lightboxClose = byId('lightboxClose');
    if (!lightbox || !lightboxImage || !lightboxClose) {
      return;
    }

    document.querySelectorAll('.article-content img, .single-image-container img, .image-slider img').forEach(function (img) {
      img.addEventListener('click', function () {
        lightboxImage.src = img.currentSrc || img.src;
        lightboxImage.alt = img.alt || '';
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
      });
    });

    function closeLightbox() {
      lightbox.classList.remove('active');
      document.body.style.overflow = '';
      lightboxImage.removeAttribute('src');
    }

    lightboxClose.addEventListener('click', closeLightbox);
    lightbox.addEventListener('click', function (event) {
      if (event.target === lightbox) {
        closeLightbox();
      }
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && lightbox.classList.contains('active')) {
        closeLightbox();
      }
    });
  }

  function initImageSlider() {
    if (config.enableImageSlider === false) {
      return;
    }

    document.querySelectorAll('.article-content').forEach(function (content) {
      content.querySelectorAll('p').forEach(function (paragraph) {
        const images = Array.from(paragraph.querySelectorAll('img'));
        if (images.length > 1) {
          const container = document.createElement('div');
          container.className = 'image-slider-container';

          const slider = document.createElement('div');
          slider.className = 'image-slider';

          images.forEach(function (img) {
            img.classList.add('slider-image');
            slider.appendChild(img);
          });

          const hint = document.createElement('div');
          hint.className = 'slider-hint';
          hint.textContent = '← 左右滑动查看更多图片 →';

          container.appendChild(slider);
          container.appendChild(hint);
          paragraph.parentNode.insertBefore(container, paragraph.nextSibling);

          paragraph.innerHTML = paragraph.innerHTML.replace(/!\[.*?\]\(.*?\)/g, '').trim();
          if (!paragraph.textContent.trim()) {
            paragraph.style.display = 'none';
          }
        } else if (images.length === 1) {
          const container = document.createElement('div');
          container.className = 'single-image-container';
          container.appendChild(images[0]);
          paragraph.innerHTML = '';
          paragraph.appendChild(container);
        }
      });
    });
  }

  function initCodeCopy() {
    document.querySelectorAll('.article-content .chroma, .article-content .highlight .chroma').forEach(function (block) {
      block.addEventListener('click', function (event) {
        if (event.target !== block && event.target !== block.querySelector('code')) {
          return;
        }

        const code = block.querySelector('code');
        if (!code || !navigator.clipboard) {
          return;
        }

        navigator.clipboard.writeText(code.textContent).then(function () {
          block.classList.add('is-copied');
          setTimeout(function () {
            block.classList.remove('is-copied');
          }, 1600);
        });
      });
    });
  }

  window.toggleTOC = function toggleTOC() {
    const tocContent = byId('toc-content');
    const buttonText = byId('toc-toggle-text');
    if (!tocContent || !buttonText) {
      return;
    }

    const collapsed = tocContent.getAttribute('data-collapsed') === 'true';
    tocContent.style.maxHeight = collapsed ? '1000px' : '0';
    tocContent.style.opacity = collapsed ? '1' : '0';
    tocContent.setAttribute('data-collapsed', collapsed ? 'false' : 'true');
    buttonText.textContent = collapsed ? '收起' : '展开';
  };

  function initToc() {
    const tocToggle = document.querySelector('[data-toc-toggle]');
    if (tocToggle) {
      tocToggle.addEventListener('click', window.toggleTOC);
    }

    const headings = document.querySelectorAll('h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]');
    const tocLinks = document.querySelectorAll('.enhanced-toc a');
    const tocContainer = byId('toc-container');
    const tocContent = byId('toc-content');

    function syncActiveTocLink(id) {
      let activeLink = null;
      tocLinks.forEach(function (link) {
        const isActive = link.getAttribute('href') === '#' + id;
        link.classList.toggle('active', isActive);
        if (isActive) {
          activeLink = link;
        }
      });

      if (!activeLink || !tocContainer || (tocContent && tocContent.getAttribute('data-collapsed') === 'true')) {
        return;
      }

      requestAnimationFrame(function () {
        const activeItem = activeLink.closest('li') || activeLink;
        const containerRect = tocContainer.getBoundingClientRect();
        const itemRect = activeItem.getBoundingClientRect();
        const topBuffer = 86;
        const bottomBuffer = 28;
        const isAbove = itemRect.top < containerRect.top + topBuffer;
        const isBelow = itemRect.bottom > containerRect.bottom - bottomBuffer;

        if (!isAbove && !isBelow) {
          return;
        }

        tocContainer.scrollTo({
          top: tocContainer.scrollTop + itemRect.top - containerRect.top - topBuffer,
          behavior: 'smooth'
        });
      });
    }

    if (headings.length && tocLinks.length) {
      const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) {
            return;
          }

          const id = entry.target.getAttribute('id');
          syncActiveTocLink(id);
        });
      }, {
        root: null,
        rootMargin: '-10% 0px -80% 0px',
        threshold: 0
      });

      headings.forEach(function (heading) {
        observer.observe(heading);
      });

      if (window.location.hash) {
        syncActiveTocLink(window.location.hash.slice(1));
      }
    }

    document.querySelectorAll('.enhanced-toc li').forEach(function (item) {
      const sublist = item.querySelector('ul');
      const link = item.querySelector('a');
      if (!sublist || !link || item.querySelector('.toc-toggle')) {
        return;
      }

      const toggle = document.createElement('button');
      toggle.className = 'toc-toggle';
      toggle.type = 'button';
      toggle.innerHTML = '▶';
      toggle.addEventListener('click', function () {
        const hidden = sublist.style.display === 'none';
        sublist.style.display = hidden ? 'block' : 'none';
        toggle.innerHTML = hidden ? '▼' : '▶';
      });
      link.parentNode.insertBefore(toggle, link);
    });
  }

  function initRuntime() {
    const runtime = byId('runtime');
    if (!runtime) {
      return;
    }

    const startTime = new Date(runtime.getAttribute('data-runtime-start') || '2026-03-21T00:00:00+08:00').getTime();
    if (!Number.isFinite(startTime)) {
      return;
    }

    const daysNode = runtime.querySelector('[data-runtime-days]');
    const hoursNode = runtime.querySelector('[data-runtime-hours]');
    const minutesNode = runtime.querySelector('[data-runtime-minutes]');
    const secondsNode = runtime.querySelector('[data-runtime-seconds]');
    if (!daysNode || !hoursNode || !minutesNode || !secondsNode) {
      return;
    }

    function updateRuntime() {
      const diff = Math.max(Date.now() - startTime, 0);
      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((diff % (1000 * 60)) / 1000);

      daysNode.textContent = String(days);
      hoursNode.textContent = String(hours);
      minutesNode.textContent = String(minutes);
      secondsNode.textContent = String(seconds);
    }

    updateRuntime();
    window.setInterval(updateRuntime, 1000);
  }

  function initFireworks() {
    if (config.enableClickFireworks === false || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return;
    }

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d', { alpha: true });
    if (!ctx) {
      return;
    }

    const particles = [];
    const isCoarsePointer = window.matchMedia('(pointer: coarse)').matches;
    const maxParticles = isCoarsePointer ? 72 : 96;
    const clickCooldown = 200;
    let animationFrame = null;
    let lastClickTime = 0;
    let dpr = Math.min(window.devicePixelRatio || 1, 2);

    canvas.setAttribute('aria-hidden', 'true');
    canvas.className = 'blog-firework-canvas';
    document.body.appendChild(canvas);

    function resizeCanvas() {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      canvas.width = Math.ceil(window.innerWidth * dpr);
      canvas.height = Math.ceil(window.innerHeight * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }

    function getFireworkColors() {
      const isLightTheme = document.body.getAttribute('data-theme') === 'light';
      return isLightTheme
        ? ['#0096a6', '#ff9f1c', '#e83f7d', '#087f8c', '#f6bd60', '#2ec4b6']
        : ['#00ffff', '#a5b4fc', '#ffffff', '#ff79c6', '#50fa7b', '#bd93f9', '#ffb86c', '#ff5555'];
    }

    function createFireworks(x, y) {
      const colors = getFireworkColors();
      const count = isCoarsePointer ? 10 : 18;
      const particleCount = Math.min(count, Math.max(maxParticles - particles.length, 0));

      for (let i = 0; i < particleCount; i++) {
        const angle = (Math.PI * 2 / particleCount) * i + Math.random() * 0.2;
        const distance = (isCoarsePointer ? 48 : 60) + Math.random() * (isCoarsePointer ? 26 : 40);
        const speed = distance * 0.06;

        particles.push({
          x: x,
          y: y,
          vx: Math.cos(angle) * speed,
          vy: Math.sin(angle) * speed,
          size: 2 + Math.random() * 4,
          color: colors[Math.floor(Math.random() * colors.length)],
          alpha: 0,
          scale: 0,
          gravity: 0.3,
          age: 0,
          fadeAfter: 8,
          fadeStarted: false
        });
      }

      if (!animationFrame && particles.length) {
        animationFrame = requestAnimationFrame(drawFireworks);
      }
    }

    function drawFireworks() {
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);

      for (let i = particles.length - 1; i >= 0; i--) {
        const particle = particles[i];
        particle.x += particle.vx;
        particle.y += particle.vy + particle.gravity;
        particle.gravity += 0.03;
        particle.age += 1;
        particle.scale = Math.min(particle.scale + 0.1, 1);

        if (!particle.fadeStarted) {
          particle.alpha = Math.min(particle.alpha + 0.1, 1);
        }

        if (particle.age >= particle.fadeAfter) {
          particle.fadeStarted = true;
        }

        if (particle.fadeStarted) {
          particle.alpha -= 0.032;
        }

        if (particle.alpha <= 0) {
          particles.splice(i, 1);
          continue;
        }

        ctx.globalAlpha = Math.max(particle.alpha, 0);
        ctx.fillStyle = particle.color;
        ctx.shadowColor = particle.color;
        ctx.shadowBlur = isCoarsePointer ? 2 : Math.min(particle.size * 1.5, 6);
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.size * particle.scale, 0, Math.PI * 2);
        ctx.fill();
      }

      ctx.globalAlpha = 1;
      ctx.shadowBlur = 0;
      animationFrame = particles.length ? requestAnimationFrame(drawFireworks) : null;
    }

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas, { passive: true });
    document.addEventListener('click', function (event) {
      const currentTime = Date.now();
      const lightbox = byId('lightbox');
      if (currentTime - lastClickTime < clickCooldown || (lightbox && lightbox.classList.contains('active'))) {
        return;
      }
      lastClickTime = currentTime;
      createFireworks(event.clientX, event.clientY);
    }, { passive: true });
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function escapeAttr(value) {
    return escapeHtml(value).replace(/`/g, '&#96;');
  }
})();
