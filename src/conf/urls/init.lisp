(in-package :cl-user)
(defpackage piklz.conf.urls
  (:nicknames :piklz.conf.urls)
  (:use :cl)
  (:import-from :piklz.core.urlresolvers
                :make-<regex-url-pattern>
                :make-<regex-url-resolver>
                :<regex-url-pattern>
                :set-package)
  (:export :include
           :patterns
           :url))
(in-package :piklz.conf.urls)

(defun include (arg &key (namespace nil) (app-name nil))
  (let ((urlconf-pkg (find-package (string-upcase arg))))
    (list urlconf-pkg app-name namespace)))

(defun patterns (pkg-name &rest args)
  (loop with pattern-list = '()
        for x in args
        when (listp x)
          do (setq x (apply #'url x))
        when (typep x '<regex-url-pattern>)
          do (set-package x pkg-name)
        do (setq pattern-list (append pattern-list (list x)))
        finally (return pattern-list)))

(defun url (regex view &key (kwargs nil) (name nil) (prefix ""))
  (cond
    ((listp view)
     (apply #'make-<regex-url-resolver> regex view))
    (t
     (when (> (length prefix) 0)
       (setq view (concatenate 'string prefix "." viwe)))
     (make-<regex-url-pattern> regex view kwargs name))))
