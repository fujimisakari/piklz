(in-package :cl-user)
(defpackage piklz.core.management.commands.runserver
  (:use :cl)
  (:import-from :piklz.core.management.base
                :<base-command>)
  (:import-from :piklz.conf
                :*settings*)
  (:export :<command>
           :handle
           :hoge))
(in-package :piklz.core.management.commands.runserver)


(defclass <command> (<base-command>)
  ())

(defmethod handle ((this <command>) argv)
  (format t "runserver ~a ~a" argv (getf *settings* :TIME_ZONE)))
