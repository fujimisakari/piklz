(in-package :cl-user)
(defpackage piklz.core.management.commands.startapp
  (:use :cl)
  (:import-from :piklz.core.management.templates
                :<template-command>)
  (:export :<command>))
(in-package :piklz.core.management.commands.startapp)


(defclass <command> (<template-command>)
  ())

(defmethod handle ((this <command>) argv)
  (format t "startapp done. ~a" argv))
