;;; -*- lexical-binding: t; -*-
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'naysayer t)
(set-frame-font "Fira Mono-14" nil t) ;; Fira Mono Font
(add-to-list 'default-frame-alist '(font . "Fira Mono-14"))
(show-paren-mode 1) ;; highlight matching parenthesis 
(setq use-short-answers t) ;; Clean Yes or No prompts
(global-hl-line-mode 1) ;; Highlight current line
(menu-bar-mode -1)
(scroll-bar-mode -1)
;; (ido-mode 1) ; Ehhh not sure about this File search IDO mode
(tool-bar-mode -1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("19e390918f5e517e84511806e80ea7d7b61644aea9274f6025b98f1e5860e0bb"
	 default))
 '(package-selected-packages '(cmake-mode glsl-mode multiple-cursors topsy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(line-number ((t (:foreground "color"))))
 '(line-number-current-line ((t (:foreground "color" :weight bold)))))

;; (global-display-line-numbers-mode)


(setq-default tab-width 4)          ;; Set tab width to 4
(setq-default c-basic-offset 4)     ;; For C-like languages

(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-basic-offset 4)    ;; Set indentation width to 4
            (c-set-offset 'substatement-open 0) ;; Align { with if/for/while
            (c-set-offset 'brace-list-open 0)   ;; Align { in enum/structs
            (c-set-offset 'case-label '+)))     ;; Indent case labels properly in switch

(global-set-key (kbd "C-x C-o") 'ff-find-other-file)
(global-set-key (kbd "C-c m") #'mc/mark-all-in-region)

;; MELPA
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)


;; TOML
(add-hook 'conf-toml-mode-hook
  (lambda ()
    (setq indent-tabs-mode nil)
    (setq tab-width 2)
    (local-set-key (kbd "TAB") (lambda () (interactive) (insert "  ")))))

;; For Prescience opening 
(require 'server)
(unless (server-running-p)
  (server-start))

(add-hook 'c++-mode-hook
          (lambda ()
            (c-set-offset 'statement-cont '+)))

;; Objective-C++
(add-to-list 'auto-mode-alist '("\\.mm\\'" . objc-mode))
(with-eval-after-load 'find-file
  (add-to-list 'cc-other-file-alist '("\\.mm\\'" (".h")))
  (setcdr (assoc "\\.h\\'" cc-other-file-alist)
          (list (append (cadr (assoc "\\.h\\'" cc-other-file-alist)) '(".mm")))))

;; Topsy (Sticky Header)
(use-package topsy
  :ensure t
  :hook (prog-mode . topsy-mode))

;; Slang shaders
(define-derived-mode slang-mode c++-mode "Slang"
  "Major mode for Slang shaders.")

(font-lock-add-keywords
 'slang-mode
 '(("\\_<\\(?:float\\|half\\|int\\|uint\\|bool\\)[1-4]\\(?:x[1-4]\\)?\\_>" 0 font-lock-type-face t)
   ("\\_<\\(?:Texture[123]D\\|TextureCube\\|RWTexture2D\\|SamplerState\\|ConstantBuffer\\|StructuredBuffer\\|RWStructuredBuffer\\|ByteAddressBuffer\\|RWByteAddressBuffer\\)\\_>" 0 font-lock-type-face t)
   ("\\_<\\(?:import\\|module\\|implementing\\|nointerpolation\\|groupshared\\|inout\\|let\\|var\\|interface\\|extension\\|associatedtype\\)\\_>" 0 font-lock-keyword-face t)
   ("\\_<SV_[A-Za-z]+\\_>" 0 font-lock-constant-face t)
   ("\\[\\[?\\(?:vk::\\)?[a-z_]+" 0 font-lock-preprocessor-face t))
 'append)

(add-to-list 'auto-mode-alist '("\\.slang\\'" . slang-mode))

;; Slang LSP (slangd ships with slang)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `(slang-mode . (,(expand-file-name "~/.local/slang/bin/slangd")))))
(add-hook 'slang-mode-hook #'eglot-ensure)

;; Slang: recompile shaders on save in the background, hot reload picks up the new .spv
(defvar my/shader-build-dirs
  (list (expand-file-name "~/dev/shrooms/build")
        (expand-file-name "~/dev/engine/build"))
  "Build dirs whose 'shaders' target runs when a .slang is saved.")

(defvar my/cmake (or (executable-find "cmake") "/opt/homebrew/bin/cmake"))

(defun my/slang-compile-shaders ()
  (dolist (dir my/shader-build-dirs)
    (when (file-exists-p (expand-file-name "CMakeCache.txt" dir))
      (let* ((project (file-name-nondirectory (directory-file-name (file-name-directory (directory-file-name dir)))))
             (buf (get-buffer-create (format " *shaders %s*" project))))
        (with-current-buffer buf (erase-buffer))
        (make-process
         :name (format "shaders-%s" project)
         :buffer buf
         :command (list my/cmake "--build" dir "--target" "shaders")
         :noquery t
         :sentinel #'my/shader-build-sentinel)))))

;; NOTE: the project comes from the process name
(require 'ansi-color)
(defun my/shader-build-sentinel (proc _event)
  (when (memq (process-status proc) '(exit signal))
    (let ((project (substring (process-name proc) (length "shaders-"))))
      (if (= (process-exit-status proc) 0)
          (message "shaders %s: ok" project)
        (with-current-buffer (process-buffer proc)
          (goto-char (point-min))
          (message "shaders %s: %s" project
                   (if (re-search-forward "^.*error.*$" nil t)
                       (ansi-color-filter-apply (match-string 0))
                     "build failed")))))))

(add-hook 'slang-mode-hook
          (lambda () (add-hook 'after-save-hook #'my/slang-compile-shaders nil t)))

;; Keep backup (~) and auto-save (#...#) files out of project folders
(let ((dir (expand-file-name "~/.emacs.d/backups/")))
  (make-directory dir t)
  (setq backup-directory-alist `(("." . ,dir))
        auto-save-file-name-transforms `((".*" ,dir t))))

;; CMake
(use-package cmake-mode
  :ensure t)
