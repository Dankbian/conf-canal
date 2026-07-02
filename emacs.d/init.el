;;; ==================== Paquetes base ====================

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)


;;; ==================== Mouse en modo -nw ====================

(xterm-mouse-mode 1)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)


;;; ==================== GUI: transparencia y barras ====================

;; Siempre ocultar las barras (funciona en GUI y -nw)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; La transparencia solo aplica en GUI.
;; default-frame-alist la hereda cada frame nuevo (incluyendo el inicial).
;; set-frame-parameter solo se llama si ya hay un frame GUI disponible.
(when (display-graphic-p)
  (add-to-list 'default-frame-alist '(alpha-background . 55))
  (add-to-list 'default-frame-alist '(alpha . (90 . 90)))
  (set-frame-parameter nil 'alpha-background 55)
  (set-frame-parameter (selected-frame) 'alpha '(90 . 90)))

;; Para frames GUI que se creen después (daemon / emacsclient)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (set-frame-parameter frame 'alpha-background 55)
              (set-frame-parameter frame 'alpha '(90 . 90)))))


;;; ==================== Portapapeles ====================

(setq select-enable-primary t
      select-enable-clipboard t)


;;; ==================== Calidad de vida general ====================

(electric-pair-mode 1)
(run-with-timer 0 60 (lambda () (save-some-buffers t)))

