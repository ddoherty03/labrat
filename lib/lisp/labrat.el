;;;; labrat -- Print labels using labrat from within a buffer.

;;; Commentary:

;; Lisp commands to print labels from within Emacs a buffer by invoking
;; labrat, a Ruby application desgined for printing labels from the
;; command-line rather than through a GUI.  You must have labrat installed
;; first.  See https://github.com/ddoherty03/labrat for details.

;;; Code:

(require 'thingatpt)
(require 's)
(require 'dash)

(defcustom labrat-executable "labrat"
  "Executable for labrat.

If the executable is not in your variable `exec-path', set this
to the full path name of the executable,
e.g. ~/.rbenv/shims/labrat, for an rbenv ruby installation."
  :type 'string
  :group 'labrat)

(defcustom labrat-nl-sep "~~"
  "String to mark newlines in label text.

If you change this, you need to make a corresponding change in your
labrat configuration at ~/.config/labrat/config.yml."
  :type 'string
  :group 'labrat)

(defcustom labrat-label-sep "@@"
  "String to mark the separation between labels on the labrat command-line.

If you change this, you need to make a corresponding change in your
labrat configuration at ~/.config/labrat/config.yml."
  :type 'string
  :group 'labrat)

(defconst labrat-buffer-name "*labrat*"
  "Name of the labrat process output buffer.")

(defun labrat/pars-in-region ()
  "Return a string of paragraphs in region, separated by `labrat-label-sep'.

If the region is not active, just return the paragraph at or before point as
is done by `labrat-par-at-point'.  In either case strip comment lines."
  (if (region-active-p)
      (progn
        (let ((beg (region-beginning))
              (end (save-excursion
                     (progn (goto-char (region-end))
                            (forward-paragraph)
                            (point))))
              (pars ""))
          (progn
            (save-excursion
              (goto-char beg)
              (while (< (point) end)
                (forward-paragraph)
                (setq pars (s-concat pars (labrat/par-at-point) labrat-label-sep))))
            (s-chop-prefix labrat-label-sep (s-chop-suffix labrat-label-sep pars)))))
    (labrat/par-at-point)))

(defun labrat/par-at-point ()
  "Return the paragraph at or before point.

Similar to the command `thing-at-point' for paragraph, but look
for preceding paragraph even if there are several blank lines
before point, trim white space, comments, and properties from the
result."
  (save-excursion
    (unless (looking-at ".+")
      (re-search-backward "^.+$" nil 'to-bob))
    (s-replace "\n" labrat-nl-sep
               (labrat/remove-comments
                          (s-trim (thing-at-point 'paragraph t))))))

(defun labrat/remove-comments (str)
  "Remove any lines from STR that start with the comment character '#'.

If STR consists of multiple new-line separated lines, the lines
that start with '#' are removed, and the remaining lines
returned"
  (s-join "\n" (--remove (string-match "^#" it) (s-split "\n" str))))

(defun labrat/run (&rest args)
  "Run labrat with ARGS, always reusing and displaying `*labrat*'.

Stdout and stderr are both written to the `*labrat*' buffer.
Return the labrat exit status."
  (let* ((buf (get-buffer-create labrat-buffer-name))
         (stderr-file (make-temp-file "labrat-stderr-"))
         (status nil))
    (unwind-protect
        (progn
          (with-current-buffer buf
            (let ((inhibit-read-only t)
                  (ts (format-time-string "%Y-%m-%d %H:%M:%S")))
              (goto-char (point-max))
              (unless (bolp)
                (insert "\n"))
              (insert (format "\n===== %s =====\n" ts))
              (insert (format "$ %s %s\n\n"
                              labrat-executable
                              (mapconcat #'identity args " ")))))
          (setq status
                (apply #'call-process
                       labrat-executable
                       nil
                       (list buf stderr-file)
                       nil
                       args))
          (with-current-buffer buf
            (let ((inhibit-read-only t))
              (when (file-exists-p stderr-file)
                (let ((stderr-text
                       (with-temp-buffer
                         (insert-file-contents stderr-file)
                         (buffer-string))))
                  (unless (string-empty-p stderr-text)
                    (goto-char (point-max))
                    (unless (bolp)
                      (insert "\n"))
                    (insert "===== stderr =====\n")
                    (insert stderr-text)
                    (unless (bolp)
                      (insert "\n")))))
              (goto-char (point-max))
              (insert (format "\n[labrat exited with status %s]\n" status))))
          (unless (equal status 0)
            (display-buffer buf)
            (message "labrat failed with status %s; see %s" status labrat-buffer-name))
          status)
      (when (file-exists-p stderr-file)
        (delete-file stderr-file)))))

(defun labrat-view ()
  "View the paragraph at or before point as a label with labrat.

This invokes the \"labrat -V\ <label>\" command with the
paragraph at or before point inserted in the <label> position,
but with each new-line replaced with the value of the variable
labrat-nl-sep, '~~' by default."
  (interactive)
  (labrat/run "-V" (labrat/pars-in-region)))

(defun labrat-print ()
  "Print the paragraph at or before point as a label with labrat.

This invokes the \"labrat <label>\" command with the paragraph
at or before point inserted in the <label> position, but with
each new-line replaced with the value of the variable
labrat-nl-sep, '~~' by default."
  (interactive)
  (labrat/run (labrat/pars-in-region)))

(provide 'labrat)
;;; labrat.el ends here
