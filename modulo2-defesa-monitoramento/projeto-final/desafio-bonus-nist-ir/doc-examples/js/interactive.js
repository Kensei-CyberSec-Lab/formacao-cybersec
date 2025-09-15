// Interactive Features for NIST IR Documentation
document.addEventListener('DOMContentLoaded', function() {
    
    // Initialize all features
    initializeNavigation();
    initializeSearch();
    initializeProgress();
    initializeTooltips();
    initializePrintFeatures();
    initializeThemeToggle();
    initializeAnimations();
    
    // Navigation functionality
    function initializeNavigation() {
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
        
        // Active navigation highlighting
        const sections = document.querySelectorAll('section[id]');
        const navLinks = document.querySelectorAll('.nav-links a[href^="#"]');
        
        function highlightNavigation() {
            let current = '';
            sections.forEach(section => {
                const sectionTop = section.offsetTop;
                const sectionHeight = section.clientHeight;
                if (scrollY >= sectionTop - 200) {
                    current = section.getAttribute('id');
                }
            });
            
            navLinks.forEach(link => {
                link.classList.remove('active');
                if (link.getAttribute('href') === '#' + current) {
                    link.classList.add('active');
                }
            });
        }
        
        window.addEventListener('scroll', highlightNavigation);
    }
    
    // Search functionality
    function initializeSearch() {
        const searchInput = document.getElementById('searchInput');
        const searchResults = document.getElementById('searchResults');
        
        if (searchInput && searchResults) {
            let searchTimeout;
            
            searchInput.addEventListener('input', function(e) {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => {
                    performSearch(e.target.value);
                }, 300);
            });
            
            function performSearch(query) {
                if (query.length < 2) {
                    searchResults.style.display = 'none';
                    return;
                }
                
                const results = searchDocuments(query);
                displaySearchResults(results);
            }
            
            function searchDocuments(query) {
                const documents = [
                    {
                        title: 'Desafio Bônus NIST IR',
                        url: 'desafio-bonus.html',
                        content: 'Plano de resposta a incidentes NIST SP 800-61 Rev. 2 cenários ransomware data breach conta privilegiada'
                    },
                    {
                        title: 'Template Plano IR',
                        url: 'template-plano.html',
                        content: 'Template estruturado preparação detecção análise contenção erradicação recuperação pós-incidente'
                    },
                    {
                        title: 'Exemplo Cenário Ransomware',
                        url: 'exemplo-ransomware.html',
                        content: 'Exemplo prático LockBit criptografia isolamento evidências forense recuperação backup'
                    },
                    {
                        title: 'Matriz de Classificação',
                        url: 'matriz-classificacao.html',
                        content: 'Classificação incidentes severidade impacto urgência CIA confidencialidade integridade disponibilidade'
                    },
                    {
                        title: 'Playbook de Contenção',
                        url: 'playbook-contencao.html',
                        content: 'Procedimentos técnicos contenção malware phishing DDoS data breach compromisso conta defacement APT'
                    },
                    {
                        title: 'Tutorial Completo Lab',
                        url: 'tutorial-lab.html',
                        content: 'Tutorial passo a passo WAF ModSecurity DVWA Docker containers ataques SQLi XSS reconhecimento'
                    }
                ];
                
                const lowercaseQuery = query.toLowerCase();
                return documents.filter(doc => 
                    doc.title.toLowerCase().includes(lowercaseQuery) ||
                    doc.content.toLowerCase().includes(lowercaseQuery)
                ).slice(0, 5);
            }
            
            function displaySearchResults(results) {
                if (results.length === 0) {
                    searchResults.innerHTML = '<div class="search-no-results">Nenhum resultado encontrado</div>';
                } else {
                    searchResults.innerHTML = results.map(result => `
                        <div class="search-result">
                            <a href="${result.url}" class="search-result-title">${result.title}</a>
                            <div class="search-result-snippet">${getSnippet(result.content, searchInput.value)}</div>
                        </div>
                    `).join('');
                }
                searchResults.style.display = 'block';
            }
            
            function getSnippet(content, query) {
                const words = content.split(' ');
                const queryIndex = words.findIndex(word => 
                    word.toLowerCase().includes(query.toLowerCase())
                );
                
                if (queryIndex === -1) return words.slice(0, 15).join(' ') + '...';
                
                const start = Math.max(0, queryIndex - 7);
                const end = Math.min(words.length, queryIndex + 8);
                
                return '...' + words.slice(start, end).join(' ') + '...';
            }
            
            // Close search results when clicking outside
            document.addEventListener('click', function(e) {
                if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
                    searchResults.style.display = 'none';
                }
            });
        }
    }
    
    // Progress tracking
    function initializeProgress() {
        const progressBars = document.querySelectorAll('.progress-bar');
        
        progressBars.forEach(bar => {
            const targetWidth = bar.getAttribute('data-width') || '0%';
            
            // Animate progress bar when it comes into view
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        setTimeout(() => {
                            entry.target.style.width = targetWidth;
                        }, 300);
                        observer.unobserve(entry.target);
                    }
                });
            });
            
            observer.observe(bar);
        });
    }
    
    // Tooltips
    function initializeTooltips() {
        const tooltipElements = document.querySelectorAll('[data-tooltip]');
        
        tooltipElements.forEach(element => {
            element.addEventListener('mouseenter', showTooltip);
            element.addEventListener('mouseleave', hideTooltip);
            element.addEventListener('mousemove', moveTooltip);
        });
        
        function showTooltip(e) {
            const tooltip = document.createElement('div');
            tooltip.className = 'tooltip';
            tooltip.textContent = e.target.getAttribute('data-tooltip');
            document.body.appendChild(tooltip);
            
            const rect = e.target.getBoundingClientRect();
            tooltip.style.left = rect.left + (rect.width / 2) - (tooltip.offsetWidth / 2) + 'px';
            tooltip.style.top = rect.top - tooltip.offsetHeight - 10 + 'px';
            
            tooltip.style.opacity = '1';
            e.target.tooltipElement = tooltip;
        }
        
        function hideTooltip(e) {
            if (e.target.tooltipElement) {
                e.target.tooltipElement.remove();
                e.target.tooltipElement = null;
            }
        }
        
        function moveTooltip(e) {
            if (e.target.tooltipElement) {
                const tooltip = e.target.tooltipElement;
                const rect = e.target.getBoundingClientRect();
                tooltip.style.left = rect.left + (rect.width / 2) - (tooltip.offsetWidth / 2) + 'px';
                tooltip.style.top = rect.top - tooltip.offsetHeight - 10 + 'px';
            }
        }
    }
    
    // Print features
    function initializePrintFeatures() {
        const printButtons = document.querySelectorAll('.btn-print');
        
        printButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Add print styles
                document.body.classList.add('printing');
                
                // Trigger print
                window.print();
                
                // Remove print styles after printing
                setTimeout(() => {
                    document.body.classList.remove('printing');
                }, 1000);
            });
        });
        
        // PDF export functionality
        const exportButtons = document.querySelectorAll('.btn-export-pdf');
        
        exportButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Show export modal or instructions
                showExportInstructions();
            });
        });
        
        function showExportInstructions() {
            const modal = document.createElement('div');
            modal.className = 'export-modal';
            modal.innerHTML = `
                <div class="export-modal-content">
                    <div class="export-modal-header">
                        <h3>Exportar para PDF</h3>
                        <button class="export-modal-close">&times;</button>
                    </div>
                    <div class="export-modal-body">
                        <p><strong>Para exportar este documento como PDF:</strong></p>
                        <ol>
                            <li>Use <kbd>Cmd+P</kbd> (macOS) ou <kbd>Ctrl+P</kbd> (Windows/Linux)</li>
                            <li>Selecione "Salvar como PDF" no destino</li>
                            <li>Configure margens para "Mínima" ou "Personalizada (1cm)"</li>
                            <li>Habilite "Gráficos de fundo" para manter as cores</li>
                            <li>Clique em "Salvar"</li>
                        </ol>
                        <p class="text-muted">O layout foi otimizado para impressão em papel A4.</p>
                    </div>
                    <div class="export-modal-footer">
                        <button class="btn btn-primary" onclick="window.print()">Imprimir Agora</button>
                        <button class="btn btn-secondary export-modal-close">Fechar</button>
                    </div>
                </div>
            `;
            
            document.body.appendChild(modal);
            
            // Close modal functionality
            modal.querySelectorAll('.export-modal-close').forEach(closeBtn => {
                closeBtn.addEventListener('click', () => {
                    modal.remove();
                });
            });
            
            // Close on backdrop click
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.remove();
                }
            });
        }
    }
    
    // Theme toggle
    function initializeThemeToggle() {
        const themeToggle = document.getElementById('themeToggle');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
        
        if (themeToggle) {
            // Set initial theme
            const savedTheme = localStorage.getItem('nist-ir-theme') || 'light';
            setTheme(savedTheme);
            
            themeToggle.addEventListener('click', function(e) {
                e.preventDefault();
                const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
                const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
                setTheme(newTheme);
                localStorage.setItem('nist-ir-theme', newTheme);
                
                // Visual feedback
                themeToggle.style.transform = 'scale(0.8)';
                setTimeout(() => {
                    themeToggle.style.transform = 'scale(1)';
                }, 200);
            });
            
            // Listen for system theme changes
            prefersDark.addEventListener('change', (e) => {
                if (!localStorage.getItem('nist-ir-theme')) {
                    setTheme(e.matches ? 'dark' : 'light');
                }
            });
        }
        
        function setTheme(theme) {
            document.documentElement.setAttribute('data-theme', theme);
            if (themeToggle) {
                themeToggle.innerHTML = theme === 'dark' ? '☀️' : '🌙';
                themeToggle.setAttribute('data-tooltip', 
                    theme === 'dark' ? 'Modo Claro' : 'Modo Escuro');
                themeToggle.setAttribute('aria-label', 
                    theme === 'dark' ? 'Alternar para modo claro' : 'Alternar para modo escuro');
            }
            
            // Trigger a custom event for other components
            document.dispatchEvent(new CustomEvent('themeChanged', { 
                detail: { theme: theme } 
            }));
        }
    }
    
    // Animations
    function initializeAnimations() {
        // Fade in animation for cards
        const animatedElements = document.querySelectorAll('.card, .doc-card, .stat-card');
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in-up');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });
        
        animatedElements.forEach(element => {
            observer.observe(element);
        });
        
        // Typing animation for headers
        const typingElements = document.querySelectorAll('.typing-animation');
        
        typingElements.forEach(element => {
            const text = element.textContent;
            element.textContent = '';
            
            let i = 0;
            const typeInterval = setInterval(() => {
                element.textContent += text.charAt(i);
                i++;
                
                if (i > text.length) {
                    clearInterval(typeInterval);
                }
            }, 100);
        });
    }
    
    // Copy to clipboard functionality
    function initializeCopyFeatures() {
        const copyButtons = document.querySelectorAll('.btn-copy');
        
        copyButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetId = this.getAttribute('data-copy-target');
                const targetElement = document.getElementById(targetId) || 
                                    this.parentElement.querySelector('code, pre');
                
                if (targetElement) {
                    const text = targetElement.textContent;
                    
                    navigator.clipboard.writeText(text).then(() => {
                        showCopyFeedback(this);
                    }).catch(() => {
                        // Fallback for older browsers
                        fallbackCopyToClipboard(text);
                        showCopyFeedback(this);
                    });
                }
            });
        });
        
        function fallbackCopyToClipboard(text) {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
        }
        
        function showCopyFeedback(button) {
            const originalText = button.textContent;
            button.textContent = '✓ Copiado!';
            button.classList.add('btn-success');
            
            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('btn-success');
            }, 2000);
        }
    }
    
    // Initialize copy features
    initializeCopyFeatures();
    
    // Back to top button
    function initializeBackToTop() {
        const backToTopButton = document.createElement('button');
        backToTopButton.className = 'back-to-top';
        backToTopButton.innerHTML = '↑';
        backToTopButton.setAttribute('data-tooltip', 'Voltar ao topo');
        document.body.appendChild(backToTopButton);
        
        window.addEventListener('scroll', () => {
            if (window.scrollY > 500) {
                backToTopButton.classList.add('visible');
            } else {
                backToTopButton.classList.remove('visible');
            }
        });
        
        backToTopButton.addEventListener('click', () => {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    
    initializeBackToTop();
    
    // Performance monitoring
    function initializePerformanceMonitoring() {
        if ('performance' in window) {
            window.addEventListener('load', () => {
                const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
                console.log(`Página carregada em ${loadTime}ms`);
                
                // Optional: Send analytics
                if (loadTime > 3000) {
                    console.warn('Página carregou lentamente:', loadTime + 'ms');
                }
            });
        }
    }
    
    initializePerformanceMonitoring();
});

// CSS for additional dynamic elements
const dynamicStyles = `
.tooltip {
    position: absolute;
    background: rgba(0, 0, 0, 0.9);
    color: white;
    padding: 0.5rem 0.75rem;
    border-radius: 0.25rem;
    font-size: 0.8rem;
    z-index: 1000;
    opacity: 0;
    transition: opacity 0.3s ease;
    pointer-events: none;
    white-space: nowrap;
}

.export-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.export-modal-content {
    background: white;
    border-radius: 1rem;
    max-width: 500px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 2rem 4rem rgba(0, 0, 0, 0.2);
}

.export-modal-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--border-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.export-modal-header h3 {
    margin: 0;
    color: var(--primary-color);
}

.export-modal-close {
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: var(--light-text);
}

.export-modal-body {
    padding: 1.5rem;
}

.export-modal-footer {
    padding: 1.5rem;
    border-top: 1px solid var(--border-color);
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
}

kbd {
    background: var(--light-bg);
    border: 1px solid var(--border-color);
    border-radius: 0.25rem;
    padding: 0.1rem 0.3rem;
    font-family: monospace;
    font-size: 0.8em;
}

.back-to-top {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    background: var(--secondary-color);
    color: white;
    border: none;
    border-radius: 50%;
    width: 3rem;
    height: 3rem;
    font-size: 1.2rem;
    cursor: pointer;
    box-shadow: var(--shadow-lg);
    transition: all 0.3s ease;
    opacity: 0;
    visibility: hidden;
    z-index: 100;
}

.back-to-top.visible {
    opacity: 1;
    visibility: visible;
}

.back-to-top:hover {
    background: #2980b9;
    transform: translateY(-2px);
}

.search-results {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid var(--border-color);
    border-radius: 0.5rem;
    box-shadow: var(--shadow-lg);
    max-height: 300px;
    overflow-y: auto;
    z-index: 1000;
    display: none;
}

.search-result {
    padding: 1rem;
    border-bottom: 1px solid var(--border-color);
}

.search-result:last-child {
    border-bottom: none;
}

.search-result:hover {
    background: var(--light-bg);
}

.search-result-title {
    color: var(--secondary-color);
    text-decoration: none;
    font-weight: 500;
    display: block;
    margin-bottom: 0.25rem;
}

.search-result-snippet {
    color: var(--light-text);
    font-size: 0.875rem;
    line-height: 1.4;
}

.search-no-results {
    padding: 1rem;
    text-align: center;
    color: var(--light-text);
    font-style: italic;
}

.btn-copy {
    position: absolute;
    top: 0.5rem;
    right: 0.5rem;
    background: rgba(255, 255, 255, 0.1);
    color: white;
    border: none;
    border-radius: 0.25rem;
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    cursor: pointer;
    opacity: 0;
    transition: opacity 0.3s ease;
}

pre:hover .btn-copy {
    opacity: 1;
}

.btn-success {
    background: var(--success-color) !important;
}

.nav-links a.active {
    background: var(--secondary-color);
    color: white;
}
`;

// Inject dynamic styles
const styleSheet = document.createElement('style');
styleSheet.textContent = dynamicStyles;
document.head.appendChild(styleSheet);
