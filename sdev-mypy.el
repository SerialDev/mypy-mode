;;; sdev-mypy.el --- Python Type checking support and compilation-mode based on mypy

;; Copyright (C) 2017 Andres Mariscal <carlos.mariscal.melgar@gmail.com>
;;
;; Author: Andres Mariscal <carlos.mariscal.melgar@gmail.com>
;; Created: 14 November 2017
;; Version: 1.0
;; Package-Requires: pip install mypy , Python 3.6 + 
;=================================={mypy-mode}=================================;

;;; Commentary:
;; Maintained by Andres Mariscal -- carlos.mariscal.melgar@gmail.com

;;; License:

;; This file is not part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.
;;; Code:

(defun shell-command-to-buffer (command buffer-name &optional buffer-mode)
  "Run a `command' ,pop and, append its output to buffer `buffer-name' ."
  (with-current-buffer (pop-to-buffer buffer-name)
    (goto-char (point-max))
    (insert (shell-command-to-string command))
    (goto-char (point-min))
    (funcall buffer-mode)))

(defun buffer-mode (&optional buffer-or-name)
  "Returns the major mode associated with a buffer.
If buffer-or-name is nil return current buffer's mode."
  (buffer-local-value 'major-mode
   (if buffer-or-name (get-buffer buffer-or-name) (current-buffer))))

(defun sdev/py-type-check()
  "type checker for python.--inferstats "
  (interactive)
   (shell-command-to-buffer
    (message "python -m mypy \
--ignore-missing-imports \
--disallow-incomplete-defs \
--disallow-any-explicit \
--disallow-any-generics \
--disallow-untyped-decorators \
--show-column-numbers \
--warn-return-any \
--warn-redundant-casts \
--warn-unused-ignores \
--check-untyped-defs \
 --disallow-untyped-calls \
--python-version 3.6 \
%s"  buffer-file-name)
    "*py-typecheck*" 'mypy-mode))


;; a simple major mode, mypy-mode

(define-derived-mode mypy-mode compilation-mode "mypy"
  "major mode for editing mypy language code."

  )

(defun mypy-install()
  (interactive)
  (async-shell-command "pip install mypy"))


;{error mode support};

(pushnew '(mypy ("\\(.*py\\):\\([0-9]+\\):\\([0-9]+\\)?" 1 2 3))
   compilation-error-regexp-alist-alist)

(make-face 'mypy-file-face)
(make-face 'mypy-line-face)
(make-face 'mypy-quoted-face)

(add-hook 'mypy-mode-hook (lambda()
			    (set (make-local-variable font-lock-type-face)
				   'mypy-file-face)
			     ))
(add-hook 'mypy-mode-hook (lambda()
			    (set (make-local-variable font-lock-keyword-face)
				   'mypy-line-face)
			     ))
(add-hook 'mypy-mode-hook (lambda()
			    (set (make-local-variable font-lock-variable-name-face)
				   'mypy-quoted-face)
			     ))


(set-face-attribute 'mypy-file-face nil :foreground "#add8e6")
(set-face-attribute 'mypy-line-face nil :foreground "#ffffff")
(set-face-attribute 'mypy-quoted-face nil :foreground "#Fafad2")

(add-hook 'mypy-mode-hook (lambda()
(font-lock-add-keywords nil
'(("\\<\\(error\\):" 1 font-lock-warning-face prepend)
  ("\\<\\(info\\):" 1 font-lock-comment-face append)
  ("\"\\(\\(?:[^\"\\]+\\|\\\\\\(?:.\\|\\)\\)*\\)\"" 1 font-lock-variable-name-face append)
  ("\\(.*py*\\):" 1 font-lock-type-face append)
  ("\\([0-9]+\\):" 1 font-lock-keyword-face append)
  ))))




(defun sdev/buffer-dir()
  (file-name-directory buffer-file-name))

(provide 'sdev-mypy)

;;; sdev-mypy.el ends here
