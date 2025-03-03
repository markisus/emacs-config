;; Visuals
(tool-bar-mode -1)
(menu-bar-mode -1)
(set-face-attribute 'default nil :height 150)
(pixel-scroll-precision-mode) ;; scroll by pixel instead of line
(set-scroll-bar-mode nil)

;; indent / movement
;; (setq-default indent-tabs-mode nil)
;; (setq-default tab-width 2)
;; (setq js-indent-level 2)
;; (setq subword-mode 1)

;; Fix emacs annoyances =====================================
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq create-lockfiles nil) 
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
;; prevent accidental minimization from fatfingering ctrl z
(global-set-key (kbd "C-z") nil) 
(global-set-key (kbd "C-x C-z") nil)
;; Garbage-collect on focus-out, Emacs should feel snappier.
(unless (version< emacs-version "27.0")
  (add-function :after after-focus-change-function
                (lambda ()
                  (unless (frame-focus-state)
                    (garbage-collect)))))

;; my-mode begin ====================================================
;; Main use is to have my key bindings have the highest priority
;; https://github.com/kaushalmodi/.emacs.d/blob/master/elisp/modi-mode.el
(defvar my-mode-map (make-sparse-keymap)
  "Keymap for `my-mode'.")
;;;###autoload
(define-minor-mode my-mode
  "A minor mode so that my key settings override annoying major modes."
  ;; If init-value is not set to t, this mode does not get enabled in
  ;; `fundamental-mode' buffers even after doing \"(global-my-mode 1)\".
  ;; More info: http://emacs.stackexchange.com/q/16693/115
  :init-value t
  :lighter " my-mode"
  :keymap my-mode-map)
;;;###autoload
(define-globalized-minor-mode global-my-mode my-mode my-mode)
;; https://github.com/jwiegley/use-package/blob/master/bind-key.el
;; The keymaps in `emulation-mode-map-alists' take precedence over
;; `minor-mode-map-alist'
(add-to-list 'emulation-mode-map-alists `((my-mode . ,my-mode-map)))
;; Turn off the minor mode in the minibuffer
(defun turn-off-my-mode ()
  "Turn off my-mode."
  (my-mode -1))
