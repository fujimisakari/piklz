(in-package :cl-user)
(defpackage piklz.core.management.base
  (:use :cl))
(in-package :piklz.core.management.base)

(defparameter *p1* "abc")
(defparameter *p2* "de")

(defclass <base-command> ()
  ())

(defgeneric handle (command argv)
  (:documentation "Build up an application for this project and return it. This method must be implemented in subclasses."))

;; (defgeneric run-from-argv (alist argv)
;;   (:method (alist argv)
;;     (execute alist argv)))

(defmethod run-from-argv ((this <base-command>) argv)
  (format t "run-from-argv"))

(defmethod execute (alist argv)
  (let ((<command> (cdr (assoc 'class alist :test #'string-equal)))
        (handle (cdr (assoc 'func alist :test #'string-equal))))
    ;; (format t "alist ~a" (type-of alist))))
    (format t "alist ~a" <command>)
    (format t "alist ~a" handle)))
    ;; (funcall handle <command> '())))
  ;; (format t "hoge ~a" (assoc 'func alist)))
  ;; (funcall '#(assoc 'func alist) (assoc 'class alist) '()))
