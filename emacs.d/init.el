;;; ==================== Paquetes base ====================


(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Asegura que use-package esté disponible
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)


;;  Arreglo para highlight-indent-guides en modo -nw o sin tema cargado
(with-eval-after-load 'highlight-indent-guides
  ;; Evita el cálculo automático de colores (que falla sin face `default`)
  (setq highlight-indent-guides-auto-enabled nil)
  (setq highlight-indent-guides-method 'character)
  ;; Frutiger Aero: guías en aqua suave
  (set-face-foreground 'highlight-indent-guides-character-face "#4ab8c8"))

;; Si se estaba activando automáticamente, desactívalo:
(remove-hook 'prog-mode-hook #'highlight-indent-guides-mode)

;; --------------- Cambiar los colores del menú (TMM) ─ Frutiger Aero -----
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(menu ((t (:background "#0a2a3a" :foreground "#7ee8f8"))))
 '(tty-menu-disabled-face ((t (:background "#0a2a3a" :foreground "#3a6a7a"))))
 '(tty-menu-enabled-face ((t (:background "#0a2a3a" :foreground "#a8edfc"))))
 '(tty-menu-selected-face ((t (:background "#1a7a9a" :foreground "#ffffff")))))
;; ------ ACABA LO DEL TMM ----------------


(setq-default highlight-indent-guides-mode nil)

;; MOUSE EN VERSIÓN -NW
(xterm-mouse-mode 1)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)

;;; Semitransparencia Frutiger Aero — vidrio azulado sobre el escritorio
(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 70))

;; PARA QUITAR LA TOOLBAR EN GUI
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)