(add-hook 'minibuffer-setup-hook #'turn-off-my-mode)
(provide 'my-mode)
;; my-mode end ==========================================================


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

;; shell / compile mode stuff for compilation/comint
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)
(setq compilation-scroll-output 'first-error)
(setq compilation-environment '("TERM=xterm-256color"))
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

;; (defun wsl-copy (start end)
;;   (interactive "r")
;;   (shell-command-on-region start end "clip.exe"))
;; (defun wsl-paste ()
;;   (interactive)
;;   (let ((wslbuffername "wsl-temp-buffer"))
;;     (get-buffer-create wslbuffername)
;;     (with-current-buffer wslbuffername
;;       (insert (let ((coding-system-for-read 'dos))
;;                 ;; TODO: put stderr somewhere else
;;                 (shell-command "powershell.exe -command 'Get-Clipboard' 2> /dev/null" wslbuffername nil))))
;;     (insert-buffer wslbuffername)
;;     (kill-buffer wslbuffername)))

;; ;; (set-face-attribute 'default nil :height 80)
(setq c-default-style "linux"
      c-indent-level 4
      c-basic-offset 4)
(add-hook 'c-mode-common-hook (lambda () (c-set-offset 'innamespace 0)))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cuh\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.qml\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.h'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))


(setq package-archives
      '(
	("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))
(package-install-selected-packages)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(abbrev-suggest t)
 '(avy-timeout-seconds 0.3)
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
 '(custom-enabled-themes '(gruvbox-dark-hard))
 '(custom-safe-themes
   '("8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378" "0a2168af143fb09b67e4ea2a7cef857e8a7dad0ba3726b500c6a579775129635" default))
 '(doc-view-resolution 1200)
 '(doc-view-scale-internally t)
 '(eglot-ignored-server-capabilities
   '(:documentRangeFormattingProvider :documentOnTypeFormattingProvider :foldingRangeProvider :inlayHintProvider))
 '(eldoc-echo-area-display-truncation-message nil)
 '(eldoc-echo-area-use-multiline-p 'truncate-sym-name-if-fit)
 '(eldoc-idle-delay 1000000000)
 '(ggtags-sort-by-nearness t)
 '(global-eldoc-mode nil)
 '(org-catch-invisible-edits 'smart)
 '(org-fold-catch-invisible-edits 'smart)
 '(package-selected-packages
   '(0x0 clean-kill-ring gruvbox-theme consult-eglot-embark consult-eglot embark-consult embark catppuccin-theme consult popon quelpa corfu orderless vertico gptel multiple-cursors auto-sudoedit bazel eglot ace-window 0blayout yasnippet-snippets ivy-xref ivy-yasnippet xterm-color auctex solidity-mode flycheck lsp-ivy zig-mode lsp-mode magit proof-general svelte-mode flymd zoom-window counsel-etags yasnippet esup protobuf-mode hungry-delete clang-format counsel swiper ivy google-c-style modern-cpp-font-lock ggtags company mode-line-bell avy))
 '(shell-file-name "/bin/bash")
 '(term-suppress-hard-newline t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(mode-line-bell-mode t)
(setq markdown-fontify-code-blocks-natively t)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c C-c") 'wdired-change-to-wdired-mode))

;; (global-company-mode 1)
;; (ivy-mode 1)
;; (use-package ivy-xref
;;   :ensure t
;;   :init
;;   ;; xref initialization is different in Emacs 27 - there are two different
;;   ;; variables which can be set rather than just one
;;   (when (>= emacs-major-version 27)
;;     (setq xref-show-definitions-function #'ivy-xref-show-defs))
;;   ;; Necessary in Emacs <27. In Emacs 27 it will affect all xref-based
;;   ;; commands other than xref-find-definitions (e.g. project-find-regexp)
;;   ;; as well
;;   (setq xref-show-xrefs-function #'ivy-xref-show-xrefs))


(yas-global-mode 1)


;; (defun advice-xref-push-before (orig-fun &rest args)
;;   "Advice function to push marker to xref stack before calling bazel-find-build-file."
;;   (xref-push-marker-stack)
;;   (apply orig-fun args))
;; (advice-add 'bazel-find-build-file :around #'advice-xref-push-before)

(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

(use-package vertico
  :ensure t
  :config
  (vertico-mode 1)
  )
(define-key vertico-map (kbd "C-c RET") #'vertico-exit-input)

(use-package corfu
  :ensure t
  :config
  (global-corfu-mode)
  )
(quelpa '(popon :fetcher git
		:url "https://codeberg.org/akib/emacs-popon.git"))
(quelpa '(corfu-terminal
	  :fetcher git
	  :url "https://codeberg.org/akib/emacs-corfu-terminal.git"))
(unless (display-graphic-p)
  (corfu-terminal-mode +1))
(setq corfu-auto t
      corfu-quit-no-match 'separator) ;; or t

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :ensure t
  :config
  (setq xref-show-xrefs-function 'consult-xref)
  (setq xref-show-definitions-function 'consult-xref)
  )

(use-package embark
  :ensure t
  :bind
  (("C-c SPC" . embark-act)         ;; pick some comfortable binding
   ("C-c C-c SPC" . embark-dwim)        ;; good alternative: M-.
   )
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
	       '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
		 nil
		 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(with-eval-after-load 'embark
  (with-eval-after-load 'consult-eglot
    (require 'consult-eglot-embark)
    (consult-eglot-embark-mode)))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
	      ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(keymap-set my-mode-map "M-i" 'consult-imenu)
(keymap-set my-mode-map "C-c M-i" 'consult-imenu-multi)
(keymap-set my-mode-map "C-c g" 'consult-ripgrep)
(keymap-set my-mode-map "M-g g" 'consult-goto-line)
(keymap-set my-mode-map "M-g M-g" 'consult-goto-line)

(keymap-set my-mode-map "C-x o" 'ace-window)

;; swiper has more intuitive behavior than consult-line
;; (keymap-set my-mode-map "C-s" 'consult-line)
(keymap-set my-mode-map "C-s" 'swiper) 

(keymap-set my-mode-map "C-c C-s" 'consult-line-multi)
(keymap-set my-mode-map "C-c f" 'project-find-file)
(keymap-set my-mode-map "C-c o C-c f" 'project-find-file-other)
(keymap-set my-mode-map "C-y" 'consult-yank-pop)
(keymap-set my-mode-map "M-y" 'consult-yank-pop)

(keymap-set my-mode-map "C-r" nil) ;; unbind reverse search, since we have swiper
(keymap-set my-mode-map "C-r r" 'gptel-rewrite)
(keymap-set my-mode-map "C-r t" 'gptel)
(keymap-set my-mode-map "C-r a" 'gptel-add)
(keymap-set my-mode-map "C-r s" 'gptel-send)
(keymap-set my-mode-map "C-r m" 'gptel-menu)
(keymap-set my-mode-map "C-r k" 'gptel-abort)

;; todo: remove usage of kbd, eg
;; (global-set-key (kbd "KEYSTRING") BINDING) => (keymap-set my-mode-map "KEYSTRING" BINDING)
(keymap-set my-mode-map  "M-." 'xref-find-definitions)
(keymap-set my-mode-map  "C-c o M-." 'xref-find-definitions-other-window)
(keymap-set my-mode-map  "M-/" 'xref-find-references)

;; do not move cursor to the xref
(advice-add 'xref-pop-to-location :around
	    (lambda (orig-fun &rest args)
	      (let ((win (selected-window)))
		(apply orig-fun args)
		(select-window win))))


;; analogous to C-v, M-v for scroll
(keymap-set my-mode-map  "M-," 'xref-go-back)
(keymap-set my-mode-map  "C-," 'xref-go-forward)

(keymap-set my-mode-map  "C-'" 'avy-goto-char-timer)
(keymap-set my-mode-map  "C-;" 'avy-goto-line)

(keymap-set my-mode-map  "C-c r" 'revert-buffer)
(keymap-set my-mode-map  "C-c x" 'replace-rectangle)
(keymap-set my-mode-map  "C-c c" 'compile)

(keymap-set my-mode-map  "C->" 'mc/mark-next-like-this)
(keymap-set my-mode-map  "C-<tab>" 'yas-expand)

(keymap-set my-mode-map  "C-x M-." 'ff-find-other-file)

(keymap-set my-mode-map  "C-c C-d" 'hungry-delete-forward)

(keymap-set my-mode-map  "C-c s" 'magit-status)
(keymap-set my-mode-map  "C-c d" 'duplicate-line)
(keymap-set my-mode-map  "C-q" 'clang-format-buffer)
(keymap-set my-mode-map  "M-s" 'sort-lines)

(keymap-set my-mode-map  "C-c C-e" 'eldoc-print-current-symbol-info)
;; (global-set-key (kbd "C-c o") 'execute-other-window-version)

;; (global-set-key (kbd "<backtab>") 'bazel-find-build-file)
;; (global-set-key (kbd "C-c b") 'bazel-find-build-file)
;; (global-set-key (kbd "C-<return>") 'up-list)
;; (global-set-key (kbd "S-<return>") 'backward-down-list)

;; (defun backward-down-list ()
;;   "Like down-list, except down into the previous sexp"
;;   (interactive)
;;   (backward-sexp) (down-list))

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

;; gptel customizization =================================================
(setq
 gptel-model   'test
 gptel-backend (gptel-make-openai "llama-cpp"
                 :stream t
                 :protocol "http"
                 :host "localhost:8080"
                 :models '(test)))

(defun my-gptel-post-response (beg end)
  (when (bound-and-true-p gptel-mode) (end-of-buffer))
  (message "Response Done!")
  )

;; Custom rewrite prompt for gptel
(defun generate-llm-rewrite-prompt ()
  (let* ((lang (downcase (gptel--strip-mode-suffix major-mode)))
         (article (if (and lang (not (string-empty-p lang))
                           (memq (aref lang 0) '(?a ?e ?i ?o ?u)))
                      "an" "a")))
    (if (derived-mode-p 'prog-mode)
        (format (concat "You are an AI %s expert living inside an IDE plugin.\n"
                        "Your responsibility is to rewrite the code in place. "
                        "The code is a small section of a larger source document. Follow these directions.\n"
                        "- Never preface your response with an introductory acknowledgment like \"Certainly\".\n"

                        ;; Choose between code-fence or non code-fence replies.
                        ;; Many models like to write code-fences even when instructed not to.

                        ;;; No code fence prompt. If code-fence is included, a post processing step removes it.
                        "- Respond only in plaintext %s code, without any markdown formatting. "
                        "Your response should never start with a backtick symbol. Choose a different starting character.\n"

                        ;;; Code fence prompt
                        ;; "- Respond only in plaintext %s code, surrounded by markdown code fences (```%s).\n"

                        "- Do not ask for further clarification, and make any assumptions you need to follow instructions.\n"
                        "- Do not #include any header files. They are already included in the larger source document.\n"
                        "- If the task is not given, or it's just to \"Rewrite\", then for any todo comments in the code and complete those todos.\n"
                        "Your code will be pasted in full back into the source document AS-IS. Any non-code parts of your response "
                        "will trigger a compilation failure of life-critical software systems, resulting in serious injury or death. "
                        )
                lang lang lang)
      (concat
       (if (string-empty-p lang)
           "You are an editor."
         (format "You are %s %s editor." article lang))
       "  Follow my instructions and improve or rewrite the text I provide."
       "  Generate ONLY the replacement text,"
       " without any explanation or markdown code fences.")))
  )

(add-hook 'gptel-rewrite-directives-hook 'generate-llm-rewrite-prompt)

(defun cleanup-llm-rewrite-response (beg end)
  "Remove Markdown-style code fences from the GPTel rewrite response."
  (save-excursion
    ;; Remove closing fence
    (goto-char end)
    (beginning-of-line)
    (when (looking-at "^```$")
      (delete-region (line-beginning-position) (line-end-position))
      )

    ;; Remove opening fence
    (goto-char beg)
    (when (looking-at "^```.*$")
      (delete-region (line-beginning-position) (line-end-position))
      (delete-char 1) ;; remove newline
      )
    )
  )

(eval-after-load "gptel"
  '(progn
     (define-key gptel-mode-map (kbd "RET") 'gptel-send)
     (define-key gptel-mode-map (kbd "C-j") 'newline)
     (add-hook 'gptel-post-response-functions 'my-gptel-post-response)
     (add-hook 'gptel-post-rewrite-functions #'cleanup-llm-rewrite-response)
     )
  )
;; end gptel customization ================================================


(defun visit-init-file ()
  "Edit the file that initializes your Emacs configuration."
  (interactive)
  (find-file "~/.emacs"))

;; pop mark tries to pop back to the buffer the mark was in
(define-advice pop-global-mark (:around (pgm) use-display-buffer)
  "Make `pop-to-buffer' jump buffers via `display-buffer'."
  (cl-letf (((symbol-function 'switch-to-buffer)
	     #'pop-to-buffer))
                    (funcall pgm)))

(switchy-window-minor-mode 1)
(keymap-set my-mode-map  "C-x o" 'switchy-window)
(keymap-set my-mode-map  "M-o" 'ace-window)

(require 'ace-window)
(defun ace-window-one-command ()
  (interactive)
  (let ((win (aw-select " ACE")))
    (when (windowp win)
      (with-selected-window win
	(let* ((command (key-binding
			 (read-key-sequence
			  (format "Run in %s..." (buffer-name)))))
	       (this-command command))
	  (call-interactively command))))))

(defun ace-window-prefix ()
  "Use `ace-window' to display the buffer of the next command.
The next buffer is the buffer displayed by the next command invoked
immediately after this command (ignoring reading from the minibuffer).
Creates a new window before displaying the buffer.
When `switch-to-buffer-obey-display-actions' is non-nil,
`switch-to-buffer' commands are also supported."
  (interactive)
  (display-buffer-override-next-command
   (lambda (buffer _)
     (let (window type)
       (setq
	window (aw-select (propertize " ACE" 'face 'mode-line-highlight))
	type 'reuse)
       (cons window type)))
   nil "[ace-window]")
    (message "Use `ace-window' to display next command buffer..."))

(keymap-set my-mode-map "C-c o" 'ace-window-one-command)
(keymap-set my-mode-map "C-c C-o" 'ace-window-prefix)


;; (keymap-set my-mode-map "C-=" 'enlarge-window)
;; (keymap-set my-mode-map "C--" 'shrink-window)
;; (keymap-set my-mode-map "C-+" 'enlarge-window-horizontally)
;; (keymap-set my-mode-map "C-_" 'shrink-window-horizontally)
;; (keymap-set my-mode-map "C-/" 'undo)
