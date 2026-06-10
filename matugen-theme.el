;;; matugen-theme.el --- Dynamic theme switcher using Matugen colors -*- lexical-binding: t -*-

;; Copyright (C) 2026 Diego

;; Author: Diego
;; Maintainer: Diego
;; Version: 0.2.0
;; Package-Requires: ((emacs "28.1") (modus-themes "4.0"))
;; Keywords: themes, matugen, wayland, ricing

;;; Commentary:

;; Este paquete permite integrar la paleta de colores generada por `matugen`
;; directamente con tu Emacs usando `modus-themes`.
;; Matugen debe configurarse para exportar un archivo JSON con los colores
;; tanto en su variante clara como oscura.

;;; Code:

(require 'json)
(require 'filenotify)
(require 'modus-themes)

(defgroup matugen-theme nil
  "Dynamic theme switcher based on Matugen color palettes."
  :group 'modus-themes
  :prefix "matugen-theme-")

(defcustom matugen-theme-colors-file (expand-file-name "~/.cache/matugen-colors.json")
  "Ruta al archivo JSON generado por Matugen."
  :type 'file
  :group 'matugen-theme)

(defvar matugen-theme--file-watch-descriptor nil
  "Descriptor para el file watcher del JSON de colores.")

(defun matugen-theme--read-colors ()
  "Lee el archivo JSON de colores y lo devuelve como alist."
  (when (file-exists-p matugen-theme-colors-file)
    (let ((json-object-type 'alist)
          (json-array-type 'list)
          (json-key-type 'symbol))
      (json-read-file matugen-theme-colors-file))))

(defun matugen-theme--apply (mode-type base-theme)
  "Aplica la paleta de colores del JSON dada por MODE-TYPE (light o dark) y carga BASE-THEME."
  (let* ((colors-full (matugen-theme--read-colors))
         (colors (cdr (assq mode-type colors-full))))
    (when colors
      (let ((primary (cdr (assq 'primary colors)))
            (secondary (cdr (assq 'secondary colors)))
            (tertiary (cdr (assq 'tertiary colors)))
            (error (cdr (assq 'error colors)))
            (bg (cdr (assq 'background colors)))
            (fg (cdr (assq 'on_background colors)))
            (surface (cdr (assq 'surface colors)))
            (surface-var (cdr (assq 'surface_variant colors))))
        (setq modus-themes-common-palette-overrides
              `((bg-main ,bg)
                (fg-main ,fg)
                (bg-dim ,surface)
                (bg-alt ,surface-var)
                (border ,surface-var)
                (blue ,primary)
                (cyan ,secondary)
                (magenta ,tertiary)
                (red ,error)
                (blue-cooler ,primary)
                (blue-warmer ,secondary)
                (magenta-cooler ,tertiary)))
        (modus-themes-load-theme base-theme)
        (message "Matugen: Tema %s aplicado." mode-type)))))

;;;###autoload
(defun matugen-theme-load-dark ()
  "Aplica los colores oscuros de Matugen y carga `modus-vivendi`."
  (interactive)
  (matugen-theme--apply 'dark 'modus-vivendi))

;;;###autoload
(defun matugen-theme-load-light ()
  "Aplica los colores claros de Matugen y carga `modus-operandi`."
  (interactive)
  (matugen-theme--apply 'light 'modus-operandi))

;;;###autoload
(defun matugen-theme-reload ()
  "Recarga la paleta utilizando la variante actual del sistema."
  (interactive)
  (let ((current-theme (or (modus-themes--current-theme) 'modus-vivendi)))
    ;; Si el tema actual contiene 'operandi' o 'light', usamos la variante clara.
    (if (string-match-p "operandi\\|light" (symbol-name current-theme))
        (matugen-theme-load-light)
      (matugen-theme-load-dark))))

(defun matugen-theme--watcher-callback (event)
  "Callback que se ejecuta cuando el archivo de colores cambia."
  (when (memq (nth 1 event) '(changed attribute-changed created))
    (matugen-theme-reload)))

;;;###autoload
(define-minor-mode matugen-theme-mode
  "Minor mode global para sincronizar Emacs con los colores de Matugen."
  :global t
  :lighter " Matugen"
  (if matugen-theme-mode
      (progn
        (when (file-exists-p matugen-theme-colors-file)
          (matugen-theme-reload))
        (unless matugen-theme--file-watch-descriptor
          (let ((dir (file-name-directory matugen-theme-colors-file)))
            (unless (file-exists-p dir)
              (make-directory dir t)))
          (setq matugen-theme--file-watch-descriptor
                (file-notify-add-watch matugen-theme-colors-file
                                       '(change attribute-change)
                                       #'matugen-theme--watcher-callback))))
    (when matugen-theme--file-watch-descriptor
      (file-notify-rm-watch matugen-theme--file-watch-descriptor)
      (setq matugen-theme--file-watch-descriptor nil))))

(provide 'matugen-theme)
;;; matugen-theme.el ends here
