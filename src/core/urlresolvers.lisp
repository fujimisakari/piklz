(in-package :cl-user)
(defpackage piklz.core.urlresolvers
  (:use :cl
        :cl-ppcre)
  (:import-from :cl-fad
                :file-exists-p)
  (:export :setup
           :*url-patern*
           :make-<regex-url-pattern>
           :make-<regex-url-resolver>))
(in-package :piklz.core.urlresolvers)

(cl-syntax:use-syntax :annot)

(defvar *url-patern* '())

(defun setup (&optional (file-path "urls.lisp"))
  (let* ((file-path (format nil "~a~a" *default-pathname-defaults* file-path))
         (urls (load-urls file-path)))
    (setq *url-patern* urls)))

(defun load-urls (file-path)
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

(defclass <locale-regex-provider> ()
  ((regex
    :initarg :regex
    :accessor regex)))

(defmethod regex-search ((this <locale-regex-provider>) path)
  (cl-ppcre:scan (regex this) path))

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
    :accessor namespaces)))

(defun make-<resolver-match> (func args kwargs &optional (url-name nil) (app-name nil) (namespaces nil))
  (make-instance '<resolver-match> :regex regex
                                   :args args
                                   :kwargs kwargs
                                   :url-name url-name
                                   :app-name app-name
                                   :namespaces namespaces))

@export
(defclass <regex-url-pattern> (<locale-regex-provider>)
  ((callback
    :initarg :callback
    :accessor callback)
   (default-args
    :initarg :default-args
    :accessor default-args)
   (name
    :initarg :name
    :accessor name)))

(defun make-<regex-url-pattern> (regex callback &optional (default-args nil) (name nil))
  (make-instance '<regex-url-pattern> :regex regex
                                      :callback callback
                                      :default-args default-args
                                      :name name))

@export
(defmethod add-prefix ((this <regex-url-pattern>) prefix)
  (let ((new-prefix (concatenate 'string prefix "." (callback this))))
    (setf (callback this) new-prefix)))

(defmethod resolve ((this <regex-url-pattern>) path))

(defmethod callback ((this <regex-url-pattern>)))

    ;; def resolve(self, path):
    ;;     match = self.regex.search(path)
    ;;     if match:
    ;;         # If there are any named groups, use those as kwargs, ignoring
    ;;         # non-named groups. Otherwise, pass all non-named arguments as
    ;;         # positional arguments.
    ;;         kwargs = match.groupdict()
    ;;         if kwargs:
    ;;             args = ()
    ;;         else:
    ;;             args = match.groups()
    ;;         # In both cases, pass any extra_kwargs as **kwargs.
    ;;         kwargs.update(self.default_args)

    ;;         return ResolverMatch(self.callback, args, kwargs, self.name)

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

@export
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

@export
(defmethod resolve ((this <regex-url-resolver>) path)
  (print (url-patterns this)))

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

(defmethod urlconf-module ((this <regex-url-resolver>))
  (find-package (string-upcase (urlconf-name this))))

(defmethod url-patterns ((this <regex-url-resolver>))
  (symbol-value (intern "*URLPATTERNS*" (urlconf-module this))))

    ;; @property
    ;; def urlconf_module(self):
    ;;     try:
    ;;         return self._urlconf_module
    ;;     except AttributeError:
    ;;         self._urlconf_module = import_module(self.urlconf_name)
    ;;         return self._urlconf_module

    ;; @property
    ;; def url_patterns(self):
    ;;     patterns = getattr(self.urlconf_module, "urlpatterns", self.urlconf_module)
    ;;     try:
    ;;         iter(patterns)
    ;;     except TypeError:
    ;;         raise ImproperlyConfigured("The included urlconf %s doesn't have any patterns in it" % self.urlconf_name)
    ;;     return patterns
