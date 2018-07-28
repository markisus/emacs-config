;kill cruft
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)

(set-face-attribute 'default nil :height 200)
(setq c-default-style "linux"
      c-basic-offset 4)

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.qml\\'" . javascript-mode))

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
 '(company-backends
   (quote
    (company-bbdb company-nxml company-css company-eclim company-semantic company-xcode company-cmake company-capf company-files
		  (company-dabbrev-code company-gtags company-etags company-keywords)
		  company-oddmuse company-dabbrev)))
 '(coq-compile-before-require nil)
 '(custom-enabled-themes (quote (wombat)))
 '(doc-view-resolution 1200)
 '(doc-view-scale-internally t)
 '(ggtags-sort-by-nearness t)
 '(org-catch-invisible-edits (quote smart))
 '(package-selected-packages
   (quote
    (counsel swiper ivy google-c-style modern-cpp-font-lock ggtags yasnippet company mode-line-bell avy)))
 '(term-suppress-hard-newline t)
 '(which-function-mode t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(which-func ((t (:inherit font-lock-function-name-face)))))

(global-set-key (kbd "C-:") 'avy-goto-char-2)

;; Open .v files with Proof General's Coq mode
(load "~/.emacs.d/lisp/PG/generic/proof-site")

(mode-line-bell-mode t)

(global-set-key [remap dabbrev-expand] 'hippie-expand)

(add-to-list 'load-path "~/.emacs.d/lisp") ;; for gtags.el, needed by
				      ;; ggtags.el copied from gnu
				      ;; global installation
(add-hook 'prog-mode-hook
	  (lambda () (ggtags-mode t)))

(add-hook 'prog-mode-hook
	  (lambda () (company-mode t)))

(yas-global-mode 1)

(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)

(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "C-c x") 'replace-rectangle)
(global-set-key (kbd "C-c c") 'compile)

(defun duplicate-line ()
  "Duplicate current line"
  (interactive)
  (kill-whole-line)
  (yank)
  (yank))
(global-set-key (kbd "C-c d") 'duplicate-line)
