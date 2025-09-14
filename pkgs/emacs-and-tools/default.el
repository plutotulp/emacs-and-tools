(setq lexical-binding t)

;; Increase GC threshold so we don't spend all our time doing GC. This
;; is good for startup and for lsp-mode, but of course means emacs
;; needs a bit of RAM.
(setq gc-cons-threshold 100000000) ; 100MB

;; Package installation is handled by Nix (see emacs.nix).
(require 'package)
(setq package-archives nil)
(setq package-enable-at-startup nil)
(package-initialize)

;; Most configuration gets done through use-package.
(require 'use-package)

;; Map modifier and delete keys for macOS.
(when (eq system-type 'darwin)
  (setf mac-option-modifier 'none)
  (setf mac-command-modifier 'meta)
  ;; sets fn-delete to be right-delete
  (global-set-key [kp-delete] 'delete-char))


(defconst my/lsp-prefix "C-c l"
  "Key prefix used to activate lsp-mode")


(defun my/which-key-delay-lsp (keyseq seqlen)
  "Delay to use for which-key when entering lsp-mode, in addition
to which-key-idle-delay."
  (when (string-equal keyseq my/lsp-prefix)
    ;; We want lsp-mode to be snappy
    0))

(defun my/which-key-delay-default (keyseq seqlen)
  "Default delay to use for which-key, in addition to
which-key-idle-delay."
  0.9)



;;;; ============================================================
;;;; Setup packages/modes.
;;;; ============================================================

(use-package use-package
  :custom
  ;; By default, use-package's :hook section automatically appends
  ;; "-hook" to all hook names. However, not all hooks have names that
  ;; end that way.
  (use-package-hook-name-suffix nil))

(cl-labels
    ((use-modus-themes ()
       (use-package modus-themes
	 :demand t
	 :init
	 (setq ;; TODO: maybe some org-agenda settings
	  modus-themes-bold-constructs nil
	  modus-themes-mode-line '(accented)
	  modus-themes-paren-match '(bold intense)
	  modus-themes-subtle-line-numbers nil
	  modus-themes-syntax '(faint yellow-comments green-strings alt-syntax)
	  modus-themes-italic-constructs nil)
	 :config
	 (load-theme 'modus-operandi)
	 (load-theme 'modus-vivendi)
	 (enable-theme 'modus-vivendi) ;; or operandi
	 :bind
	 ("<f6>" . modus-themes-toggle)))

     (use-solarized-theme ()
       (use-package solarized-theme
	 :demand t
	 :config
	 (load-theme 'solarized-light)
	 (load-theme 'solarized-dark)
	 (enable-theme 'solarized-dark)
	 :bind
	 ("<f6>" . solarized-toggle-theme))))

  (cond
   ((equal (system-name) "klenodium") (use-solarized-theme))
   ('t (use-modus-themes))))

(use-package autorevert
  :diminish) ;; diminish doesn't work?

(use-package imenu
  ;; Displacing 'tab-to-tab-stop, which isn't very useful. Note that
  ;; helm comes with its own imenu version at C-x c i (and
  ;; multi-buffer version at C-x c I).
  :bind
  (("M-i" . imenu)))

;; (use-package helm
;;   :bind
;;   (("M-x"     . helm-M-x)
;;    ("C-x C-f" . helm-find-files)
;;    ("C-x C-b" . helm-buffers-list)))

;; (use-package helm-tramp)

(use-package flyspell
  ;; Flyspell is the built-in emacs spell checker. Turn off the
  ;; welcome flag because it is rumored to break on some systems (I
  ;; don't know which). Also specify location of spelling program to
  ;; make sure it loads properly.
  :custom
  (flyspell-issue-welcome-flag nil))

(use-package ispell
  :custom
  (ispell-program-name (executable-find "aspell")))

(use-package magit
  :bind
  ("C-c m" . 'magit-status)
  :config
  ;; Evaluated too late if set in :custom (yielding an annoying
  ;; warning when entering magit-status), so we use a :config block
  ;; instead.
  (setf magit-last-seen-setup-instructions "1.4.0")
  :custom
  (magit-use-overlays nil))

;; Used to hard code the git executable to be from
;; ~/.nix-profile/bin/git to ensure we got a git version matching what
;; magit expected (magit being built with nix). That caused problems
;; when using NixOS and having git as a system package. In that case,
;; we really just want to use "git" from the search path instead. I'm
;; thinking it makes sense to just make sure emacs gets run with a
;; sensible PATH to begin with instead of hard coding anything in this
;; config. Kept the little bit of code below for future reference. It
;; enables the personal version of git if it exists, and otherwise
;; uses the system version.
;;
;; (cond
;;  ((file-readable-p "~/.nix-profile/bin/git")
;;   (setq magit-git-executable "~/.nix-profile/bin/git"))
;;  ('true
;;   (setq magit-git-executable "git")))

(use-package eldoc
  :diminish)

(use-package elm-mode
  :custom
  (elm-format-on-save t)
  (elm-format-command "elm-format-0.18"))

(use-package org
  :config
  (make-directory "~/org" 'make-parents)
  :custom
  (org-babel-load-languages
   (mapcar
    (lambda (lang) `(,lang . t))
    '(awk C haskell perl python R shell sqlite emacs-lisp)))
  (org-default-notes-file "~/org/capture.org")
  (org-habit-show-all-today t)
  (org-archive-location (concat "arkiv/"
				(format-time-string "%Y" (current-time))
				"/%s::"))
  (org-catch-invisible-edits 'smart)
  ;; Add org-habit and ox-beamer to the standard list of modules.
  (org-modules
   '(org-habit
     ol-w3m
     ol-bbdb
     ol-bibtex
     ol-docview
     ol-gnus
     ol-info
     ol-irc
     ol-mhe
     ol-rmail
     ol-eww
     ox-beamer))
  (org-todo-keywords
   '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))
  :hook
  (org-mode-hook . flyspell-mode)
  (org-mode-hook . writegood-mode)
  (org-mode-hook . org-indent-mode)
  (org-mode-hook . display-line-numbers-mode))

(use-package org-agenda
  :bind
  ("C-c a" . 'org-agenda)
  :init
  (defun my/org-agenda-follow-mode (&rest r)
    (org-agenda-follow-mode))
  (advice-add 'org-agenda-list :after #'my/org-agenda-follow-mode)
  (advice-add 'org-agenda-redo-all :after #'my/org-agenda-follow-mode)
  :custom
  ;; Note some items are defined by custom-set-variables.
  (org-agenda-include-diary t) ;; but I just use journal.org instead
  (org-agenda-show-log t)
  (org-agenda-span 'week)
  (org-agenda-todo-ignore-deadlines 'near)
  (org-agenda-todo-ignore-scheduled 'all))

(use-package org-super-agenda)

(use-package org-capture
  :bind
  ("C-c c" . 'org-capture)
  :custom
  (org-capture-templates
   '(("c" "Capture"
      entry (file "capture.org")
      "* %?\n  %i\n  %a")
     ("t" "Todo"
      entry (file+headline "todo.org" "Tasks")
      "* TODO %?")
     ("h" "Planlagt hendelse"
      entry (file+headline "hendelser.org" "Planlagte")
      "* %^T %?\n"
      :prepend 't)
     ("l" "Logget hendelse"
      entry (file+headline "hendelser.org" "Logget")
      "* %^T %?\n")
     ("j" "Journal"
      entry (file+olp+datetree "journal.org")
      "* %?")
     )))

(use-package ob-core
  :custom
  (org-confirm-babel-evaluate nil))

(use-package ob-exp
  :custom
  (org-export-use-babel t))

;; Support dead keys (like the tilde key) in the presence of the gnome
;; input method manager (don't really know which one it is).
(use-package iso-transl)

(use-package nov
  :custom
  (nov-text-width nil)
  (nov-variable-pitch t)
  :mode ("\\.epub\\'" . nov-mode))

(use-package markdown-mode
  :hook
  (markdown-mode-hook . visual-line-mode)
  (markdown-mode-hook . writegood-mode)
  (markdown-mode-hook . flyspell-mode))

(use-package f90
  :custom
  (f90-beginning-ampersand nil)
  (f90-do-indent 2)
  (f90-if-indent 2)
  (f90-type-indent 2)
  :hook
  (f90-mode-hook
   . (lambda nil
       (f90-add-imenu-menu)
       (setf fill-column 132))))

;; (use-package ido
;;   :custom
;;   (ido-enable-flex-matching t)
;;   (ido-everywhere t)
;;   :init
;;   (ido-mode 1))

(use-package which-key
  :diminish
  :init
  (which-key-mode t)
  :custom
  (which-key-delay-functions
   '(my/which-key-delay-lsp
     my/which-key-delay-default))
  (which-key-idle-delay 0.1))

(use-package projectile
  :diminish
  :init
  (projectile-mode t))

(use-package calendar
  :config
  (make-directory "~/org" 'make-parents)
  :custom
  (diary-date-forms
   '((month "/" day "[^/0-9]")
     (monthname " *" day "[^,0-9]")
     (monthname " *" day ", *" year "[^0-9]")
     (dayname "\\W")))
  (diary-file "~/org/diary")
  (calendar-week-start-day 1))

(use-package solar
  :custom
  (calendar-time-display-form
   '(24-hours
     ":" minutes
     (if time-zone " (") time-zone (if time-zone ")"))))

(use-package haskell-mode
  :hook
  ((haskell-mode-hook . interactive-haskell-mode)
   (haskell-mode-hook . display-line-numbers-mode)
   (haskell-literate-mode-hook . lsp-deferred)
   (haskell-literate-mode-hook . display-line-numbers-mode)))

(use-package lsp-haskell
  ;; Having experimented with autoformatting on save using ormolu,
  ;; fourmolu and brittany, I think I'll just *not* autoformat Haskell
  ;; code.
  ;;
  ;; :config
  ;; (defun lsp-haskell-mode-install-save-hooks ()
  ;;   (add-hook 'before-save-hook #'lsp-format-buffer t t))
  ;; :custom
  ;; (lsp-haskell-formatting-provider "ormolu")
  :hook
  ((haskell-mode-hook . lsp-deferred)))
  ;; (haskell-mode-hook . lsp-haskell-mode-install-save-hooks)))

(use-package tidal)

(use-package go-mode
  :init
  :config
  (defun lsp-go-mode-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :hook
  ((go-mode-hook . lsp-go-mode-install-save-hooks)
   (go-mode-hook . lsp-deferred)
   (go-mode-hook . display-line-numbers-mode)))

(use-package rust-mode
  :custom
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-rust-analyzer-server-display-inlay-hints 't)
  :hook
  ((rust-mode-hook . lsp-deferred)
   (rust-mode-hook . display-line-numbers-mode)))

(use-package rustic
  :custom
  (rustic-format-trigger 'on-save))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix my/lsp-prefix)
  :hook ((lsp-mode-hook . lsp-enable-which-key-integration)
	 (lsp-mode-hook . (lambda nil
			    (setq read-process-output-max (* 1024 1024)))))
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :commands lsp-ui-mode)

;; (use-package helm-lsp
;;   :commands helm-lsp-workspace-symbol)

(use-package lsp-treemacs
  :config
  (lsp-treemacs-sync-mode 1)
  :commands lsp-treemacs-errors-list)

;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package ess)

(use-package hippie-exp
  :init
  ;; Replace dabbrev-expand with hippie-expand. By default this means
  ;; rebinding M-/.
  (global-set-key [remap dabbrev-expand] 'hippie-expand))

(use-package doc-view
  :custom
  (doc-view-resolution 400))

(use-package tramp
  :custom
  (tramp-default-method "ssh")
  (tramp-ssh-controlmaster-options
   (string-join
    '("-o ControlMaster=auto"
      "-o ControlPath='/var/run/user/%i/ssh-%C'"
      "-o ControlPersist=600")
    " ")))

(use-package dired-x
  ;; Built-in dired functionality that weirdly is not turned on by
  ;; default.
  )

(use-package yasnippet
  :init
  (yas-global-mode 1))

(use-package dumb-jump
  :hook
  (xref-backend-functions . dumb-jump-xref-activate))

(use-package racket-mode)

(use-package winner
  ;; Enable window undo with C-c <left> and redo with C-c <right>.
  ;; Bundled with emacs.
  :init
  (winner-mode 1))

(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :config
  (make-directory "~/org/roam" 'parents)
  (org-roam-db-autosync-mode 1)
  :bind
  (("C-c r" . org-roam-capture)
   ("C-c f" . org-roam-node-find)
   ("C-c l" . org-roam-node-insert))) ;; Er dette krasj med lsp-mode?

(use-package org-download
  :after org
  :bind
  (:map org-mode-map
        (("s-Y" . org-download-screenshot)
         ("s-y" . org-download-yank))))

(use-package org-fold
  :custom
  (org-fold-catch-invisible-edits 'smart nil nil "Customized with use-package org"))

(use-package docker
  :bind
  ("C-c d" . docker))

(defun my/popup-new-vterm ()
  "Pop up a new vterm i a new frame (gui) or window (terminal)"
  (interactive)
  (if (window-system)
      (progn
	(select-frame-set-input-focus (make-frame-on-current-monitor))
	(vterm 'make-new-term))
    (vterm-other-window 'make-new-term)))
(use-package vterm
  :bind
  ("C-c t" . my/popup-new-vterm))

(use-package window-number
  :config
  ;; Switch windows with M-number
  ;(window-number-mode 1) ;; very distinct visual indicator
  (window-number-meta-mode 1))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :custom
  ;; Kjør orderless først, med fallback til basic.
  (completion-styles '(orderless basic))
  ;; tramp krever dog at vi kjører basic først, så overstyr stil for
  ;; fil-baserte operasjoner. Tar også med partial-completion her i
  ;; tillegg til basic, så vi får støtte for å matche f.eks. "/u/s/l"
  ;; for "/usr/share/local".
  ;;
  ;; Ref. README på https://github.com/oantolin/orderless
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult)

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package gdscript-mode
  :hook
  (before-save-hook . gdscript-format-buffer))

(use-package gnuplot-mode
  :config
  (setq gnuplot-program "/run/current-system/sw/bin/gnuplot"))

(use-package gleam-ts-mode)


;; Meow kommer helt uten tastebindinger i utgangspunktet, men i repoet
;; sitt har de noen forslag til hvilke ~meow-setup~ du kan lage. Jeg
;; har kopiert qwerty-layouten deres siden jeg ikke har noen ide om
;; hva slags bindinger som gir mening, og jeg tror de vil ligne litt
;; på vim.
;;
;; https://github.com/meow-edit/meow
;; https://github.com/meow-edit/meow/blob/master/KEYBINDING_QWERTY.org
(use-package meow
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (meow-setup)
  (meow-global-mode))

(use-package emacs
  :init
  ;; Mye bedre scrolling i grafisk modus
  (pixel-scroll-precision-mode 1)
  :custom
  (before-save-hook '(delete-trailing-whitespace))
  (column-number-mode t)
  (compilation-auto-jump-to-first-error t)
  (compilation-scroll-output 'first-error)
  (enable-local-variables :safe)
  (global-subword-mode t)
  (inhibit-startup-screen t)
  (initial-major-mode 'org-mode)
  (initial-scratch-message nil)
  (ls-lisp-use-insert-directory-program nil)
  (make-backup-files nil)
  (menu-bar-mode nil)
  (recenter-positions '(0.4 0.1 0.9))
  (sentence-end-double-space nil)
  (show-paren-mode t)
  (system-time-locale "C.UTF-8" t)
  (tab-always-indent 'complete)
  (tool-bar-mode nil)
  (shell-command-prompt-show-cwd t)
  :bind
  ("<f5>" . 'compile))
