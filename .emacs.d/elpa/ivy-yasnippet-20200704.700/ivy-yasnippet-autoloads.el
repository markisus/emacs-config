;;; ivy-yasnippet-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "ivy-yasnippet" "ivy-yasnippet.el" (0 0 0 0))
;;; Generated autoloads from ivy-yasnippet.el

(autoload 'ivy-yasnippet "ivy-yasnippet" "\
Read a snippet name from the minibuffer and expand it at point.
The completion is done using `ivy-read'.

In the minibuffer, each time selection changes, the selected
snippet is temporarily expanded at point for preview.

If text before point matches snippet key of any candidate, that
candidate will be initially selected, unless variable
`ivy-yasnippet-expand-keys' is set to nil." t nil)

(register-definition-prefixes "ivy-yasnippet" '("ivy-yasnippet-"))

;;;***

;;;### (autoloads nil nil ("ivy-yasnippet-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8-emacs-unix
;; End:
;;; ivy-yasnippet-autoloads.el ends here
