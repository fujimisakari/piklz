(in-package :cl-user)
(defpackage piklz.core.handlers.clack
  (:use :cl
        :clack
        :clack.builder
        :piklz.http.request)
  (:import-from :piklz.conf
                :*settings*)
  (:import-from :piklz.core.handlers.base
                :<base-handler>
                :get-response)
  (:import-from :piklz.core.urlresolvers
                :get-resolver
                :resolve
                :pkg-name
                :func)
  (:export :<clack-handler>))
(in-package :piklz.core.handlers.clack)

(defclass <clack-handler> (<base-handler>) ())

(defmethod call ((this <clack-handler>) env)
  ;; (declare (ignore env))
  ;; (print env)
  (let ((request (make-request env)))
    (print (accesslog env))
    (get-response this request)))

(defun accesslog (env)
  (format nil "[~a] ~a ~a ~a"
          (today-time)
          (getf env :REQUEST-METHOD)
          (getf env :REQUEST-URI)
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

(defun make-request (env)
  (make-instance '<clack-request>
                 :environ env
                 :path-info (getf env :PATH-INFO)
                 :meta env
                 :method-type (getf env :REQUEST-METHOD)))

(defclass <clack-request> (<http-request>)
 ((environ
   :initarg :environ
   :accessor environ)))
