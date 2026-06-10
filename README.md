# matugen-theme.el

A dynamic theme switcher for Emacs that synchronizes your Emacs colors with your system's dynamic themes out-of-the-box (specifically designed for **Dank Linux** / **Ghostty** environments using `dankcolors`).

Whenever your Wayland setup updates your system colors (via Matugen, Wallust, etc.), Ghostty's `dankcolors` file gets updated. This Emacs package simply listens to that same file and live-reloads your `modus-themes` without requiring an Emacs restart!

## Requirements
- Emacs 28.1+
- `modus-themes` package installed

## 1. Install in Emacs

### Using Straight.el (Doom Emacs)
Add this to your `packages.el`:
```elisp
(package! matugen-theme
  :recipe (:host github :repo "diegoveraniego/matugen-theme-emacs"))
```

### Configuration (Doom Emacs)
In your `config.el`:
```elisp
(use-package! matugen-theme
  :defer nil
  :config
  ;; Starts the file watcher so Emacs reloads when Ghostty/Dank Linux updates the colors
  (matugen-theme-mode 1))
```

## Usage

That's it! As long as `matugen-theme-mode` is enabled, Emacs will extract its palette from `~/.config/ghostty/themes/dankcolors` automatically.

You can trigger a manual reload of the colors by typing:
- `M-x matugen-theme-reload`
