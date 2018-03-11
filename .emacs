;kill cruft
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)

(set-face-attribute 'default nil :height 200)
(setq c-default-style "linux"
      c-basic-offset 4)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq package-archives
      '(
	("gnu" . "https://elpa.gnu.org/packages/")
	("marmalade" . "https://marmalade-repo.org/packages/")
	("melpa" . "https://melpa.org/packages/")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coq-compile-before-require nil)
 '(custom-enabled-themes (quote (wombat)))
 '(doc-view-resolution 1200)
 '(doc-view-scale-internally t)
 '(ggtags-sort-by-nearness t)
 '(ido-enable-flex-matching t)
 '(ido-mode (quote both) nil (ido))
 '(package-selected-packages (quote (ggtags yasnippet company mode-line-bell avy)))
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

(add-to-list 'load-path "~/.emacs.d") ;; for gtags.el, needed by
				      ;; ggtags.el copied from gnu
				      ;; global installation

(add-hook 'prog-mode-hook
	  (lambda () (ggtags-mode 1)))

(add-hook 'prog-mode-hook
	  (lambda () (company-mode 1)))
