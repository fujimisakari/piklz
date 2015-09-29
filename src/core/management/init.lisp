(in-package :cl-user)
(defpackage piklz.core.management.init
  (:nicknames :piklz.core.management)
  (:use :cl
        :cl-ppcre)
  (:import-from :piklz.core.management.base
                :run-from-argv)
  (:import-from :piklz.conf
                :*settings*
                :setup)
  (:export :execute-from-command-line))
(in-package :piklz.core.management.init)

(defun get-commands ()
  (flet ((command-check (pkg)
           (cl-ppcre:scan "MANAGEMENT\\.COMMANDS" (package-name pkg))))
    (loop for pkg in (list-all-packages)
          when (command-check pkg)
            collect (cons (make-symbol (car (last (cl-ppcre:split "\\." (package-name pkg))))) (package-name pkg)))))

(defclass <management-utility> ()
  ((subcommand :initarg :subcommand
               :accessor subcommand)
   (options :initarg :options
            :accessor options)
   (pkg-name :accessor pkg-name
             :type :keyword)))

(defmethod main-help-text ((this <management-utility>))
  "Returns the script's main help text, as a string."
  (let ((commands (get-commands))
        (get-pkg-name (lambda (pkg) (scan-to-strings ".*\\.MANAGEMENT\\.COMMANDS" pkg))))
    (format t "~%~%Usage: manage.ros subcommand [options] [args]")
    (format t "~%~%Options:")
    (format t "~%  --version         show program's version number and exit")
    (format t "~%  -h, --help        show this help message and exit")
    (format t "~%~%Type 'manage.ros help <subcommand>' for help on a specific subcommand.~%~%Available subcommands:~%")
    (loop with pkg-name = nil
          for command in commands
          unless (string= pkg-name (funcall get-pkg-name (cdr command)))
            do (prog ()
                  (setq pkg-name (funcall get-pkg-name (cdr command)))
                  (format t "~%~c[31m[~a]~c[0m~%" #\ESC (string-downcase (funcall get-pkg-name (cdr command))) #\ESC))
          do (format t "    ~a~%" (string-downcase (car command))))))

(defmethod fetch-command ((this <management-utility>) subcommand)
  "baseCommandコマンドをloadする"
  (let* ((commands (get-commands))
         (pkg-alist (assoc (string-upcase (string subcommand)) commands :test #'string=)))
    (when pkg-alist
      (setf (pkg-name this) (intern (cdr pkg-alist) :keyword))
      (make-instance (intern (string '#:<command>) (pkg-name this))))))

(defmethod execute ((this <management-utility>))
  (cond ((or (not (subcommand this)) (string= (subcommand this) "help"))
         (main-help-text this))
        (t
         (let ((command (fetch-command this (subcommand this))))
           (if command
               (progn
                 (piklz.conf:setup)
                 (funcall (intern #.(string '#:handle) (pkg-name this)) command (options this)))
               (format t "~%~%Unknown command: '~a'~%Type 'manage.ros help' for usage.~%" (subcommand this)))))))

(defun execute-from-command-line (&rest argv)
  "A simple method that runs a ManagementUtility."
  (execute (make-instance '<management-utility> :subcommand (car (car argv))
                                                :options (cdr (car argv)))))
