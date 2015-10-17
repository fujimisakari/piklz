(in-package :cl-user)
(defpackage piklz.conf.init
  (:nicknames :piklz.conf)
  (:use :cl)
  (:import-from :cl-fad
                :file-exists-p)
  (:export :*settings*
           :setup))
(in-package :piklz.conf.init)

(defvar *settings* '())

(defun setup ()
  (let* ((global-settings-path (asdf:system-relative-pathname
                                (intern
                                 (package-name (find-package "PIKLZ"))
                                 :keyword)
                                "src/conf/global-settings.lisp"))
         (local-settings-path (format nil "~a~a" *default-pathname-defaults* "settings.lisp"))
         (global-settings (load-setting global-settings-path))
         (local-settings (load-setting local-settings-path)))
    (loop for (key value) on local-settings by #'cddr
          do (setf (getf global-settings key) value))
    (setq *settings* global-settings)))

(defun load-setting (file-path)
  (when (file-exists-p file-path)
    (eval
     (read-from-string
      (slurp-file file-path)))))

(defun slurp-file (path)
  "Read a specified file and return the content as a sequence."
  (with-open-file (stream path :direction :input)
    (let ((seq (make-array (file-length stream) :element-type 'character :fill-pointer t)))
      (setf (fill-pointer seq) (read-sequence seq stream))
      seq)))
