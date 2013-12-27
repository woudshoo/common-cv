(in-package #:cl-user)

(defun red-object-tracking (&optional (cam -1))
  (mt:call-in-main-thread nil
    (let* ((morph-kernel (cv:create-structuring-element-ex 5 5 1 1 :cv-shape-rect)))
      (cv:with-named-window ("red_object_tracking")
	(cv:with-captured-camera (vid cam)
	  (cv:with-cv-tracks (tracks)
	    (let* ((img (cv:query-frame vid))
		   (frame (cv:create-image (cv:size (cv:width img) (cv:height img)) :ipl-depth-8u 3)))
	      (loop
		(let ((img (cv:query-frame vid)))
		  (cv:convert-scale img frame 1 0)
		  (cv:with-cv-blobs (blobs)
		    (let ((width (cv:width img))
			  (height (cv:height img)))
		      (cv:with-ipl-image ((segmentated (cv:size width height) :ipl-depth-8u 1)
					  (label-img (cv:size width height) :ipl-depth-label 1))
			(let ((frame-data (cv:image-data frame))
			      (segmentated-data (cv:image-data segmentated)))
			  (dotimes (j height)
			    (dotimes (i width)
			      (let* ((b (/ (cffi:mem-aref frame-data :unsigned-char (+ (+ (* 3 i) (* 3 j width)) 0)) 255.0))
				     (g (/ (cffi:mem-aref frame-data :unsigned-char (+ (+ (* 3 i) (* 3 j width)) 1)) 255.0))
				     (r (/ (cffi:mem-aref frame-data :unsigned-char (+ (+ (* 3 i) (* 3 j width)) 2)) 255.0))
				     (f (* 255 (if (cl:and (> r (+ 0.2 g)) (> r (+ 0.2 b))) 1 0))))
				(setf (cffi:mem-aref segmentated-data :unsigned-char (+ i (* j width))) f)))))
			(cv:morphology-ex segmentated segmentated nil morph-kernel :cv-mop-open 1)
			(cv:label segmentated label-img blobs)
			(cv:filter-by-area blobs 500 1000000)
			(cv:render-blobs label-img blobs frame frame :cv-blob-render-bounding-box)
			(cv:update-tracks blobs tracks 200. 5)
			(cv:render-tracks tracks frame frame '(:cv-track-render-id
							       :cv-track-render-bounding-box))
			(cv:show-image "red_object_tracking" frame)
			(cv:release-blobs blobs)))))
		(let ((c (cv:wait-key 33)))
		  (when (= c 27)
		    (return))))
	      (cv:release-structuring-element morph-kernel)
	      (cv:release-image frame))))))))
