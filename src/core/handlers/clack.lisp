(in-package :cl-user)
(defpackage piklz.core.handlers.clack
  (:use :cl)
  (:import-from :clack
                :clackup)
  (:export :call))
(in-package :piklz.core.handlers.clack)

(defun call ()
  (format t "cccc")
  (clackup
   (lambda (env)
     (declare (ignore env))
     '(200 (:content-type "text/html") ("<html><h1>test</h1></html>"))) :use-thread nil))
