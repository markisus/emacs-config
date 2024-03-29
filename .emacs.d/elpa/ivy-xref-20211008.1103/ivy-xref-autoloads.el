;;; ivy-xref-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "ivy-xref" "ivy-xref.el" (0 0 0 0))
;;; Generated autoloads from ivy-xref.el

(autoload 'ivy-xref-show-xrefs "ivy-xref" "\
Show the list of xrefs returned by FETCHER and ALIST via ivy.

\(fn FETCHER ALIST)" nil nil)

(autoload 'ivy-xref-show-defs "ivy-xref" "\
Show the list of definitions returned by FETCHER and ALIST via ivy.
Will jump to the definition if only one is found.

\(fn FETCHER ALIST)" nil nil)

(register-definition-prefixes "ivy-xref" '("ivy-xref-"))

;;;***

;;;### (autoloads nil nil ("ivy-xref-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8-emacs-unix
;; End:
;;; ivy-xref-autoloads.el ends here
