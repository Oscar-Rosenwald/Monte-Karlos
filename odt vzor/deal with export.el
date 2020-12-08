(defun aaa (STYLE ONCE-ONLY)
  (interactive "sStyle: \nP")
  (let ((go-on (null ONCE-ONLY))
		(empty-line nil)
		(heading-level
		 (save-excursion
		   (beginning-of-buffer)
		   (unless (org-on-heading-p)
			 (outline-next-heading))
		   (org-outline-level)))
		(special-chars-alist nil)
		heading-styles)
	(when go-on
	  (beginning-of-buffer))
	(when (and (org-on-heading-p) go-on)
	  (forward-line))
	(while (and (not (= (point-at-eol) (buffer-end 1))) go-on)
	  (cond ((looking-at "^$")
			 (when empty-line
			   (when (y-or-n-p "Add empty line? ")
				 (backward-delete-char 1)
				 (insert "\\\\")))
			 (setq empty-line t))
			((looking-at " *[~:=]")
			 (setq empty-line nil)
			 (let ((character (buffer-substring-no-properties
							   (point)
							   (1+ (point))))
				   style)
			   (setq style (cadr (assoc character special-chars-alist)))
			   (unless style
				 (push (list
						character
						(setq style
							  (read-string
							   (format "Style for lines beginning with %s: " character))))
					   special-chars-alist))
			   (unless (string= style "")
				 (insert (format "#+attr_odt: :style \"%s\"\n" style)))))
			((org-on-heading-p)
			 (progn
			   (when (< heading-level (org-outline-level))
				 (setq heading-level (1+ heading-level)
					   empty-line nil)
				 (push (read-string
						(format "Style for heading %d [Heading %d]: "
								heading-level (org-outline-level))
						nil nil (format "Heading %d" (org-outline-level)))
					   heading-styles))
			   (insert (format "#+attr_odt: :style \"%s\"\n" (nth (- (org-outline-level) heading-level) heading-styles)))
			   (zap-to-char 1 ? )))
			(t (insert (format "#+attr_odt: :style \"%s\"\n" STYLE))
			   (setq empty-line nil)))
	  (forward-line))
	(if (looking-at "[~=:]")
		(let ((character (buffer-substring-no-properties
							   (point)
							   (1+ (point))))
				   style)
			   (setq style (cadr (assoc character special-chars-alist)))
			   (unless style
				 (push (list
						character
						(read-string
						 (format "Style for lines beginning with %s: " character)))
					   special-chars-alist))
			   (unless (string= style "")
				 (setq STYLE style))))
	  (insert (format "#+attr_odt: :style \"%s\"\n" STYLE))))