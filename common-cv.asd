
(asdf:defsystem #:common-cv
  :serial t
  :depends-on (#:simple-utils
	       #:alexandria
	       #:cffi
	       #+darwin #:main-thread)
  :components ((:file "library")
	       (:file "package")
	       (:file "macros")
	       (:file "constants")
	       (:file "cv-types")
	       (:file "filter")
	       (:file "processing")
	       (:file "highgui")))
