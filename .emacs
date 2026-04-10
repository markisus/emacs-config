;; Packaging Setup ==========================================
(setq use-package-always-ensure t)
(setq package-archives
      '(
	("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")))
;; (unless package-archive-contents
;;   (package-refresh-contents))
(use-package quelpa)
(use-package quelpa-use-package :after quelpa)

;; Visuals ===================================================
(tool-bar-mode -1)
(menu-bar-mode -1)
(pixel-scroll-precision-mode) ;; scroll by pixel instead of line
(set-scroll-bar-mode nil)
(set-face-attribute 'default nil
                    ;; :family "Fira Code" ;; https://github.com/tonsky/FiraCode
                    ;; :family "Source Code Pro" ;; https://github.com/adobe-fonts/source-code-pro
                    :family "Jetbrains Mono" 
                    :height 160)
(use-package gruvbox-theme
  :config
  (load-theme 'gruvbox-dark-medium t))
(display-time-mode 1)

;; Fix emacs annoyances =====================================
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq create-lockfiles nil) 
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)

;; fix weird startup issue in x11 where emacs does not think it has focus,
;; but it can still receive keyboard input, resulting incorrect cursor
;; rendering
(when (display-graphic-p)
  (add-hook 'window-setup-hook
            (lambda ()
              (select-frame-set-input-focus (selected-frame)))))

;; prevent accidental minimization from fatfingering ctrl z
(global-set-key (kbd "C-z") nil) 
(global-set-key (kbd "C-x C-z") nil)

;; setq default no tabs is overridden by certain modes like JSON mode.
(defun always-no-tabs ()
  (setq indent-tabs-mode nil))
(add-hook 'prog-mode-hook #'always-no-tabs)
(add-hook 'text-mode-hook #'always-no-tabs)

;; compilation-mode should auto-scroll to the first error
(setq compilation-scroll-output 'first-error)

;; on mac, the command (super) key is where the alt key usually is
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super) 

;; be able to type "y", "n" when usually emacs asks for "yes" or "no"
;; to confirm actions
(fset 'yes-or-no-p 'y-or-n-p)

(use-package mode-line-bell
  :init
  (mode-line-bell-mode))

;; use rg instead of grep
(setq grep-command "rg")

