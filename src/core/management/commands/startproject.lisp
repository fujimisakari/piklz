(in-package :cl-user)
(defpackage piklz.core.management.commands.startproject
  (:use :cl)
  (:import-from :piklz.core.management.templates
                :<template-command>)
  (:export :<command>))
(in-package :piklz.core.management.commands.startproject)


(defclass <command> (<template-command>)
  ())

(defmethod handle ((this <command>) argv)
  (format t "startproject ~a" argv))
