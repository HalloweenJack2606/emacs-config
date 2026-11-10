# Emacs config

My personal Emacs setup, kept in `~/.emacs.d`.

## Files

- `init.el`: main config
- `early-init.el`: turns off native compilation, which fails on Mac
- `themes/naysayer-theme.el`: color theme, loaded from a local file
- `.mc-lists.el`: multiple-cursors preferences, written by the package itself

Packages, caches and backups are left out of the repo (see `.gitignore`).

## Restore on a new machine

1. Move any existing `~/.emacs` out of the way. Emacs loads it before `init.el` if both exist.
2. Clone the repo:
   ```sh
   git clone https://github.com/HalloweenJack2606/emacs-config.git ~/.emacs.d
   ```
3. Open Emacs. `use-package` installs topsy and cmake-mode on first start.
4. Run `M-x package-install-selected-packages` once to install glsl-mode and multiple-cursors.

## Not in the repo

Install these separately:

- Fira Mono font
- `slangd` at `~/.local/slang/bin/slangd` (ships with Slang), used for the Slang LSP
- `cmake` (Homebrew), used to rebuild shaders when you save a `.slang` file
- The shader projects in `~/dev/shrooms` and `~/dev/engine`. Saving a `.slang` file builds the `shaders` target in each one that has a configured `build/` dir and skips the rest.
