;;; 0blayout-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "0blayout" "0blayout.el" (0 0 0 0))
;;; Generated autoloads from 0blayout.el

(autoload '0blayout-add-keybindings-with-prefix "0blayout" "\
Add 0blayout keybindings using the prefix PREFIX.

\(fn PREFIX)" nil nil)

(defvar 0blayout-mode nil "\
Non-nil if 0bLayout mode is enabled.
See the `0blayout-mode' command
for a description of this minor mode.")

(custom-autoload '0blayout-mode "0blayout" nil)

(autoload '0blayout-mode "0blayout" "\
Handle layouts with ease

This is a global minor mode.  If called interactively, toggle the
`0bLayout mode' mode.  If the prefix argument is positive, enable
the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `(default-value \\='0blayout-mode)'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\(fn &optional ARG)" t nil)

(register-definition-prefixes "0blayout" '("0blayout-"))

;;;***

;;;### (autoloads nil nil ("0blayout-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8-emacs-unix
;; End:
;;; 0blayout-autoloads.el ends here
