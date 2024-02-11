;kill cruft
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq js-indent-level 2)
(setq subword-mode 1)

(setq create-lockfiles nil) ; prevent #. files

(set-face-attribute 'default nil :height 150)

; put all backup files into the /temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Garbage-collect on focus-out, Emacs should feel snappier.
(unless (version< emacs-version "27.0")
  (add-function :after after-focus-change-function
                (lambda ()
                  (unless (frame-focus-state)
                    (garbage-collect)))))

;; (add-hook 'window-setup-hook #'delete-other-windows)

;; ; faster startup for large fonts?
;; (setq frame-inhibit-implied-resize t)

;; ----------------
;; UTF-8 Everywhere
;; ================
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; ; shell / compile mode stuff for compilation/comint
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
(setq compilation-scroll-output 'first-error)
(setq compilation-environment '("TERM=xterm-256color"))
(require 'ansi-color)
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

;; (pixel-scroll-precision-mode) ; scroll by pixel instead of line
(global-set-key "\C-z" nil) ; prevent accidental minimization from fatfingering ctrl z
(global-set-key (kbd "C-x C-z") nil) ; prevent accidental minimization from fatfingering ctrl z

(defun wsl-copy (start end)
  (interactive "r")
  (shell-command-on-region start end "clip.exe"))

(defun wsl-paste ()
  (interactive)
  (let ((wslbuffername "wsl-temp-buffer"))
    (get-buffer-create wslbuffername)
    (with-current-buffer wslbuffername
      (insert (let ((coding-system-for-read 'dos))
                ;; TODO: put stderr somewhere else
                (shell-command "powershell.exe -command 'Get-Clipboard' 2> /dev/null" wslbuffername nil))))
    (insert-buffer wslbuffername)
    (kill-buffer wslbuffername)))

;; ;; (set-face-attribute 'default nil :height 80)
(setq c-default-style "linux"
      c-indent-level 4
      c-basic-offset 4)
(add-hook 'c-mode-common-hook (lambda () (c-set-offset 'innamespace 0)))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.qml\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.h'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq package-archives
      '(
	("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(abbrev-suggest t)
 '(avy-timeout-seconds 0.1)
 '(bazel-command '("send_bazel_command.py"))
 '(bazel-fix-visibility 'ask)
 '(cc-other-file-alist
   '(("\\.cc\\'"
      (".hh" ".h"))
     ("\\.hh\\'"
      (".cc" ".C" ".CC" ".cxx" ".cpp" ".c++"))
     ("\\.c\\'"
      (".h"))
     ("\\.m\\'"
      (".h"))
     ("\\.h\\'"
      (".c" ".cc" ".C" ".CC" ".cxx" ".cpp" ".c++" ".m"))
     ("\\.C\\'"
      (".H" ".hh" ".h"))
     ("\\.H\\'"
      (".C" ".CC"))
     ("\\.CC\\'"
      (".HH" ".H" ".hh" ".h"))
     ("\\.HH\\'"
      (".CC"))
     ("\\.c\\+\\+\\'"
      (".h++" ".hh" ".h"))
     ("\\.h\\+\\+\\'"
      (".c++"))
     ("\\.cpp\\'"
      (".h" ".hpp" ".hh"))
     ("\\.hpp\\'"
      (".cpp"))
     ("\\.cxx\\'"
      (".hxx" ".hh" ".h"))
     ("\\.hxx\\'"
      (".cxx"))))
 '(company-backends
   '(company-capf company-files
                  (company-dabbrev-code company-etags company-keywords)))
 '(company-idle-delay 0.0)
 '(compilation-auto-jump-to-first-error t)
 '(coq-compile-before-require nil)
 '(counsel-yank-pop-preselect-last t)
 '(custom-enabled-themes '(wombat))
 '(doc-view-resolution 1200)
 '(doc-view-scale-internally t)
 '(eglot-ignored-server-capabilities
   '(:documentRangeFormattingProvider :documentOnTypeFormattingProvider :foldingRangeProvider :inlayHintProvider))
 '(ggtags-sort-by-nearness t)
 '(org-catch-invisible-edits 'smart)
 '(package-selected-packages
   '(eglot ace-window 0blayout yasnippet-snippets ivy-xref ivy-yasnippet xterm-color auctex solidity-mode flycheck lsp-ivy zig-mode lsp-mode magit proof-general svelte-mode flymd zoom-window counsel-etags yasnippet esup protobuf-mode hungry-delete clang-format counsel swiper ivy google-c-style modern-cpp-font-lock ggtags company mode-line-bell avy))
 '(shell-file-name "/bin/bash")
 '(term-suppress-hard-newline t))

