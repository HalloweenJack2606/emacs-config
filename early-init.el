;;; early-init.el --- Runs before ~/.emacs  -*- lexical-binding: t; -*-

;; Native compilation currently fails on this machine:
;;   clang: error: invalid version number in '-mmacosx-version-min=18.0'
;; Turn off on-the-fly compilation so Emacs does not try to invoke it.
;; Emacs still runs everything, using the .elc files instead.
;; Delete this file once a newer Emacs/libgccjit build fixes the error.
(setq native-comp-jit-compilation nil
      native-comp-enable-subr-trampolines nil)

;;; early-init.el ends here