(use-package dired
  :ensure nil  ; built-in package
  :custom
  (dired-dwim-target t)  ; suggest other visible dired buffer as target
  :config
  ;; Optional: additional useful settings
  (setq dired-listing-switches "-alh")  ; human-readable file sizes
  (setq dired-recursive-copies 'always)  ; copy directories recursively without asking
  (setq dired-recursive-deletes 'always))  ; delete directories recursively without asking
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c C-c") 'wdired-change-to-wdired-mode)
  )
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c m") #'casual-dired-tmenu))

;; fix diff-mode for new and deleted files
;; Fix diff-mode to handle file creation in diffs
(with-eval-after-load 'diff-mode
  (defun diff-find-file-name (&optional old noprompt prefix)
    "Return the file corresponding to the current patch.
Non-nil OLD means that we want the old file.
Non-nil NOPROMPT means to prefer returning nil than to prompt the user.
PREFIX is only used internally: don't use it."
    (unless (equal diff-remembered-defdir default-directory)
      (setq-local diff-remembered-defdir default-directory)
      (setq-local diff-remembered-files-alist nil))
    (save-excursion
      (save-restriction
        (widen)
        (unless (looking-at diff-file-header-re)
          (or (ignore-errors (diff-beginning-of-file))
              (re-search-forward diff-file-header-re nil t)))
        (let ((fs (diff-hunk-file-names old)))
          (if prefix (setq fs (mapcar (lambda (f) (concat prefix f)) fs)))
          (or
           (cdr (assoc fs diff-remembered-files-alist))
           (cl-dolist (rf diff-remembered-files-alist)
             (let ((newfile (diff-merge-strings (caar rf) (car fs) (cdr rf))))
               (if (and newfile (file-exists-p newfile)) (cl-return newfile))))
           (cl-do* ((files fs (delq nil (mapcar #'diff-filename-drop-dir files)))
                    (file nil nil))
               ((or (null files)
                    (setq file (cl-do* ((files files (cdr files))
                                        (file (car files) (car files)))
                                   ((or (null file) (file-regular-p file))
                                    file))))
                file))
           (and (string-match "\\.rej\\'" (or buffer-file-name ""))
                (let ((file (substring buffer-file-name 0 (match-beginning 0))))
                  (when (file-exists-p file) file)))
           (and (not prefix)
                (boundp 'cvs-pcl-cvs-dirchange-re)
                (save-excursion
                  (re-search-backward cvs-pcl-cvs-dirchange-re nil t))
                (diff-find-file-name old noprompt (match-string 1)))
           (unless noprompt
             (let ((file (or (car fs) ""))
                   (creation (equal null-device
                                    (car (diff-hunk-file-names (not old))))))
               (when (and (memq diff-buffer-type '(git hg))
                          (string-match "/" file))
                 (setq file (substring file (match-end 0))))
               (setq file (expand-file-name file))
               (setq file
                     (read-file-name (format "Use file %s: " file)
                                     (file-name-directory file) file
                                     (not creation)
                                     (file-name-nondirectory file)))
               (when (or (not creation) (file-exists-p file))
                 (setq-local diff-remembered-files-alist
                             (cons (cons fs file) diff-remembered-files-alist)))
               file))))))))
(with-eval-after-load 'diff-mode
  (defun diff-apply-hunk (&optional reverse)
    "Apply the current hunk to the source file and go to the next.
By default, the new source file is patched, but if the variable
`diff-jump-to-old-file' is non-nil, then the old source file is
patched instead (some commands, such as `diff-goto-source' can change
the value of this variable when given an appropriate prefix argument).

With a prefix argument, REVERSE the hunk."
    (interactive "P")
    (diff-beginning-of-hunk t)
    (pcase-let* ((diff-vc-backend nil)
                 (deletion (equal null-device (car (diff-hunk-file-names reverse))))
                 (`(,buf ,line-offset ,pos ,old ,new ,switched)
                  (diff-find-source-location deletion reverse)))
      (cond
       ((null line-offset)
        (user-error "Can't find the text to patch"))
       ((with-current-buffer buf
          (and buffer-file-name
               (backup-file-name-p buffer-file-name)
               (not diff-apply-hunk-to-backup-file)
               (not (setq-local diff-apply-hunk-to-backup-file
                                (yes-or-no-p (format "Really apply this hunk to %s? "
                                                     (file-name-nondirectory
                                                      buffer-file-name)))))))
        (user-error "%s"
                    (substitute-command-keys
                     (format "Use %s\\[diff-apply-hunk] to apply it to the other file"
                             (if (not reverse) "\\[universal-argument] ")))))
       ((and switched
             (not (save-window-excursion
                    (pop-to-buffer buf)
                    (goto-char (+ (car pos) (cdr old)))
                    (y-or-n-p
                     (if reverse
                         "Hunk hasn't been applied yet; apply it now? "
                       "Hunk has already been applied; undo it? ")))))
        (message "(Nothing done)"))
       ((and deletion (not switched))
        (when (y-or-n-p (format-message "Delete file `%s'?" (buffer-file-name buf)))
          (delete-file (buffer-file-name buf) delete-by-moving-to-trash)
          (kill-buffer buf)))
       (t
        (with-current-buffer buf
          (goto-char (car pos))
          (delete-region (car pos) (cdr pos))
          (insert (car new)))
        (set-window-point (display-buffer buf) (+ (car pos) (cdr new)))
        (diff-hunk-status-msg line-offset (xor switched reverse) nil)
        (when diff-advance-after-apply-hunk
          (diff-hunk-next)))))))
(with-eval-after-load 'diff-mode
  (defun diff-apply-buffer (&optional beg end reverse)
    "Apply the diff in the entire diff buffer."
    (interactive)
    (let ((buffer-edits nil)
          (delete-bufs nil)
          (failures 0)
          (diff-refine nil))
      (save-excursion
        (goto-char (or beg (point-min)))
        (diff-beginning-of-hunk t)
        (while (pcase-let* ((diff-vc-backend nil)
                            (deletion (equal null-device
                                            (car (diff-hunk-file-names reverse))))
                            (`(,buf ,line-offset ,pos ,_src ,dst ,switched)
                             (diff-find-source-location deletion reverse)))
                 (cond ((and line-offset (not switched))
                        (if deletion
                            (cl-pushnew buf delete-bufs)
                          (push (cons pos dst)
                                (alist-get buf buffer-edits))))
                       (t (setq failures (1+ failures))))
                 (and (not (eq (prog1 (point) (ignore-errors (diff-hunk-next)))
                               (point)))
                      (or (not end) (< (point) end))
                      (looking-at-p diff-hunk-header-re)))))
      (cond ((zerop failures)
             (dolist (buf-edits (reverse buffer-edits))
               (with-current-buffer (car buf-edits)
                 (dolist (edit (cdr buf-edits))
                   (let ((pos (car edit))
                         (dst (cdr edit))
                         (inhibit-read-only t))
                     (goto-char (car pos))
                     (delete-region (car pos) (cdr pos))
                     (insert (car dst))))
                 (save-buffer)))
             (dolist (buf delete-bufs)
               (when (buffer-file-name buf)
                 (delete-file (buffer-file-name buf) delete-by-moving-to-trash)
                 (kill-buffer buf)))
             (message "Saved %d buffers, deleted %d files"
                      (length buffer-edits) (length delete-bufs))
             nil)
            (t
             (message (ngettext "%d hunk failed; no buffers changed"
                                "%d hunks failed; no buffers changed"
                                failures)
                      failures)
             failures)))))

;; Window Management =================================================
(define-advice pop-global-mark (:around (pgm) use-display-buffer)
  "Make `pop-to-buffer' jump buffers via `display-buffer'."
  (cl-letf (((symbol-function 'switch-to-buffer)
                         #'pop-to-buffer))
    (funcall pgm)))

(setq switch-to-buffer-obey-display-actions t)

(add-to-list 'display-buffer-alist
             '((or (major-mode . Info-mode)
                   (major-mode . help-mode)
                   (major-mode . eat-mode)
                   )
               (display-buffer-reuse-window
                display-buffer-in-side-window)
               (reusable-frames . visible)
               (side . bottom)
               (window-height . 0.45)
               (body-function . select-window)))

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

;; UTF-8 Everywhere ===================================================
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; Standalone Convenience functions & Keybinds ========================
(defun project-save-buffers ()
  "Save all modified file-visiting buffers in the current project."
  (interactive)
  (when-let ((pr (project-current)))
    (dolist (buf (project-buffers pr))
      (when (and (buffer-file-name buf)
                 (buffer-modified-p buf))
        (with-current-buffer buf
          (save-buffer))))))
(keymap-set my-mode-map "C-c c" 'compile)
(keymap-set my-mode-map "C-c r" 'revert-buffer)

;; Autocomplete ================================================
(use-package vertico
  :config
  (vertico-mode 1))

(use-package corfu
  :config
  (global-corfu-mode)
  ;; Unbind Corfu's navigation keys. They steal navigation too often
  ;; in modes where there are dictionary word
  ;; suggestions. Next-suggestion can still be accomplished with M-n,
  ;; M-p.
  (define-key corfu-map [remap next-line] nil)
  (define-key corfu-map [remap previous-line] nil)
  (keymap-unset corfu-map "RET")

  :custom
  (corfu-auto t)
  (corfu-quit-no-match t))

(use-package orderless
  :custom
  (completion-styles '(orderless partial-completion basic))
  (completion-category-overrides
   '(
     (file (styles basic partial-completion)))
   ))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package cape)

(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'completion-at-point-functions #'cape-file 100 t)
            (add-hook 'completion-at-point-functions #'cape-keyword 100 t)
            (add-hook 'completion-at-point-functions #'cape-dabbrev 100 t)
	    ))

;; Navigation  ================================================
(defun visit-init-file ()
  "Edit the file that initializes your Emacs configuration."
  (interactive)
  (find-file "~/.emacs"))

(keymap-set my-mode-map "C-c f" 'project-find-file)
(keymap-set my-mode-map "C-x M-." 'ff-find-other-file)
(keymap-set my-mode-map "M-." 'xref-find-definitions)
(keymap-set my-mode-map "M-/" 'xref-find-references)

(use-package swiper
  :bind ("C-s" . swiper))

(use-package transpose-frame)
(use-package ace-window
  :bind ("M-o" . ace-window)
  :custom
  (aw-dispatch-always t)
  )

(use-package avy
  :bind (:map my-mode-map ;; my-mode-map prevents other modes from reassigning
          ("C-'" . avy-goto-char)
          ("C-c '" . avy-goto-char-in-line)
          ("C-;" . avy-goto-line)
          ("C-c ;" . avy-goto-end-of-line)
          )
  :custom
  (avy-style 'at-full))

(which-function-mode t)

;; Other Packages ==============================================
(use-package consult
  :bind (:map my-mode-map ;; override minor modes
         ("C-x b" . consult-buffer)
         ("M-i" . consult-imenu)
         ("C-c M-i" . consult-imenu-multi)
         ("C-c g" . consult-ripgrep)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-y" . consult-yank-pop)
         ("C-c y" . consult-yasnippet)
         ("C-c C-s" . consult-line-multi)
         )
  :config
  (setq xref-show-xrefs-function 'consult-xref)
  (setq xref-show-definitions-function 'consult-xref))

(use-package eat
  :quelpa (eat
           :fetcher git
           :url "https://codeberg.org/akib/emacs-eat"
           :files ("*.el"
                   ("term" "term/*.el")
                   "*.texi" "*.ti"
                   ("terminfo/e" "terminfo/e/*")
                   ("terminfo/65" "terminfo/65/*")
                   ("integration" "integration/*")
                   (:exclude ".dir-locals.el" "*-tests.el"))))
;; (with-eval-after-load 'eat (setq eat-shell "/bin/zsh")) ;; macos
;; (with-eval-after-load 'eat (setq eat-shell "/bin/bash"))

;; Magit ========================================
(use-package magit
  :bind (("C-c s" . magit-status)))

;; These settings make magit work better over TRAMP
;; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
;; don't show the diff by default in the commit buffer. Use `C-c C-d' to display it
(setq magit-commit-show-diff nil)
;; don't show git variables in magit branch
(setq magit-branch-direct-configure nil)
;; don't automatically refresh the status buffer after running a git command
(setq magit-refresh-status-buffer nil)

;; fix magit asking for password many times
(use-package ssh-agency)

(require 'subr-x)
(require 'tramp)

(defcustom my/magit-keychain-command "keychain --eval --quiet"
  "Command run (local or over TRAMP) to obtain SSH_AUTH_SOCK/SSH_AGENT_PID."
  :type 'string)

(defun my/magit--keychain-extract (var text)
  (when (string-match (format "^%s=\\([^;\n]+\\)" (regexp-quote var)) text)
    (match-string 1 text)))

(defun my/magit--run-shell-command-to-string (cmd)
  "Run CMD via sh -c in `default-directory` (local or TRAMP), return stdout."
  (with-temp-buffer
    (if (eq 0 (process-file "sh" nil (current-buffer) nil "-c" (concat cmd " 2>/dev/null")))
        (buffer-string)
      "")))

(defun my/magit--env-remove-vars (env vars)
  (let ((re (concat "\\`\\(?:" (string-join (mapcar #'regexp-quote vars) "\\|") "\\)=")))
    (seq-remove (lambda (s) (and (stringp s) (string-match-p re s))) env)))

(defun my/magit--env-upsert (env var value)
  (cons (format "%s=%s" var value)
        (my/magit--env-remove-vars env (list var))))

(defun my/magit--env-has-var-p (env var)
  (let ((prefix (concat var "=")))
    (seq-some (lambda (s) (and (stringp s) (string-prefix-p prefix s))) env)))

(defun my/magit-import-keychain-into-magit-env-if-missing (&optional verbose)
  "Ensure buffer-local `magit-git-environment` contains SSH_AUTH_SOCK (and PID).
Only runs keychain if SSH_AUTH_SOCK is not already present.

With prefix arg (C-u), message what happened. Returns non-nil if updated."
  (interactive "P")
  ;; Ensure buffer-local copy (so we don't mutate the global default).
  (setq-local magit-git-environment (copy-sequence magit-git-environment))

  (if (my/magit--env-has-var-p magit-git-environment "SSH_AUTH_SOCK")
      (progn
        (when verbose (message "magit-git-environment already has SSH_AUTH_SOCK; skipping keychain"))
        nil)
    (let* ((raw  (my/magit--run-shell-command-to-string my/magit-keychain-command))
           (sock (my/magit--keychain-extract "SSH_AUTH_SOCK" raw))
           (pid  (my/magit--keychain-extract "SSH_AGENT_PID" raw)))
      (cond
       ((or (null sock) (string-empty-p sock))
        (when verbose (message "keychain produced no SSH_AUTH_SOCK (cmd=%s)" my/magit-keychain-command))
        nil)
       (t
        (setq-local magit-git-environment
                    (my/magit--env-upsert magit-git-environment "SSH_AUTH_SOCK" sock))
        (when (and pid (not (string-empty-p pid)))
          (setq-local magit-git-environment
                      (my/magit--env-upsert magit-git-environment "SSH_AGENT_PID" pid)))
        (when verbose
          (message "Set magit-git-environment: SSH_AUTH_SOCK=%s%s"
                   sock (if pid (format " SSH_AGENT_PID=%s" pid) "")))
        t)))))

;; Automatically apply when a Magit status buffer is created.
(add-hook 'magit-status-mode-hook #'my/magit-import-keychain-into-magit-env-if-missing)

;; Editing =========================================
(electric-pair-mode 1)
(keymap-set my-mode-map "M-s" 'sort-lines)

(use-package hungry-delete
  :bind ((:map my-mode-map
               ("C-c C-d" . hungry-delete-forward)
         )))

(use-package region-bindings-mode
  :config
  (region-bindings-mode-enable)
  (region-bindings-mode t))

(use-package expand-region
  :bind (
         ("C-c SPC" . er/expand-region)
         (:map region-bindings-mode-map ("SPC" . er/expand-region))
         ))

;; uses region-bindings-mode for key bindings
(use-package multiple-cursors
  :bind (
         (:map mc/keymap
               ("C-;" . nil) ;; conflict with avy keymap 
               )
         (:map region-bindings-mode-map
               ("m" . mc/mark-next-like-this)
               ("u" . mc/unmark-next-like-this)
               ("n" . mc/skip-to-next-like-this)
               ("l" . mc/edit-lines)
               )
         )
  :custom
  (mc/always-run-for-all t))

(use-package puni
  :bind ((:map my-mode-map
          ("C-M-s" . puni-slurp-forward)
          ("C-M-b" . puni-barf-forward)
          ("M-k" . puni-kill-line))))

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
(keymap-set my-mode-map "C-c d" 'duplicate-line)

;; yasnippet =========================================
(use-package yasnippet
  :bind (("C-<tab>" . yas-expand))
  :custom
  (yas-global-mode 1))
(use-package yasnippet-snippets)
(use-package consult-yasnippet)

;; gptel ==============================================
(use-package gptel
  :preface
  (define-prefix-command 'my/gptel-prefix-map)  
  :bind (("C-r" . my/gptel-prefix-map)
         (:map my/gptel-prefix-map
               ("r" . gptel-rewrite)
               ("a" . gptel-add)
               ("t" . gptel)
               ("m" . gptel-menu)
               ("u" . gptel-context-remove-all)
               ("k" . gptel-abort)
               )
         )
  :config
  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key #'gptel-api-key
    :models '(
              anthropic/claude-haiku-4.6
              anthropic/claude-opus-4.6
              anthropic/claude-sonnet-4.6
              qwen/qwen3-coder-next
              ))

  (setq gptel-backend (gptel-get-backend "OpenRouter"))
  (setf (alist-get 'org-mode gptel-prompt-prefix-alist) "@user\n")
  (setf (alist-get 'org-mode gptel-response-prefix-alist) "@assistant\n")

  :custom ;; runs before the package is loaded (?)
  (gptel-default-mode 'org-mode)
  (gptel-expert-commands t)
  (gptel-model 'qwen/qwen3-coder-next)
  )

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
     (define-key gptel-mode-map (kbd "C-c C-c") 'gptel-send)
     (define-key gptel-mode-map (kbd "RET") 'newline)
     (add-hook 'gptel-post-rewrite-functions #'cleanup-llm-rewrite-response)
     (add-hook 'gptel-post-stream-hook #'gptel-auto-scroll)
     )
  )

;; Eglot =================================================
(use-package eglot
  :hook (
         (
          python-mode ;; sudo snap install pyright --classic
          c++-mode ;; clangd
          ) . eglot-ensure)
  :custom
  (eglot-ignored-server-capabilities
   '(:inlayHintProvider))
  )

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode) 
                 . ("clangd" "--query-driver=/usr/bin/gcc")))) ;; fixes missing header issues 

;; Bazel =================================================
(use-package bazel)

(defvar bazel-prefix-map (make-sparse-keymap))
(define-key bazel-prefix-map (kbd "b") #'bazel-find-build-file)
(define-key bazel-prefix-map (kbd "c") #'bazel-compile-current-file)
(define-key bazel-prefix-map (kbd "r") #'bazel-run)

(with-eval-after-load 'bazel
  (define-key bazel-build-mode-map (kbd "C-q") #'bazel-buildifier)
  (define-key bazel-build-mode-map (kbd "C-c b") bazel-prefix-map)
  )

;; Python Development ====================================
(use-package python-black)

(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c b") bazel-prefix-map)
  (define-key python-mode-map (kbd "C-q") #'python-black-buffer))

;; C++ Development =======================================
(with-eval-after-load 'cc-mode
  (define-key c-mode-base-map (kbd "C-c b") bazel-prefix-map)
  (define-key c-mode-base-map (kbd "C-q") #'eglot-format-buffer))

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

;; prefer .h over .hpp
(with-eval-after-load 'find-file
  (setq ff-other-file-alist
        '(("\\.h\\'" (".c" ".cpp", ".cc", ".cxx"))
          ("\\.cpp\\'" (".h" ".hpp"))
          ("\\.cc\\'"  (".h" ".hpp"))
          ("\\.cxx\\'" (".h" ".hpp"))
          ("\\.c\\'"   (".h" ".hpp"))
          ("\\.hpp\\'" (".cpp" ".cc" ".cxx")))))

;; GLSL ====================================================
(use-package glsl-mode)

;; Org ==================================================
(use-package adaptive-wrap)
(use-package org
  :bind (:map org-mode-map
              ("C-c '" . nil)
              ("C-c a" . org-fold-show-all)
              )
  :custom (
           (org-pretty-entities t)
           (org-hide-emphasis-markers t)
           (org-pretty-entities-include-sub-superscripts t)
           (org-use-sub-superscripts '{}) ;; subscripts like a_{1}
           (org-confirm-elisp-link-function 'y-or-n-p)
           (org-babel-python-command "python3")
           )
  :hook (
         (org-mode . visual-line-mode)
         (org-mode . adaptive-wrap-prefix-mode)
         )
  :config 
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (C      . t)
     (shell  . t)))
  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 2.5))
  )

(add-hook 'org-mode-hook
          (lambda ()
            ;; clear bad defaults (ispell)
            (setq-local completion-at-point-functions '())
            ;; add useful capfs
            (add-hook 'completion-at-point-functions #'cape-file 100 t)
            (add-hook 'completion-at-point-functions #'cape-keyword 100 t)
            (add-hook 'completion-at-point-functions #'cape-dabbrev 100 t)
	    ))

(defvar my/org-roam-default-template
  '("d" "default" plain "%?"
    :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                       "#+title: ${title}\n\ #+date: %<%Y-%m-%d>\n\ #+filetags:\n\n")
    :unnarrowed t)
  "Default Org-roam capture template with date and empty filetags.")

(defvar my/org-roam-idea-template
  '("i" "idea" plain
    "* ${title}\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %U\n:END:\n\n%?"
    :if-new (file+head "ideas.org"
                       "#+title: Ideas\n#+filetags: :ideas:\n")))

(defun my/org-roam-node-has-tag (node tag)
  "Filter function to check if the given NODE has the specified TAG."
  (member tag (org-roam-node-tags node)))

(defun my/org-roam-node-find-by-tag ()
  "Find and open an Org-roam node based on a specified tag."
  (interactive)
  (let ((tag (read-string "Enter tag: ")))
    (org-roam-node-find nil nil (lambda (node) (my/org-roam-node-has-tag node tag)))))

(use-package org-roam
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n d" . org-roam-dailies-capture-today))
         ("C-c n t" . my/org-roam-node-find-by-tag)
  :custom
  (org-roam-capture-templates
   (list my/org-roam-default-template my/org-roam-idea-template)
   )
  :config
  (org-roam-db-autosync-mode t)
  )


;; EWW ===================================
(use-package eww
  :hook (eww-mode . scroll-lock-mode)
  )

;; TRAMP ======================================
;; don't ask to save plain-text password into authinfo
(setq tramp-save-ad-hoc-proxies nil)
;; (connection-local-set-profile-variables 'remote-without-auth-sources '((auth-sources . nil)))
;; (connection-local-set-profiles '(:application tramp) 'remote-without-auth-sources)

(with-eval-after-load 'tramp
  ;; common binary locations on remote
  (add-to-list 'tramp-remote-path "~/.local/bin" t)
  (add-to-list 'tramp-remote-path "/snap/bin" t)
  )

;; tramp speed
;; https://coredumped.dev/2025/06/18/making-tramp-go-brrrr./
;; https://www.gnu.org/software/tramp/#Frequently-Asked-Questions-1

;; Set remote-file-name-inhibit-cache to nil if remote files are not independently updated outside TRAMP's control. That cache cleanup will be necessary if the remote directories or files are updated independent of TRAMP.
(setq remote-file-name-inhibit-cache nil)

;; apparently rsync is faster than the default scp, but was bugged
;; until emacs 30.2
(setq tramp-default-method "rsync")

;; This modifies Emacs' version-control (VC) behavior so that VC is
;; disabled for all TRAMP paths, which avoids expensive remote checks
;; and thus speeds things up. With this: Emacs completely skips VC
;; integration for remote files. No Git status, no branch display, no
;; VC backend invocation. Much faster TRAMP performance.
(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))


;; When browsing directories on this remote machine via TRAMP, don't
;; try to resolve symlinks to see if they're broken. just display
;; them, and do it fast
(connection-local-set-profile-variables
 'fast-remote-dired
 '((dired-check-symlinks . nil)))
(connection-local-set-profiles
 '(:application tramp)
 'fast-remote-dired)

;; "these additional settings will prevent TRAMP from creating a bunch of extra files and use scp directly when moving files."
(setq remote-file-name-inhibit-locks t
      tramp-use-scp-direct-remote-copying t
      remote-file-name-inhibit-auto-save-visited t)
(setq tramp-copy-size-limit (* 1024 1024) ;; 1MB
      tramp-verbose 2)

;; Use direct async. "This feature alone will take many packages (like
;; magit or git-gutter) from completely unusable to bearable over
;; TRAMP"
(connection-local-set-profile-variables
 'remote-direct-async-process
 '((tramp-direct-async-process . t)))
(connection-local-set-profiles
 '(:application tramp :protocol "scp")
 'remote-direct-async-process)
(connection-local-set-profiles
 '(:application tramp :protocol "rsync")
 'remote-direct-async-process)
(setq magit-tramp-pipe-stty-settings 'pty)

;; "Newer versions of TRAMP will use SSH connection sharing for much
;; faster connections. These don't require you to reenter your
;; password each time you connect. The compile command disables this
;; feature, so we want to turn it back on."
(with-eval-after-load 'tramp
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

;; From the docs:
;; ssh sessions on the local host hang when the network is down. TRAMP
;; cannot safely detect such hangs. OpenSSH can be configured to kill
;; such hangs with the following settings in ~/.ssh/config:
;;
;; Host *
;;     ServerAliveInterval 5
;;     ServerAliveCountMax 2

;; Tryout =================================================
;; trying out these packages, not sure if we are going to keep them
(use-package olivetti)
(add-hook 'org-mode-hook #'olivetti-mode)

(use-package mentor)
(use-package reddigg)
(setq reddigg-subs '(selfdrivingcars emacs robotics hackernews))

(use-package vundo
  :bind (("C-?" . vundo))
  )

;; Avy menu, global binding
(use-package casual-avy
  :bind (("C-c C-'" . casual-avy-tmenu)))
(global-set-key (kbd "C-c C-'") #'casual-avy-tmenu)

(with-eval-after-load 'ibuffer
  (define-key ibuffer-mode-map (kbd "C-c m") #'casual-ibuffer-tmenu))



(global-set-key (kbd "C-c o") 'consult-outline)

(use-package nov :ensure t)

;; End ===============================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(olivetti-minimum-body-width 120)
 '(olivetti-style t)
 '(org-link-elisp-confirm-function 'y-or-n-p nil nil "Customized with use-package org")
 '(package-selected-packages
   '(ace-window adaptive-wrap bazel cape casual-avy consult-yasnippet
                corfu eat expand-region glsl-mode gptel gruvbox-theme
                hungry-delete llm-tool-collection macher magit
                marginalia mentor minimap mode-line-bell
                multiple-cursors nov olivetti olivetti-mode orderless
                org-roam puni python-black quelpa-use-package reddigg
                region-bindings-mode ssh-agency swiper switchy-window
                transpose-frame vertico vundo yasnippet-snippets)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
