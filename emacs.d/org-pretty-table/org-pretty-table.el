;;; org-pretty-table.el --- Replace org-table characters with box-drawing unicode glyphs -*- lexical-binding: t -*-

;; Copyright (C) 2013, 2023 Matus Goljer

;; Author: Matus Goljer <matus.goljer@gmail.com>
;; Maintainer: Matus Goljer <matus.goljer@gmail.com>
;; Keywords: faces
;; URL: https://github.com/Fuco1/org-pretty-table
;; Package-Requires: ((org "9") (emacs "24.1"))
;; Version: 1.0.0
;; Created: 29th November 2013

;;; Commentary:

;; This replaces the characters - | and + in `org-mode' tables with
;; appropriate unicode box-drawing glyphs, see
;; http://en.wikipedia.org/wiki/Box-drawing_character

;;; Code:

(require 'org)

(defconst org-pretty-table-regexp (regexp-opt '("-" "+" "|")))

(defgroup org-pretty-table ()
  "Replace org-table characters with box-drawing unicode glyphs."
  :group 'org)

(defcustom org-pretty-table-charset "┌┐└┘┬┤┴├┼─│"
  "Charset to draw the table.

The value is a string of length 11 with the characters used to
draw the table borders.

The order of the blocks is:

- upper left corner
- upper right corner
- lower left corner
- lower right corner
- down-facing T
- left-facing T
- up-facing T
- right-facing T
- cross
- horizontal bar
- vertical bar"
  :group 'org-pretty-table
  :type '(choice (const :tag "Single horizontal lines" "┌┐└┘┬┤┴├┼─│")
                 (const :tag "Double horizontal lines" "╒╕╘╛╤╡╧╞╪═│")
                 (string :tag "Custom")))

(defsubst org-pretty-table-ul-corner ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 0)))

(defsubst org-pretty-table-ur-corner ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 1)))

(defsubst org-pretty-table-ll-corner ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 2)))

(defsubst org-pretty-table-lr-corner ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 3)))

(defsubst org-pretty-table-df-t ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 4)))

(defsubst org-pretty-table-lf-t ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 5)))

(defsubst org-pretty-table-uf-t ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 6)))

(defsubst org-pretty-table-rf-t ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 7)))

(defsubst org-pretty-table-cross ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 8)))

(defsubst org-pretty-table-hb ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 9)))

(defsubst org-pretty-table-vb ()
  (declare (pure t))
  (make-string 1 (aref org-pretty-table-charset 10)))

(defun org-pretty-table-at-table-p ()
  "Check if point is at table."
  (save-excursion
    (skip-syntax-forward " " (line-end-position))
    (eq (following-char) ?|)))

(defun org-pretty-table-propertize-region (start end)
  "Replace org-table characters with box-drawing glyphs between START and END.

Used by jit-lock for dynamic highlighting."
  (save-excursion
    (goto-char start)
    (let (table-end)
      (while (re-search-forward org-pretty-table-regexp end t)
        (if (and table-end
                 (> (point) table-end))
            (setq table-end nil))

        (unless (and (not table-end)
                     (not (save-match-data
                            (org-at-table-p))))

          (unless table-end
            (save-match-data
              (setq table-end (org-table-end))))

          (let ((match (match-string 0)))
            (cond
             ((equal "-" match)
              (backward-char 1)
              (re-search-forward "-+")
              (when (looking-at-p "[+|]")
                (put-text-property
                 (match-beginning 0) (match-end 0)
                 'display
                 (make-string (- (match-end 0) (match-beginning 0))
                              (aref (org-pretty-table-hb) 0))))
              t)
             ((equal "|" match)
              (cond
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (forward-line 1)
                       (org-pretty-table-at-table-p))
                     (save-excursion
                       (backward-char 1)
                       (not (bobp)))
                     (save-excursion
                       (forward-line -1)
                       (and (not (bobp))
                            (org-pretty-table-at-table-p))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-rf-t))
                t)
               ((and (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (forward-line 1)
                       (org-pretty-table-at-table-p))
                     (save-excursion
                       (forward-line -1)
                       (and (not (bobp))
                            (org-pretty-table-at-table-p))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-lf-t))
                t)
               ((and (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (forward-line -1)
                       (or (bobp)
                           (not (org-pretty-table-at-table-p)))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-ur-corner))
                t)
               ((and (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (forward-line 1)
                       (not (org-pretty-table-at-table-p))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-lr-corner))
                t)
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (forward-line -1)
                       (or (bobp)
                           (not (org-pretty-table-at-table-p)))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-ul-corner))
                t)
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (forward-line 1)
                       (not (org-pretty-table-at-table-p))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-ll-corner))
                t)
               (t
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-vb))
                t)))
             ((equal "+" match)
              (cond
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (forward-line -1)
                       (and (not (bobp))
                            (org-pretty-table-at-table-p)))
                     (save-excursion
                       (forward-line 1)
                       (org-pretty-table-at-table-p)))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-cross))
                t)
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (forward-line -1)
                       (or (bobp)
                           (not (org-pretty-table-at-table-p))))
                     (save-excursion
                       (forward-line 1)
                       (org-pretty-table-at-table-p)))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-df-t))
                t)
               ((and (eq (following-char) ?-)
                     (save-excursion
                       (backward-char 1)
                       (eq (preceding-char) ?-))
                     (save-excursion
                       (let ((char-pos (- (point) (line-beginning-position) 1)))
                         (forward-line -1)
                         (beginning-of-line)
                         (forward-char char-pos))
                       (eq (following-char) ?|))
                     (save-excursion
                       (backward-char 1)
                       (forward-line)
                       (not (eq (following-char) ?|))))
                (put-text-property (match-beginning 0) (match-end 0) 'display (org-pretty-table-uf-t))
                t))))))))))

(defun org-pretty-table-unpropertize-region (start end)
  "Remove box-drawing compositions between START and END."
  (remove-text-properties start end '(display)))

(defun org-pretty-table-unpropertize-table ()
  "Remove box-drawing compositions from table at point."
  (org-pretty-table-unpropertize-region (org-table-begin) (org-table-end)))

;; ============================================================
;; PATCH: reemplaza la función original que tenía el bug.
;;
;; Original:
;;   desactiva modo → limpia → alinea → reactiva modo
;;   El problema: reactivar solo llama jit-lock-register,
;;   que es perezoso y nunca refontifica la región "limpia".
;;
;; Fix:
;;   Guardamos beg/end ANTES de tocar nada, luego después de
;;   alinear llamamos propertize-region directamente.
;; ============================================================
(defun org-pretty-table-align (oldfun &rest args)
  "Align org table and immediately re-apply box-drawing glyphs.
This replaces the original which relied on jit-lock lazily
refontifying — which never happened because the region was
already considered clean after alignment."
  (let ((beg (condition-case nil (org-table-begin) (error nil)))
        (end (condition-case nil (org-table-end)   (error nil))))
    ;; Limpia propiedades visuales para que org vea ASCII puro
    (when (and beg end)
      (org-pretty-table-unpropertize-region beg end))
    ;; Alinea con los caracteres reales
    (apply oldfun args)
    ;; Actualiza end porque org-table-align puede cambiar el tamaño
    (setq end (condition-case nil (org-table-end) (error end)))
    ;; Aplica los glifos AHORA, sin esperar a jit-lock
    (when (and beg end)
      (org-pretty-table-propertize-region beg end))))

;;; Minor mode:

;;;###autoload
(define-minor-mode org-pretty-table-mode
  "Replace org-table characters with box-drawing unicode glyphs."
  :lighter " OPT"
  (if org-pretty-table-mode
      (progn
        (jit-lock-register 'org-pretty-table-propertize-region t)
        (advice-add 'org-table-align :around #'org-pretty-table-align))
    (jit-lock-unregister 'org-pretty-table-propertize-region)
    (advice-remove 'org-table-align #'org-pretty-table-align)
    (org-pretty-table-unpropertize-region (point-min) (point-max))))

;;;###autoload
(defun turn-on-org-pretty-table-mode ()
  "Turn on `org-pretty-table-mode'."
  (org-pretty-table-mode 1))

;;;###autoload
(defun turn-off-org-pretty-table-mode ()
  "Turn off `org-pretty-table-mode'."
  (org-pretty-table-mode 0))

;;;###autoload
(define-globalized-minor-mode global-org-pretty-table-mode
  org-pretty-table-mode turn-on-org-pretty-table-mode)

(provide 'org-pretty-table)
;;; org-pretty-table.el ends here
