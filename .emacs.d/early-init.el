;; (defvar default-gc-cons-threshold 16777216 ; 16mb
;;   "my default desired value of `gc-cons-threshold'
;; during normal emacs operations.")

;; ;; make garbage collector less invasive
;; (setq gc-cons-threshold most-positive-fixnum)
;; (setq gc-cons-percentage 0.6)

;; Prevent the glimpse of un-styled Emacs by disabling these UI elements early.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; (add-hook
;;  'emacs-startup-hook
;;  (lambda (&rest _)
;;    (setq gc-cons-threshold default-gc-cons-threshold)
;;    (setq gc-cons-percentage 0.1)))

