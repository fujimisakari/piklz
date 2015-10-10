(in-package :cl-user)
(defpackage piklz.http.request
  (:use :cl)
  (:export :<http-request>
           :get-port))
(in-package :piklz.http.request)

(defclass <http-request> ()
 ((get-data
   :initarg :get-data
   :accessor get-data)
  (post-data
   :initarg :post-data
   :accessor post-data)
  (cookies
   :initarg :cookies
   :accessor cookies)
  (meta
   :initarg :meta
   :accessor meta)
  (files
   :initarg :files
   :accessor files)
  (path
   :initarg :path
   :accessor path)
  (path-info
   :initarg :path-info
   :accessor path-info)
  (method-type
   :initarg :method-type
   :accessor method-type)
  (resolver-match
   :initarg :resolver-match
   :accessor resolver-match)))

(defmethod get-port ((this <http-request>))
  (getf (meta this) :SERVER-PORT))
