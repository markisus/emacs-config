;;; vundo-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "vundo" "vundo.el" (0 0 0 0))
;;; Generated autoloads from vundo.el

(autoload 'vundo "vundo" "\
Display visual undo for the current buffer." t nil)

(register-definition-prefixes "vundo" '("vundo-"))

;;;***

;;;### (autoloads nil "vundo-diff" "vundo-diff.el" (0 0 0 0))
;;; Generated autoloads from vundo-diff.el

(autoload 'vundo-diff-mark "vundo-diff" "\
Mark NODE for vundo diff.
NODE defaults to the current node.

\(fn &optional NODE)" t nil)

(autoload 'vundo-diff-unmark "vundo-diff" "\
Unmark the node marked for vundo diff." t nil)

(autoload 'vundo-diff "vundo-diff" "\
Perform diff between marked and current buffer state.
Displays in a separate diff buffer with name based on
the original buffer name." t nil)

(register-definition-prefixes "vundo-diff" '("vundo-diff-"))

;;;***

;;;### (autoloads nil nil ("vundo-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8-emacs-unix
;; End:
;;; vundo-autoloads.el ends here
