;kill cruft
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq js-indent-level 2)

; put all backup files into the /temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; (set-face-attribute 'default nil :height 80)
(setq c-default-style "linux"
      c-indent-level 4
      c-basic-offset 4)
(add-hook 'c-mode-common-hook (lambda () (c-set-offset 'innamespace 0)))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.qml\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("/BUILD\\'" . bazel-mode))
(add-to-list 'auto-mode-alist '("/WORKSPACE\\'" . bazel-mode))
(add-to-list 'auto-mode-alist '("\\.h'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))

;; ;; Added by Package.el.  This must come before configurations of
;; ;; installed packages.  Don't delete this line.  If you don't want it,
;; ;; just comment it out by adding a semicolon to the start of the line.
;; ;; You may delete these explanatory comments.
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
 '(company-backends
   (quote
    (company-capf company-files
                  (company-dabbrev-code company-etags company-keywords))))
 '(company-idle-delay 0.0)
 '(coq-compile-before-require nil)
 '(custom-enabled-themes (quote (wombat)))
 '(doc-view-resolution 1200)
 '(doc-view-scale-internally t)
 '(ggtags-sort-by-nearness t)
 '(org-catch-invisible-edits (quote smart))
 '(package-selected-packages
   (quote
    (proof-general svelte-mode flymd zoom-window counsel-etags yasnippet-snippets yasnippet esup protobuf-mode magit hungry-delete bazel-mode clang-format counsel swiper ivy google-c-style modern-cpp-font-lock ggtags company mode-line-bell avy)))
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

;; (add-to-list 'load-path "~/.emacs.d/lisp") ;; for gtags.el, needed by
;; 				      ;; ggtags.el copied from gnu
;; 				      ;; global installation
;; (add-hook 'prog-mode-hook
;; 	  (lambda () (ggtags-mode t)))
;; (add-hook 'prog-mode-hook
;; 	  (lambda () (company-mode t)))

(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)

;; (add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; (setq ivy-use-virtual-buffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-rg)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "M-.") 'counsel-etags-find-tag-at-point)

(global-set-key (kbd "C-:") 'avy-goto-char-timer)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "C-c x") 'replace-rectangle)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-x M-.") 'ff-find-other-file)
(global-set-key (kbd "C-c C-d") 'hungry-delete-forward)
;; prevent python mode from rebinding hungry delete
(eval-after-load "python-mode"
  '(define-key python-mode-map (kbd "C-c C-d") nil))
(global-set-key (kbd "C-c s") 'magit-status)
(global-set-key (kbd "C-c d") 'duplicate-line)
(global-set-key (kbd "C-q") 'clang-format-buffer)
(global-set-key [remap dabbrev-expand] 'hippie-expand)
(global-set-key (kbd "C-c z") 'zoom-window-zoom)
(global-set-key (kbd "C-c y") 'counsel-yank-pop)

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

