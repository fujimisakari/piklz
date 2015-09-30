#|
  This file is a part of piklz project.
  Copyright (c) 2015 fujimisakari (fujimisakari@gmail.com)
|#

#|
  Author: fujimisakari (fujimisakari@gmail.com)
|#

(in-package :cl-user)
(defpackage piklz-asd
  (:use :cl :asdf))
(in-package :piklz-asd)

(defsystem piklz
  :version "0.1"
  :author "fujimisakari"
  :license "LLGPL"
  :depends-on (:bordeaux-threads
               :clack-v1-compat
               :cl-ppcre
               :cl-fad
               :cl-annot)
  :components ((:module "src"
                :components
                ((:file "piklz" :depends-on ("conf" "core/handlers" "core/management"))
                 (:module "conf"
                  :components
                  ((:file "init")))
                 (:module "core/handlers"
                  :components
                  ((:file "clack")))
                 (:module "core/management"
                  :components
                  ((:file "init" :depends-on ("base"))
                   (:file "base")
                   (:file "templates" :depends-on ("base"))
                   (:file "commands/runserver" :depends-on ("base"))
                   (:file "commands/startapp" :depends-on ("templates"))
                   (:file "commands/startproject" :depends-on ("templates")))))))
  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op piklz-test))))
