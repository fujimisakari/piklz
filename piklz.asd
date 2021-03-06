#|
  This file is a part of piklz project.
  URL: http://github.com/fujimisakari/piklz
  Copyright (c) 2015 Ryo Fujimoto (fujimisakari@gmail.com)
|#

(in-package :cl-user)
(defpackage piklz-asd
  (:use :cl :asdf))
(in-package :piklz-asd)

(defsystem piklz
  :version "0.0.3"
  :description "Web application framework like Django"
  :author "Ryo Fujimoto"
  :license "BSD"
  :depends-on (:bordeaux-threads
               :alexandria
               :clack-v1-compat
               :cl-ppcre
               :cl-fad
               :cl-syntax-annot)
  :components ((:module "src"
                :components
                ((:file "piklz" :depends-on ("conf" "http" "core/handlers" "core/management"))
                 (:module "conf"
                  :components
                  ((:file "init")))
                 (:module "conf/urls"
                  :depends-on ("core")
                  :components
                  ((:file "init")))
                 (:module "http"
                  :components
                  ((:file "request")))
                 (:module "core"
                  :components
                  ((:file "urlresolvers")))
                 (:module "core/handlers"
                  :depends-on ("core" "conf")
                  :components
                  ((:file "base")
                   (:file "clack" :depends-on ("base"))))
                 (:module "core/management"
                  :components
                  ((:file "init" :depends-on ("base"))
                   (:file "base")
                   (:file "templates" :depends-on ("base"))
                   (:file "commands/runserver" :depends-on ("base"))
                   (:file "commands/startapp" :depends-on ("templates"))
                   (:file "commands/startproject" :depends-on ("templates")))))))
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
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
