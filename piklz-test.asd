#|
  This file is a part of piklz project.
  URL: http://github.com/fujimisakari/piklz
  Copyright (c) 2015 Ryo Fujimoto (fujimisakari@gmail.com)
|#

(in-package :cl-user)
(defpackage piklz-test-asd
  (:use :cl :asdf))
(in-package :piklz-test-asd)

(defsystem piklz-test
  :author "Ryo Fujimoto"
  :license "BSD"
  :depends-on (:piklz
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "piklz"))))
  :description "Test system for piklz"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