;;; ==================== Org mode (base) ====================
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
  (define-key org-mode-map (kbd "C-c <up>")   #'org-priority-up)
  (define-key org-mode-map (kbd "C-c <down>") #'org-priority-down)
  (define-key org-mode-map (kbd "C-c C-g C-r") #'org-shiftmetaright))

 
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
        org-agenda-format-date "%a %d %b"
        org-agenda-prefix-format '((agenda  . " %i %-12:c%?-12t% s")
                                   (timeline . " % s")
                                   (todo    . " %i %-12:c%T ")
                                   (tags    . " %i %-12:c")
                                   (search  . " %i %-12:c"))
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

;;; ==================== Fechas estilo Día-Mes-Año ====================
(setq org-display-custom-times t)
(setq org-time-stamp-custom-formats '("<%d-%m-%Y>" . "<%d-%m-%Y %H:%M>"))

(with-eval-after-load 'org-agenda
  (setq org-agenda-format-date "%a %d-%m-%Y"))


;;; ==================== (Opcional) Clipboard en terminal ====================
;; (use-package xclip :if (and (not (display-graphic-p)) (executable-find "xclip"))
;;   :init (xclip-mode 1))

;; ========= PREÁMBULO LATEX AUTO =========
(require 'subr-x)
(setq user-full-name (or user-full-name "Dankbian"))

(use-package autoinsert
  :ensure nil
  :hook (after-init . auto-insert-mode)
  :config
  (setq auto-insert-query nil)

  (defun my/org-derive-title-from-filename ()
    (let* ((base (file-name-base (or (buffer-file-name) (buffer-name))))
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


;; ========= TREEMACS =========
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


(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package which-key
  :ensure t
  :init (which-key-mode))


;; =====================================================
;; TEMA FRUTIGER AERO
;; doom-city-lights como base + retoques aqua/cristal
;; =====================================================
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-city-lights t))

(doom-themes-visual-bell-config)
(doom-themes-org-config)

;; Retoques de color Frutiger Aero sobre el tema base
;; Se aplican después de que el tema esté cargado
(with-eval-after-load 'doom-themes
  ;; Fondo principal — azul noche profundo con toque aqua
  (set-face-attribute 'default nil
                      :background "#0d1f2d"
                      :foreground "#cce8f4")

  ;; Región seleccionada — brillo cristal aqua
  (set-face-attribute 'region nil
                      :background "#1a6080"
                      :foreground nil)

  ;; Cursor — aqua brillante
  (set-face-attribute 'cursor nil
                      :background "#40e8e0")

  ;; Strings — verde naturaleza fresco
  (set-face-attribute 'font-lock-string-face nil
                      :foreground "#78e8a8")

  ;; Keywords — aqua vidrioso
  (set-face-attribute 'font-lock-keyword-face nil
                      :foreground "#38d8f8")

  ;; Comentarios — gris azulado suave
  (set-face-attribute 'font-lock-comment-face nil
                      :foreground "#5a8a9a"
                      :slant 'italic)

  ;; Funciones — azul cielo claro
  (set-face-attribute 'font-lock-function-name-face nil
                      :foreground "#88c8f8")

  ;; Variables — blanco aqua
  (set-face-attribute 'font-lock-variable-name-face nil
                      :foreground "#a8e8e0")

  ;; Tipos — aqua medio
  (set-face-attribute 'font-lock-type-face nil
                      :foreground "#50d8d8")

  ;; Números — verde menta
  (set-face-attribute 'font-lock-constant-face nil
                      :foreground "#90f0b8"))


(use-package treemacs-nerd-icons
  :after treemacs nerd-icons
  :ensure t
  :config
  (treemacs-load-theme "nerd-icons"))

;; Coloriza paréntesis
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode)
  :ensure t)

;; Colores de paréntesis 
(with-eval-after-load 'rainbow-delimiters
  (set-face-foreground 'rainbow-delimiters-depth-1-face "#40e8e8")
  (set-face-foreground 'rainbow-delimiters-depth-2-face "#78d8a0")
  (set-face-foreground 'rainbow-delimiters-depth-3-face "#58b8f8")
  (set-face-foreground 'rainbow-delimiters-depth-4-face "#a8e8f0")
  (set-face-foreground 'rainbow-delimiters-depth-5-face "#30c8d8")
  (set-face-foreground 'rainbow-delimiters-depth-6-face "#c8f0e0")
  (set-face-foreground 'rainbow-delimiters-depth-7-face "#80e8c8"))

(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'column
        highlight-indent-guides-responsive 'top))

(setq display-line-numbers-type 'absolute)
(global-display-line-numbers-mode t)
(column-number-mode t)


(use-package beacon
  :ensure t
  :config
  (beacon-mode 1)
  ;; Beacon aqua
  (setq beacon-color "#40e8e0"
        beacon-size 28
        beacon-blink-delay 0.05))

;; Transparencia en modo GUI
(set-frame-parameter (selected-frame) 'alpha '(88 . 80))
(add-to-list 'default-frame-alist '(alpha . (88 . 80)))


(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner "/home/dankbian/.emacs.d/ascii/intro.txt")
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents  . 0)
                          (projects . 0)
                          (bookmarks . 0)
                          (agenda . 0))))


;; Terminal: fondo translúcido tono aqua noche
(when (not (display-graphic-p))
  (set-face-background 'default "#0d1f2dB0")
  (set-face-foreground 'default "#cce8f4"))

;;; ======= GIT =======
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package forge
  :ensure t
  :after magit)


;; ======= SNIPPETS =======
(use-package yasnippet-snippets
  :ensure t)

(global-set-key (kbd "<f1>") #'yas-describe-tables)

(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(setenv "PATH" (concat (expand-file-name "~/.local/bin") ":" (getenv "PATH")))

;; ======= VTERM =======
(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 10000))


;; ======= MÚSICA =======
(use-package emms
  :ensure t
  :init
  (require 'emms-setup)
  (emms-all)
  (setq emms-source-file-default-directory "~/Música/")
  (setq emms-player-list '(emms-player-mpv))
  (setq emms-info-functions '(emms-info-native))
  (setq emms-player-mpv-parameters '("--no-video"))
  (message "[EMMS] Configuración cargada correctamente")
  :config
  (global-set-key (kbd "C-c e p") #'emms)
  (global-set-key (kbd "C-c e a") #'emms-add-directory)
  (global-set-key (kbd "C-c e n") #'emms-next)
  (global-set-key (kbd "C-c e b") #'emms-previous)
  (global-set-key (kbd "C-c e SPC") #'emms-pause)
  (global-set-key (kbd "C-c e s") #'emms-stop))

(load-file "~/.emacs.d/radio-mode/radio-mode.el")

(use-package toc-org
  :hook (org-mode . toc-org-enable))


;; ======= ORG-MODERN =======
(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-table nil)
  (setq org-modern-block-name '((t . "")))
  (setq org-modern-block-fringe nil))

;; ======= ORG PRETTY TABLE =======

(use-package org-pretty-table
  :load-path "~/.emacs.d/packetes_externos_descargados/org-pretty-table"
  :hook (org-mode . org-pretty-table-mode))

(setq org-modern-table nil)

(with-eval-after-load 'org-modern
  (setq org-modern-block-name '((t . "")))
  (setq org-modern-block-fringe nil)
  (add-hook 'org-mode-hook
            (lambda ()
              (org-modern-mode 1)
              (org-pretty-table-mode 1))))

(defun my/org-pretty-table-refresh ()
  (when (and org-pretty-table-mode (org-at-table-p))
    (org-pretty-table--fontify)))

(add-hook 'post-command-hook #'my/org-pretty-table-refresh)

(defun my/org-table-visual-refresh (&rest _)
  (when (derived-mode-p 'org-mode)

    ;; refresh org-pretty-table
    (when (bound-and-true-p org-pretty-table-mode)
      (org-pretty-table--fontify))

    ;; refresh font-lock
    (font-lock-flush)))

(advice-add 'org-table-align :after #'my/org-table-visual-refresh)

(set-face-attribute 'org-table nil
  :foreground "#7df9ff")

(setq valign-fancy-bar t)


;; ======= ORG MIND MAP =======
(use-package org-mind-map
  :init
  (require 'ox-org)
  :ensure t
  :config
  (setq org-mind-map-engine "dot"))


;; ======= PDFs =======
(setq org-file-apps
      '(("\\.pdf\\'" . "pdfopen --viewer xpdf %s")))


;; ======= ORG-APPEAR =======
(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autokeywords t
        org-appear-delay 0.05))


;; ======= KEYWORDS OCULTAS =======
(setq org-hidden-keywords '(title author date startup))


;;; ==========================================
;;; TRIÁNGULOS DINÁMICOS 
;;; ==========================================

(require 'org)
(require 'outline)

;; Faces por nivel — paleta Frutiger Aero
(defface org-custom-triangle-level-1 '((t :foreground "#40e8e8")) "Triángulo nivel 1 — aqua.")
(defface org-custom-triangle-level-2 '((t :foreground "#78d8a0")) "Triángulo nivel 2 — verde suave.")
(defface org-custom-triangle-level-3 '((t :foreground "#60b8f8")) "Triángulo nivel 3 — azul cielo.")
(defface org-custom-triangle-level-4 '((t :foreground "#b8f0e8")) "Triángulo nivel 4 — blanco medio azulado.")
(defface org-custom-triangle-level-5 '((t :foreground "#a0d8e0")) "Triángulo nivel 5 — azul cielo pero diferente.")

(defun org-custom-triangles--face (level)
  (pcase level
    (1 'org-custom-triangle-level-1)
    (2 'org-custom-triangle-level-2)
    (3 'org-custom-triangle-level-3)
    (4 'org-custom-triangle-level-4)
    (_ 'org-custom-triangle-level-5)))

(defvar-local org-custom-triangles--visual-state (make-hash-table :test 'equal))

(defun org-custom-triangles--visually-folded-p (point)
  (gethash point org-custom-triangles--visual-state))

(defun org-custom-triangles--toggle-visual (point)
  (puthash point (not (gethash point org-custom-triangles--visual-state))
           org-custom-triangles--visual-state))

(defun org-custom-triangles--symbol (level point)
  (let ((folded (org-custom-triangles--visually-folded-p point)))
    (if folded
        (if (<= level 2) "▶ " "▷ ")
      (if (<= level 2) "▼ " "▽ "))))

(defvar-local org-custom-triangles--overlays nil)

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
      (let* ((level (length (match-string 1)))
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
  (let* ((pt (line-beginning-position))
         (level (org-current-level)))
    (puthash pt nil org-custom-triangles--visual-state)
    (org-custom-triangles--make-overlay pt level)))

(define-minor-mode org-custom-triangles-mode
  "Triángulos dinámicos por nivel."
  :lighter ""
  (if org-custom-triangles-mode
      (progn
        (org-custom-triangles--apply-all)
        (add-hook 'org-cycle-hook #'org-custom-triangles--after-cycle nil t)
        (add-hook 'org-insert-heading-hook #'org-custom-triangles--after-insert nil t))
    (remove-hook 'org-cycle-hook #'org-custom-triangles--after-cycle t)
    (remove-hook 'org-insert-heading-hook #'org-custom-triangles--after-insert t)
    (mapc #'delete-overlay org-custom-triangles--overlays)))

(add-hook 'org-mode-hook #'org-custom-triangles-mode)

(setq org-hide-leading-stars t) ;; ESTO BORRA LOS ASTERISCOS JEJE
(setq org-startup-indented t)


;;; ==========================================
;;; HEADER LINE 
;;; ==========================================

;; Fondo tipo vidrio aqua oscuro
(set-face-attribute 'header-line nil
                    :background "#0a2030"
                    :foreground "#88d8e8"
                    :box '(:line-width -1 :color "#1a5068" :style released-button))

;; Faces para las carpetas del breadcrumb — gradiente gradiente azul y blanco
(defface my-header-breadcrumb-1
  '((t :foreground "#5ab8d0" :weight bold))
  "Carpeta más externa | aqua medio."
  :group 'my-header-faces)

(defface my-header-breadcrumb-2
  '((t :foreground "#30d8f0" :weight bold))
  "Carpeta intermedia | aqua brillante."
  :group 'my-header-faces)

(defface my-header-breadcrumb-3
  '((t :foreground "#c0f0ff" :weight bold))
  "Carpeta más interna | blanco trasluscido."
  :group 'my-header-faces)

(defface my-header-breadcrumb-separator
  '((t :foreground "#2a6878"))
  "Separador aqua oscuro."
  :group 'my-header-faces)

(defun my/header-line-breadcrumb ()
  "Muestra solo las últimas 3 carpetas"
  (if (or (minibufferp)
          (string-prefix-p " *" (buffer-name)))
      ""
    (let* ((dir (or (if buffer-file-name
                        (file-name-directory buffer-file-name)
                      default-directory)
                   ""))
           (abbr  (abbreviate-file-name dir))
           (parts (split-string abbr "/" t))
           (len   (length parts))
           (tail  (last parts (min 3 len)))
           (faces (list 'my-header-breadcrumb-1
                        'my-header-breadcrumb-2
                        'my-header-breadcrumb-3))
           (i 0)
           (segments '()))
      (dolist (p tail)
        (let* ((face (nth i faces))
               (seg  (propertize p 'face face)))
          (push seg segments)
          (setq i (1+ i))))
      (setq segments (nreverse segments))
      (concat
       " ◈ "
       (mapconcat #'identity
                  segments
                  (propertize " › " 'face 'my-header-breadcrumb-separator))))))

(setq-default header-line-format '((:eval (my/header-line-breadcrumb))))


;;; ==========================================
;;; MODE LINE (BORDE DEPENDE DE ESTA ACTIVO O INACTIVO)
;;; ==========================================

;; Mode line activo 
(set-face-attribute 'mode-line nil
                    :background "#0a2030"
                    :foreground "#88d8e8"
                    :box '(:line-width 1
                          :color "#30c8e0"
                          :style released-button))

;; Mode line inactivo 
(set-face-attribute 'mode-line-inactive nil
                    :background "#071820"
                    :foreground "#3a6878"
                    :box '(:line-width 1
                          :color "#1a4858"
                          :style released-button))


;;; ==========================================
;;; HL LINE
;;; ==========================================

(require 'hl-line)
(require 'org)

(with-eval-after-load 'hl-line
  ;; Resaltado aqua suave tipo agua
  (set-face-background 'hl-line "#0f4055")
  (set-face-foreground 'hl-line nil))

(defun my/org-hl-line-only-in-tables ()
  (setq-local
   hl-line-range-function
   (lambda ()
     (when (org-at-table-p)
       (save-excursion
         (beginning-of-line)
         (if (search-forward "|" (line-end-position) t)
             (cons (1- (point)) (line-end-position))
           (cons (line-beginning-position)
                 (line-end-position))))))))

(add-hook 'org-mode-hook #'my/org-hl-line-only-in-tables)
(add-hook 'org-mode-hook #'hl-line-mode)


;;; ==========================================
;;; FOCUS
;;; ==========================================

(defun my/toggle-narrow-reading ()
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

(use-package visual-fill-column
  :commands visual-fill-column-mode
  :bind (("C-c z" . my/toggle-narrow-reading)))


;;; ==========================================
;;; NÚMEROS DE LÍNEA 
;;; ==========================================
(with-eval-after-load 'display-line-numbers
  (set-face-foreground 'line-number "#2a5868")
  (set-face-foreground 'line-number-current-line "#40d8e8")
  (set-face-background 'line-number-current-line nil))


;;; ==========================================
;;; RELOAD PARA Q CARGUE LO Q NO CARGÓ PQ QN SABE PQ DA ERROR
;;; ==========================================

(defvar my/init-el-reloaded nil)

(unless my/init-el-reloaded
  (setq my/init-el-reloaded t)
  (run-with-timer
   0.5 nil
   (lambda ()
     (message "Recargando init.el una sola vez...")
     (load-file user-init-file))))
