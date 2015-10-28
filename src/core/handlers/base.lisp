(in-package :cl-user)
(defpackage piklz.core.handlers.base
  (:use :cl
        :clack
        :clack.builder
        :piklz.http.request)
  (:import-from :piklz.conf
                :*settings*)
  (:import-from :piklz.core.urlresolvers
                :get-resolver
                :resolve
                :pkg-name
                :func)
  (:export :<base-handler>
           :get-response))
(in-package :piklz.core.handlers.base)

(defclass <base-handler> (<component>)
  ((request-middleware
    :initarg :request-middleware
    :initform nil
    :accessor request-middleware)
   (view-middleware
    :initarg :view-middleware
    :initform nil
    :accessor view-middleware)
   (template-response-middleware
    :initarg :template-response-middleware
    :initform nil
    :accessor template-response-middleware)
   (response_middleware
    :initarg :response_middleware
    :initform nil
    :accessor response_middleware)
   (exception_middleware
    :initarg :exception_middleware
    :initform nil
    :accessor exception_middleware)))

(defmethod get-response ((this <base-handler>) request)
  (let ((urlconf (get-resolver (getf *settings* :root-urlconf)))
        (resolver-match nil))
    (setq resolver-match (resolve urlconf (path-info request)))
    (if resolver-match
        (progn
          (let ((pkg (find-package (string-upcase (pkg-name resolver-match))))
                (func-name (string-upcase (func resolver-match))))
            (funcall (intern func-name pkg) request)))
        '(200
          (:content-type "text/plain")
          ("hoge Hello, Clack!")))))
