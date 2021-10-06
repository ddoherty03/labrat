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

(defcustom labrat-nlsep "++"
  "String to mark newlines in label text.

If you change this, you need to make a corresponding change in your
labrat configuration at ~/.config/labrat/config.yml."
  :type 'string
  :group 'labrat)

(defun labrat/par-at-point ()
  "Return the paragraph at or before point.

Similar to the command `thing-at-point' for paragraph, but look
for preceding paragraph even if there are several blank lines
before point, trim white space, comments, and properties from the
result."
  (save-excursion
    (re-search-backward "^.+$" nil 'to-bob)
    (s-replace "\n" labrat-nlsep
               (labrat/remove-comments
                          (s-trim (thing-at-point 'paragraph t))))))

(defun labrat/remove-comments (str)
  "Remove any lines from STR that start with the comment character '#'.

If STR consists of multiple new-line separated lines, the lines
that start with '#' are removed, and the remaining lines
returned"
  (s-join "\n" (--remove (string-match "\\`#.*\\'"it) (s-split "\n" str))))

(defun labrat-view ()
  "View the paragraph at or before point as a label with labrat.

This invokes the \"labrat -V\ <label>\" command with the
paragraph at or before point inserted in the <label> position,
but with each new-line replaced with the value of the variable
labrat-nlsep, '++' by default."
  (interactive)
  (call-process labrat-executable nil nil nil
                "-V" (labrat/par-at-point)))

(defun labrat-print ()
  "Print the paragraph at or before point as a label with labrat.

This invokes the \"labrat -P <label>\" command with the paragraph
at or before point inserted in the <label> position, but with
each new-line replaced with the value of the variable
labrat-nlsep, '++' by default."
  (interactive)
  (call-process labrat-executable nil nil nil
                (labrat/par-at-point)))

(provide 'labrat)
;;; labrat.el ends here