(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z") 'undo)

(setq display-line-numbers-type 'absolute)
(global-display-line-numbers-mode t)
(column-number-mode t)


;;; ==================== Colores del menú TTY ====================

(custom-set-faces
 '(menu ((t (:background "#1a1b26" :foreground "#00ffbe"))))
 '(tty-menu-disabled-face ((t (:background "#1a1b26" :foreground "#565f89"))))
 '(tty-menu-enabled-face ((t (:background "#1a1b26" :foreground "#ff00ff"))))
 '(tty-menu-selected-face ((t (:background "#ff00ff" :foreground "#ffffff")))))


;;; ==================== Transparencia en terminal -nw ====================

;; En terminal no se pueden usar colores con canal alfa (#RRGGBBAA)
;; Solo se usa un color sólido normal
(when (not (display-graphic-p))
  (set-face-background 'default "black")
  (set-face-foreground 'default "#DDDDDD"))


;;; ==================== Tema y modeline ====================

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-outrun-electric t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(set-face-attribute 'mode-line nil
                    :background "#202020"
                    :foreground "grey80"
                    :box '(:line-width 1
                           :color "#ff5fff"
                           :style released-button))

(set-face-attribute 'mode-line-inactive nil
                    :background "#151515"
                    :foreground "grey50"
                    :box '(:line-width 1
                           :color "#444444"
                           :style released-button))


;;; ==================== Header line con breadcrumb ====================

(defface my-header-breadcrumb-1
  '((t :foreground "white" :weight bold))
  "Carpeta más externa del breadcrumb.")

(defface my-header-breadcrumb-2
  '((t :foreground "#00afff" :weight bold))
  "Carpeta intermedia del breadcrumb.")

(defface my-header-breadcrumb-3
  '((t :foreground "#f700ff" :weight bold))
  "Carpeta más interna del breadcrumb.")

(defface my-header-breadcrumb-separator
  '((t :foreground "grey60"))
  "Separador entre carpetas.")

(defun my/header-line-breadcrumb ()
  "Muestra solo las últimas 3 carpetas de la ruta, coloreadas por nivel."
  (if (or (minibufferp)
          (string-prefix-p " *" (buffer-name)))
      ""
    (let* ((dir (or (if buffer-file-name
                        (file-name-directory buffer-file-name)
                      default-directory)
                   ""))
           (abbr  (abbreviate-file-name dir))
           (parts (split-string abbr "/" t))
           (tail  (last parts (min 3 (length parts))))
           (faces (list 'my-header-breadcrumb-1
                        'my-header-breadcrumb-2
                        'my-header-breadcrumb-3))
           (i 0)
           (segments '()))
      (dolist (p tail)
        (push (propertize p 'face (nth i faces)) segments)
        (setq i (1+ i)))
      (setq segments (nreverse segments))
      (concat " "
              (mapconcat #'identity segments
                         (propertize " > " 'face 'my-header-breadcrumb-separator))))))

(setq-default header-line-format '((:eval (my/header-line-breadcrumb))))

(set-face-attribute 'header-line nil
                    :background "#202020"
                    :foreground "grey80"
                    :box '(:line-width -1 :style released-button))


;;; ==================== Which-key ====================

(use-package which-key
  :ensure t
  :init (which-key-mode))


;;; ==================== Beacon ====================

(use-package beacon
  :ensure t
  :config (beacon-mode 1))


;;; ==================== Rainbow delimiters ====================

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :ensure t)


;;; ==================== Highlight indent guides ====================

(with-eval-after-load 'highlight-indent-guides
  (setq highlight-indent-guides-auto-enabled nil)
  (setq highlight-indent-guides-method 'character)
  (set-face-foreground 'highlight-indent-guides-character-face "gray35"))

(remove-hook 'prog-mode-hook #'highlight-indent-guides-mode)

(when (boundp 'highlight-indent-guides-mode)
  (remove-hook 'prog-mode-hook  #'highlight-indent-guides-mode)
  (remove-hook 'java-mode-hook  #'highlight-indent-guides-mode)
  (remove-hook 'after-change-major-mode-hook #'highlight-indent-guides-mode))

(setq-default highlight-indent-guides-mode nil)


;;; ==================== Treemacs ====================

(use-package treemacs
  :ensure t
  :defer t
  :bind
  (("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs)
   ("C-x t B"   . treemacs-bookmark)
   ("C-x t C-t" . treemacs-find-file))
  :config
  (setq treemacs-is-never-other-window t
        treemacs-follow-mode t
        treemacs-persist-file nil
        max-lisp-eval-depth 5000)

  (defun my/treemacs-open-current-dir ()
    "Abrir Treemacs en el directorio actual del buffer."
    (interactive)
    (let ((dir (if (buffer-file-name)
                   (file-name-directory (buffer-file-name))
                 default-directory)))
      (treemacs-select-window)
      (treemacs-display-current-project-exclusively)
      (treemacs-root-up)
      (treemacs-find-file)))

  (global-set-key (kbd "C-x t h") 'my/treemacs-open-current-dir))

(use-package treemacs-nerd-icons
  :after treemacs nerd-icons
  :ensure t
  :config
  (treemacs-load-theme "nerd-icons"))


;;; ==================== Dashboard ====================

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner (expand-file-name "~/.emacs.d/ascii/logo.txt"))
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents   . 0)
                           (projects  . 0)
                           (bookmarks . 0)
                           (agenda    . 0))))


;;; ==================== Org mode ====================

(use-package org
  :pin gnu
  :config
  (setq org-use-fast-tag-selection t
        org-fast-tag-selection-single-key t)

  (setq org-todo-keywords
        '((sequence "POR_HACER(t)" "EN_PROGRESO(p)" "BLOQUEADO(b)" "|" "HECHO(d)" "ENTREGADO(e)")))

  (setq org-log-done 'time
        org-return-follows-link t
        org-hide-emphasis-markers t)

  (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
  (add-hook 'org-mode-hook #'org-indent-mode)
  (add-hook 'org-mode-hook #'visual-line-mode)

  (define-key global-map (kbd "C-c l") #'org-store-link)
  (define-key global-map (kbd "C-c a") #'org-agenda)
  (define-key global-map (kbd "C-c c") #'org-capture)
  (define-key org-mode-map (kbd "C-c <up>")    #'org-priority-up)
  (define-key org-mode-map (kbd "C-c <down>")  #'org-priority-down)
  (define-key org-mode-map (kbd "C-c C-g C-r") #'org-shiftmetaright)

  (defun my/org-rebuild-tag-faces-and-refresh ()
    "Reconstruye regex de tags y refresca buffers Org."
    (org-set-regexps-and-options)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (derived-mode-p 'org-mode)
          (if (fboundp 'org-restart-font-lock)
              (org-restart-font-lock)
            (font-lock-flush)
            (font-lock-ensure))))))

  (add-hook 'org-mode-hook #'my/org-rebuild-tag-faces-and-refresh)
  (add-hook 'after-make-frame-functions (lambda (_f) (my/org-rebuild-tag-faces-and-refresh)))
  (advice-add 'load-theme :after (lambda (&rest _) (my/org-rebuild-tag-faces-and-refresh)))

  (defun my/apply-org-tag-faces () (interactive) (my/org-rebuild-tag-faces-and-refresh))

  (my/org-rebuild-tag-faces-and-refresh))


;;; ==================== Agenda ====================

(with-eval-after-load 'org-agenda
  (setq org-agenda-window-setup 'current-window
        org-agenda-start-on-weekday nil
        org-agenda-start-day "today"
        org-agenda-span 7
        org-deadline-warning-days 7
        org-agenda-skip-deadline-if-done t
        org-agenda-skip-deadline-prewarning-if-scheduled t
        org-agenda-skip-timestamp-if-deadline-is-shown t
        org-agenda-show-all-dates t
        org-agenda-format-date "%a %d-%m-%Y"
        org-agenda-prefix-format '((agenda   . " %i %-12:c%?-12t% s")
                                   (timeline . " % s")
                                   (todo     . " %i %-12:c%T ")
                                   (tags     . " %i %-12:c")
                                   (search   . " %i %-12:c"))
        org-agenda-sorting-strategy
        '((agenda time-up priority-down category-keep)
          (todo   priority-down deadline-up)
          (tags   priority-down)
          (search category-keep)))

  (defun air-org-skip-subtree-if-priority (priority)
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (pri-value (* 1000 (- org-lowest-priority priority)))
          (pri-current (org-get-priority (thing-at-point 'line t))))
      (if (= pri-value pri-current) subtree-end nil)))

  (setq org-agenda-custom-commands
        '(("d" "Daily agenda and all TODOs"
           ((tags "PRIORITY=\"A\""
                  ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                   (org-agenda-overriding-header "High-priority unfinished tasks:")))
            (agenda "" ((org-agenda-span 7)))
            (alltodo ""
                     ((org-agenda-skip-function
                       '(or (air-org-skip-subtree-if-priority ?A)
                            (air-org-skip-subtree-if-priority ?C)
                            (org-agenda-skip-if nil '(scheduled deadline))))
                      (org-agenda-overriding-header "ALL normal priority tasks:")))
            (tags "PRIORITY=\"C\""
                  ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                   (org-agenda-overriding-header "Low-priority unfinished tasks:"))))
           ((org-agenda-compact-blocks nil)))))

  (global-set-key (kbd "C-c A")
                  (lambda () (interactive) (org-agenda nil "d"))))


;;; ==================== Fechas Día-Mes-Año ====================

(setq org-display-custom-times t)
(setq org-time-stamp-custom-formats '("<%d-%m-%Y>" . "<%d-%m-%Y %H:%M>"))


;;; ==================== Preámbulo LaTeX automático ====================

(require 'subr-x)
(setq user-full-name (or user-full-name "Dankbian"))

(use-package autoinsert
  :ensure nil
  :hook (after-init . auto-insert-mode)
  :config
  (setq auto-insert-query nil)

  (defun my/org-derive-title-from-filename ()
    (let* ((base  (file-name-base (or (buffer-file-name) (buffer-name))))
           (clean (string-trim (replace-regexp-in-string "[-_]+" " " base))))
      (mapconcat #'capitalize (split-string clean " ") " ")))

  (defun my/org-make-preamble ()
    (let* ((title  (my/org-derive-title-from-filename))
           (author (or user-full-name "Dankbian")))
      (concat
       "#+TITLE: "  title  "\n"
       "#+AUTHOR: " author "\n\n"
       "#+LANGUAGE: es\n"
       "#+OPTIONS: toc:t num:t\n"
       "#+LATEX_CLASS: article\n"
       "#+LATEX_HEADER: \\usepackage{geometry}\n"
       "#+LATEX_HEADER: \\geometry{margin=2.5cm}\n"
       "#+LATEX_HEADER: \\usepackage{parskip}\n"
       "#+LATEX_HEADER: \\usepackage{xcolor}\n"
       "#+LATEX_HEADER: \\usepackage{sectsty}\n"
       "#+LATEX_HEADER: \\usepackage[hidelinks]{hyperref}\n"
       "#+LATEX_HEADER: \\usepackage{tocloft}\n"
       "#+LATEX_HEADER: \\renewcommand{\\cftdotsep}{1.5}\n"
       "#+LATEX_HEADER: \\renewcommand{\\cftsecleader}{\\cftdotfill{\\cftdotsep}}\n"
       "#+LATEX_HEADER: \\usepackage{titling}\n"
       "#+LATEX_HEADER: \\pretitle{\\begin{center}\\Huge\\bfseries}\n"
       "#+LATEX_HEADER: \\posttitle{\\par\\end{center}\\vfill}\n"
       "#+LATEX_HEADER: \\preauthor{\\begin{center}\\Large}\n"
       "#+LATEX_HEADER: \\postauthor{\\par\\end{center}\\vfill}\n"
       "#+LATEX_HEADER: \\predate{\\begin{center}\\large}\n"
       "#+LATEX_HEADER: \\postdate{\\par\\end{center}\\vfill\\newpage}\n\n"
       "#+LATEX_HEADER: \\usepackage{booktabs}\n"
       "#+LATEX_HEADER: \\usepackage{listings}\n"
       "#+LATEX_HEADER: \\lstset{basicstyle=\\ttfamily\\small, breaklines=true, keywordstyle=\\color{red}}\n\n"
       "#+LATEX: \\newpage\n\n")))

  (define-auto-insert
    '("\\.org\\'" . "Org default preamble")
    (lambda () (insert (my/org-make-preamble)))))

(defun my/insert-org-preamble ()
  "Inserta el preámbulo Org/LaTeX por defecto en el buffer actual."
  (interactive)
  (insert (my/org-make-preamble)))

(with-eval-after-load 'ox-latex
  (setq org-latex-with-hyperref nil))


;;; ==================== Org: estilo visual ====================

;; Estos setq deben ir antes de cargar buffers org,
;; pero el face org-hide necesita sobreescribirse DESPUÉS del tema
;; para que el color coincida con el fondo y los asteriscos desaparezcan.
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-hidden-keywords '(title author date startup))

;; Forzar que org-hide use el mismo color que el fondo del buffer.
;; Se aplica después del tema y cada vez que se abre un buffer org.
(defun my/fix-org-hide-stars ()
  "Hace que org-hide-leading-stars funcione igualando el color al fondo."
  (set-face-attribute 'org-hide nil
                      :foreground (face-background 'default nil t)
                      :background 'unspecified))

(add-hook 'org-mode-hook #'my/fix-org-hide-stars)
(advice-add 'load-theme :after (lambda (&rest _) (my/fix-org-hide-stars)))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autokeywords t
        org-appear-delay 0.05))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-table nil)
  (setq org-modern-block-name '((t . "")))
  (setq org-modern-block-fringe nil))

(use-package toc-org
  :hook (org-mode . toc-org-enable))


;;; ==================== Tablas bonitas (org-pretty-table parcheado) ====================

;; Usamos nuestra versión parcheada de org-pretty-table.
;; El parche corrige org-pretty-table-align para que llame
;; directamente a propertize-region después de alinear,
;; en vez de depender de jit-lock que nunca refontificaba.
;;
;; Instrucciones:
;; Copia el archivo org-pretty-table.el parcheado a:
;;   ~/.emacs.d/packetes_externos_descargados/org-pretty-table/
(let ((pretty-table-path
       (expand-file-name "~/.emacs.d/paquetes_externos_descargados/org-pretty-table")))
  (when (file-directory-p pretty-table-path)
    (add-to-list 'load-path pretty-table-path)
    (require 'org-pretty-table nil t)
    (when (fboundp 'org-pretty-table-mode)
      (add-hook 'org-mode-hook #'org-pretty-table-mode))))

;;; ==================== Resaltado de fila en tablas ====================

(require 'hl-line)

(with-eval-after-load 'hl-line
  (set-face-background 'hl-line "#663366")
  (set-face-foreground 'hl-line nil))

(defun my/org-hl-line-only-in-tables ()
  "Resalta solo la parte de la fila de tabla donde está el punto."
  (setq-local
   hl-line-range-function
   (lambda ()
     (when (org-at-table-p)
       (save-excursion
         (beginning-of-line)
         (if (search-forward "|" (line-end-position) t)
             (cons (1- (point)) (line-end-position))
           (cons (line-beginning-position) (line-end-position))))))))

(add-hook 'org-mode-hook #'my/org-hl-line-only-in-tables)
(add-hook 'org-mode-hook #'hl-line-mode)


;;; ==================== Triángulos dinámicos con colores ====================

(require 'org)
(require 'outline)

(defface org-custom-triangle-level-1 '((t :foreground "#00fdfd")) "Color nivel 1.")
(defface org-custom-triangle-level-2 '((t :foreground "#39FF14")) "Color nivel 2.")
(defface org-custom-triangle-level-3 '((t :foreground "#fe0ab7")) "Color nivel 3.")
(defface org-custom-triangle-level-4 '((t :foreground "#55ffe2")) "Color nivel 4.")
(defface org-custom-triangle-level-5 '((t :foreground "#c2ff05")) "Color nivel 5.")

(defun org-custom-triangles--face (level)
  (pcase level
    (1 'org-custom-triangle-level-1)
    (2 'org-custom-triangle-level-2)
    (3 'org-custom-triangle-level-3)
    (4 'org-custom-triangle-level-4)
    (_ 'org-custom-triangle-level-5)))

(defvar-local org-custom-triangles--visual-state (make-hash-table :test 'equal)
  "Estado visual de plegado por encabezado.")

(defun org-custom-triangles--visually-folded-p (point)
  (gethash point org-custom-triangles--visual-state))

(defun org-custom-triangles--toggle-visual (point)
  (puthash point (not (gethash point org-custom-triangles--visual-state))
           org-custom-triangles--visual-state))

(defun org-custom-triangles--symbol (level point)
  "Triángulos sólidos (1–2) o huecos (3+), dinámicos y visuales."
  (let ((folded (org-custom-triangles--visually-folded-p point)))
    (if folded
        (if (<= level 2) "▶ " "▷ ")
      (if (<= level 2) "▼ " "▽ "))))

(defvar-local org-custom-triangles--overlays nil
  "Overlays activos en el buffer.")

(defun org-custom-triangles--make-overlay (point level)
  (save-excursion
    (goto-char point)
    (when (looking-at "^\\*+ ")
      (let* ((symbol (org-custom-triangles--symbol level point))
             (face   (org-custom-triangles--face level))
             (ov (make-overlay (match-beginning 0) (match-end 0))))
        (overlay-put ov 'display (propertize symbol 'face face))
        (overlay-put ov 'org-custom-triangle t)
        (push ov org-custom-triangles--overlays)))))

(defun org-custom-triangles--update-at (point)
  (save-excursion
    (goto-char point)
    (when (looking-at "^\\(\\*+\\) ")
      (let* ((level  (length (match-string 1)))
             (symbol (org-custom-triangles--symbol level point))
             (face   (org-custom-triangles--face level)))
        (dolist (ov (overlays-at point))
          (when (overlay-get ov 'org-custom-triangle)
            (overlay-put ov 'display (propertize symbol 'face face))))))))

(defun org-custom-triangles--apply-all ()
  (setq org-custom-triangles--overlays nil)
  (clrhash org-custom-triangles--visual-state)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\(\\*+\\) " nil t)
      (let* ((point (match-beginning 1))
             (level (length (match-string 1))))
        (puthash point nil org-custom-triangles--visual-state)
        (org-custom-triangles--make-overlay point level)))))

(defun org-custom-triangles--update-all ()
  (dolist (ov org-custom-triangles--overlays)
    (let ((pos (overlay-start ov)))
      (when pos
        (org-custom-triangles--update-at pos)))))

(defun org-custom-triangles--after-cycle (_state)
  (let ((pt (line-beginning-position)))
    (org-custom-triangles--toggle-visual pt)
    (org-custom-triangles--update-at pt)))

(defun org-custom-triangles--after-insert ()
  (let* ((pt    (line-beginning-position))
         (level (org-current-level)))
    (puthash pt nil org-custom-triangles--visual-state)
    (org-custom-triangles--make-overlay pt level)))

(define-minor-mode org-custom-triangles-mode
  "Triángulos dinámicos con colores por nivel."
  :lighter ""
  (if org-custom-triangles-mode
      (progn
        (org-custom-triangles--apply-all)
        (add-hook 'org-cycle-hook          #'org-custom-triangles--after-cycle  nil t)
        (add-hook 'org-insert-heading-hook #'org-custom-triangles--after-insert nil t))
    (remove-hook 'org-cycle-hook          #'org-custom-triangles--after-cycle  t)
    (remove-hook 'org-insert-heading-hook #'org-custom-triangles--after-insert t)
    (mapc #'delete-overlay org-custom-triangles--overlays)))

(add-hook 'org-mode-hook #'org-custom-triangles-mode)


;;; ==================== Modo lectura centrado ====================

(use-package visual-fill-column
  :commands visual-fill-column-mode
  :bind (("C-c z" . my/toggle-narrow-reading)))

(defun my/toggle-narrow-reading ()
  "Centrar el texto para leer más cómodo."
  (interactive)
  (if (bound-and-true-p visual-fill-column-mode)
      (progn
        (visual-fill-column-mode -1)
        (visual-line-mode 1))
    (progn
      (visual-line-mode 1)
      (setq visual-fill-column-width 100
            visual-fill-column-center-text t)
      (visual-fill-column-mode 1))))


;;; ==================== Eglot (LSP general) ====================

(require 'eglot)

(defun my/maybe-eglot ()
  "Usar Eglot en prog-mode, excepto en Java."
  (unless (derived-mode-p 'java-mode)
    (eglot-ensure)))

(add-hook 'prog-mode-hook #'my/maybe-eglot)


;;; ==================== Autocompletado ====================

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1
        company-selection-wrap-around t))

(use-package yasnippet-snippets
  :ensure t)

(global-set-key (kbd "<f1>") #'yas-describe-tables)


;;; ==================== Git ====================

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))


;;; ==================== vterm ====================

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))


;;; ==================== PATH para herramientas locales ====================

(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(setenv "PATH" (concat (expand-file-name "~/.local/bin") ":" (getenv "PATH")))


;;; ==================== EMMS (música) ====================

(use-package emms
  :ensure t
  :init
  (require 'emms-setup)
  (emms-all)
  (setq emms-source-file-default-directory "~/Música/")
  (setq emms-player-list '(emms-player-mpv))
  (setq emms-info-functions '(emms-info-native))
  (setq emms-player-mpv-parameters '("--no-video"))
  :config
  (global-set-key (kbd "C-c e p")   #'emms)
  (global-set-key (kbd "C-c e a")   #'emms-add-directory)
  (global-set-key (kbd "C-c e n")   #'emms-next)
  (global-set-key (kbd "C-c e b")   #'emms-previous)
  (global-set-key (kbd "C-c e SPC") #'emms-pause)
  (global-set-key (kbd "C-c e s")   #'emms-stop))

;;; ==================== Custom variables (generadas por Emacs) ====================

(custom-set-variables
 '(package-selected-packages
   '(beacon company dashboard doom-modeline doom-themes
     emms forge highlight-indent-guides magit org-appear
     org-modern rainbow-delimiters toc-org treemacs
     treemacs-nerd-icons visual-fill-column vterm
     which-key yasnippet-snippets)))
