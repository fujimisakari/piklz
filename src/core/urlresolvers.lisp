(in-package :cl-user)
(defpackage piklz.core.urlresolvers
  (:use :cl)
  (:import-from :cl-ppcre
                :scan
                :create-scanner
                :scan-to-strings
                :*allow-named-registers*)
  (:import-from :alexandria
                :make-keyword)
  (:import-from :piklz.conf
                :*settings*)
  (:export :<regex-url-pattern>
           :make-<regex-url-pattern>
           :make-<regex-url-resolver>
           :get-resolver
           :resolve
           :set-package
           :pkg-name))
(in-package :piklz.core.urlresolvers)

(defun get-resolver (&optional (urlconf nil))
  (if urlconf
      (make-<regex-url-resolver> "^/" urlconf)
      (make-<regex-url-resolver> "^/" (getf *settings* :root-urlconf))))

(defclass <locale-regex-provider> ()
  ((regex
    :initarg :regex
    :accessor regex)))

(defmethod regex-search ((this <locale-regex-provider>) path)
  (scan (regex this) path))

(defclass <resolver-match> ()
  ((func
    :initarg :func
    :accessor func)
   (args
    :initarg :args
    :accessor args)
   (kwargs
    :initarg :kwargs
    :accessor kwargs)
   (url-name
    :initarg :url-name
    :accessor url-name)
   (app-name
    :initarg :app-name
    :accessor app-name)
   (namespaces
    :initarg :namespaces
    :accessor namespaces)
   (pkg-name
    :initarg :pkg-name
    :accessor pkg-name)))

(defun make-<resolver-match> (pkg-name func args kwargs &optional (url-name nil) (app-name nil) (namespaces nil))
  (make-instance '<resolver-match> :pkg-name pkg-name
                                   :func func
                                   :args args
                                   :kwargs kwargs
                                   :url-name url-name
                                   :app-name app-name
                                   :namespaces namespaces))

(defclass <regex-url-pattern> (<locale-regex-provider>)
  ((callback-view
    :initarg :callback-view
    :accessor callback-view)
   (default-args
    :initarg :default-args
    :accessor default-args)
   (name
    :initarg :name
    :accessor name)
   (pkg-name
    :accessor pkg-name)))

(defun make-<regex-url-pattern> (regex callback &optional (default-args nil) (name nil))
  (make-instance '<regex-url-pattern> :regex regex
                                      :callback-view callback
                                      :default-args default-args
                                      :name name))

(defmethod set-package ((this <regex-url-pattern>) pkg-name)
  (setf (pkg-name this) pkg-name))
  ;; (let ((new-prefix (concatenate 'string prefix "." (callback-view this))))
  ;;   (setf (callback-view this) new-prefix)))

(defmethod resolve ((this <regex-url-pattern>) path)
  (let* ((*allow-named-registers* t))
    (multiple-value-bind (match-start match-end)
        (regex-search this path)
      (if (and match-start match-end)
          (progn
            (multiple-value-bind (re kw)
                (create-scanner (regex this))
              (let ((params (nth-value 1 (scan-to-strings re path)))
                    (args '())
                    (kwargs '()))
                (if (= (length params) (length kw))
                    (progn
                      (dotimes (idx (length params))
                        (if (nth idx kw)
                            (setq kwargs (append kwargs (list (make-keyword (string-upcase (nth idx kw))) (elt params idx))))
                            (setq args (append args (list (elt params idx))))))
                      (make-<resolver-match> (pkg-name this) (callback-view this) args kwargs (name this)))
                    (print "errr")))))))))

(defmethod callback ((this <regex-url-pattern>)))

;; @property
;; def callback(self):
;;     if self._callback is not None:
;;         return self._callback

;;     self._callback = get_callable(self._callback_str)
;;     return self._callback

(defclass <regex-url-resolver> (<locale-regex-provider>)
  ((urlconf-name
    :initarg :urlconf-name
    :accessor urlconf-name)
   (default-kwargs
    :initarg :default-kwargs
    :accessor default-kwargs)
   (app-name
    :initarg :app-name
    :accessor app-name)
   (namespace
    :initarg :namespace
    :accessor namespace)))

(defun make-<regex-url-resolver> (regex urlconf-name &optional (app-name nil) (namespace nil))
  (make-instance '<regex-url-resolver> :regex regex
                                       :urlconf-name urlconf-name
                                       :app-name app-name
                                       :namespace namespace))

;;       def __init__(self, regex, urlconf_name, default_kwargs=None, app_name=None, namespace=None):
;;         LocaleRegexProvider.__init__(self, regex)
;;         # urlconf_name is a string representing the module containing URLconfs.
;;         self.urlconf_name = urlconf_name
;;         if not isinstance(urlconf_name, basestring):
;;             self._urlconf_module = self.urlconf_name
;;         self.callback = None
;;         self.default_kwargs = default_kwargs or {}
;;         self.namespace = namespace
;;         self.app_name = app_name
;;         self._reverse_dict = {}
;;         self._namespace_dict = {}
;;         self._app_dict = {}
;; ))

(defmethod resolve ((this <regex-url-resolver>) path)
  (multiple-value-bind (match-start match-end)
      (regex-search this path)
    (if (and match-start match-end)
        (progn
          (let ((paterns (url-patterns this))
                (new-path (subseq path match-end (length path))))
            (loop with sub-match = nil
                  for patern in paterns
                  do (setq sub-match (resolve patern new-path))
                  (if (typep sub-match '<resolver-match>)
                      (return sub-match))))))))

;;     def resolve(self, path):
;;         tried = []
;;         match = self.regex.search(path)
;;         if match:
;;             new_path = path[match.end():]
;;             for pattern in self.url_patterns:
;;                 try:
;;                     sub_match = pattern.resolve(new_path)
;;                 except Resolver404, e:
;;                     sub_tried = e.args[0].get('tried')
;;                     if sub_tried is not None:
;;                         tried.extend([[pattern] + t for t in sub_tried])
;;                     else:
;;                         tried.append([pattern])
;;                 else:
;;                     if sub_match:
;;                         sub_match_dict = dict([(smart_str(k), v) for k, v in match.groupdict().items()])
;;                         sub_match_dict.update(self.default_kwargs)
;;                         for k, v in sub_match.kwargs.iteritems():
;;                             sub_match_dict[smart_str(k)] = v
;;                         return ResolverMatch(sub_match.func, sub_match.args, sub_match_dict, sub_match.url_name, self.app_name or sub_match.app_name, [self.namespace] + sub_match.namespaces)
;;                     tried.append([pattern])
;;             raise Resolver404({'tried': tried, 'path': new_path})
;;         raise Resolver404({'path' : path})

(defmethod urlconf-package ((this <regex-url-resolver>))
  (if (typep (urlconf-name this) 'string)
      (find-package (string-upcase (urlconf-name this)))
      (urlconf-name this)))

(defmethod url-patterns ((this <regex-url-resolver>))
  (symbol-value (intern "*URLPATTERNS*" (urlconf-package this))))
