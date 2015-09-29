(in-package :cl-user)
(defpackage piklz.core.management.templates
  (:use :cl)
  (:import-from :piklz.core.management.base
                :<base-command>)
  (:export :<template-command>))
(in-package :piklz.core.management.templates)


(defclass <template-command> (<base-command>)
  ())

