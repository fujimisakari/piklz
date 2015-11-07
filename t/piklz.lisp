(in-package :cl-user)
(defpackage piklz-test
  (:use :cl
        :piklz
        :prove))
(in-package :piklz-test)

;; NOTE: To run this test file, execute `(asdf:test-system :piklz)' in your Lisp.

(plan 3)

(ok (not (find 4 '(1 2 3))))
(is 4 4)
(isnt 1 #\1)

(finalize)
