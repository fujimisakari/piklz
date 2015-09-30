(in-package :cl-user)
(defpackage piklz.core.management.commands.runserver
  (:use :cl
        :clack
        :clack.builder)
  (:import-from :piklz.core.management.base
                :<base-command>)
  (:import-from :piklz.core.handlers.clack
                :<clack-handler>)
  (:import-from :piklz.conf
                :*settings*)
  (:export :<command>
           :handle))
(in-package :piklz.core.management.commands.runserver)

(defclass <command> (<base-command>)
  ())

(defmethod handle ((this <command>) argv)
  (clack:clackup
   (make-instance '<clack-handler>)
   :use-thread nil))