(unless package-archive-contents
  (package-refresh-contents))
(package-install-selected-packages)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(mode-line-bell-mode t)
(yas-global-mode 1)
(global-company-mode 1)
(ivy-mode 1)

(use-package ivy-xref
  :ensure t
  :init
  ;; xref initialization is different in Emacs 27 - there are two different
  ;; variables which can be set rather than just one
  (when (>= emacs-major-version 27)
    (setq xref-show-definitions-function #'ivy-xref-show-defs))
  ;; Necessary in Emacs <27. In Emacs 27 it will affect all xref-based
  ;; commands other than xref-find-definitions (e.g. project-find-regexp)
  ;; as well
  (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))

(use-package yasnippet
  :ensure
  :bind
  (:map yas-minor-mode-map
        ("C-<tab>". yas-expand)
        ([(tab)] . nil)
        ("TAB" . nil))
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode))

(require 'ivy-yasnippet)

(defun advice-xref-push-before (orig-fun &rest args)
  "Advice function to push marker to xref stack before calling bazel-find-build-file."
  (xref-push-marker-stack)
  (apply orig-fun args))

;; c++ stuff
(require 'bazel)
(advice-add 'bazel-find-build-file :around #'advice-xref-push-before)

(require 'cc-mode)
(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)

(require 'eglot)
(add-to-list 'eglot-server-programs '((c++-mode c-mode)
                                      ; WSL forwarding config
                                      . ("powershell.exe" "clangd --path-mappings=/mnt/c=/C:,/mnt/d=/D:")))
; todo: add zig

(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

;; (add-hook 'c++-mode-hook (lambda()())
;; ;; (add-hook 'c-mode-common-hook 'google-make-newline-indent)
(global-set-key (kbd "M-g n") 'next-error)

;; (setq ivy-use-virtual-buffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-rg)
(global-set-key (kbd "C-x l") 'counsel-locate)
;; (global-set-key (kbd "M-.") 'counsel-etags-find-tag-at-point)
(global-set-key (kbd "M-.") 'eglot-find-declaration)

(global-set-key (kbd "C-:") 'avy-goto-char-timer)
(global-set-key (kbd "C-;") 'avy-goto-line)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "C-c x") 'replace-rectangle)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-x M-.") 'ff-find-other-file)
(global-set-key (kbd "C-x M->") 'ff-find-other-file-other-window)
(global-set-key (kbd "C-c C-d") 'hungry-delete-forward)
;; prevent python mode from rebinding hungry delete
(eval-after-load "python-mode"
  '(define-key python-mode-map (kbd "C-c C-d") 'hungry-delete-forward))
(global-set-key (kbd "C-c s") 'magit-status)
(global-set-key (kbd "C-c d") 'duplicate-line)
(global-set-key (kbd "C-q") 'clang-format-buffer)
;; (global-set-key [remap dabbrev-expand] 'hippie-expand)
(global-set-key (kbd "C-y") 'counsel-yank-pop)
(global-set-key (kbd "M-s") 'sort-lines)
(global-set-key (kbd "<backtab>") 'bazel-find-build-file)
(global-set-key (kbd "C-<return>") 'up-list)
(global-set-key (kbd "S-<return>") 'backward-down-list)
(global-set-key (kbd "M-/") 'xref-find-references)

(defun backward-down-list ()
  "Like down-list, except down into the previous sexp"
  (interactive)
  (backward-sexp) (down-list))

(defun duplicate-line (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")
  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))
  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion
      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))
      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )
      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let
  ;; put the point in the lowest line and return
  (next-line arg))

;; (require 'lsp-mode)
;; (setq lsp-zig-zls-executable "~/zls/zls")
;; (add-hook 'zig-mode-hook #'lsp)
;; (eval-after-load "zig-mode"
;;   '(define-key zig-mode-map (kbd "M-.") 'lsp-find-definition))
