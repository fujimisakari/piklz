(in-package :cl-user)
(defpackage piklz.core.handlers.clack
  (:use :cl
        :clack
        :clack.builder)
  (:export :<clack-handler>))
(in-package :piklz.core.handlers.clack)

(defclass <clack-handler> (<component>) ())

(defmethod call ((this <clack-handler>) env)
  ;; (declare (ignore env))
  (print (accesslog env))
  '(200
    (:content-type "text/plain")
    ("hoge Hello, Clack!")))

(defun accesslog (env)
  (format nil "[~a] ~a ~a ~a"
          (today-time)
          (getf env :REQUEST-METHOD)
          (getf env :PATH-INFO)
          (getf env :SERVER-PROTOCOL)))

(defun today-time ()
  (multiple-value-bind (second
                        minute
                        hour
                        date
                        month
                        year
                        day-of-weak
                        daylight-p
                        time-zone)
      (get-decoded-time)
    (format nil "~d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d" year month date hour minute second)))
