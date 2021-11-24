;;; eldoc-posframe.el --- Show eldoc  messages using posframe.el

;; Copyright (C) 2019 Eder Elorriaga

;; Author: Eder Elorriaa <eder.elorriga@gmail.com>
;; Maintainer: Eder Elorriaa <eder.elorriga@gmail.com>
;; Keywords: documentation, eldoc, posframe
;; URL: https://github.com/gexplorer/eldoc-posframe
;; Version: 0.1
;; Package-Requires: ((emacs "26") (posframe "0.3.0"))

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Eldoc displays the function signature of the closest function call
;; around point either in the minibuffer or in the modeline.
;;
;; This package modifies Eldoc to display this documentation using
;; a child frame.

;;; Code:
(require 'eldoc)
(require 'posframe)

(defgroup eldoc-posframe nil
  "Display eldoc in tooltips using posframe.el."
  :prefix "eldoc-posframe-"
  :group 'eldoc)

(defcustom eldoc-posframe-padding 5
  "Padding inside the tooltips."
  :type 'integer
  :group 'eldoc-posframe)

(defcustom eldoc-posframe-left-fringe 10
  "Fringe on the left side."
  :type 'integer
  :group 'eldoc-posframe)

(defcustom eldoc-posframe-right-fringe 10
  "Fringe on the left side."
  :type 'integer
  :group 'eldoc-posframe)

(defcustom eldoc-posframe-max-width 60
  "Posframe max width."
  :type 'integer
  :group 'eldoc-posframe)

(defcustom eldoc-posframe-poshandler #'posframe-poshandler-frame-top-right-corner
  "Display posframe at point."
  :type 'function
  :group 'eldoc-posframe)

(defvar eldoc-posframe-buffer "*eldoc-posframe-buffer*"
  "The posframe buffer name use by eldoc-posframe.")

(defvar eldoc-posframe-hide-posframe-hooks
  '(pre-command-hook post-command-hook focus-out-hook)
  "The hooks which should trigger automatic removal of the posframe.")

(defun eldoc-posframe-hide-posframe ()
  "Hide messages currently being shown if any."
  (posframe-hide eldoc-posframe-buffer)
  (dolist (hook eldoc-posframe-hide-posframe-hooks)
    (remove-hook hook #'eldoc-posframe-hide-posframe t)))

(defun eldoc-posframe-maybe-hide-posframe ()
  "Hide messages if command was not a `self-insert-command'."
  (unless (eq this-command 'self-insert-command)
    (eldoc-posframe-hide-posframe)))

(defun eldoc-posframe-show-posframe (format-string &rest args)
  "Display FORMAT-STRING and ARGS, using posframe.el library."
  (if format-string
      (progn
        (posframe-show
         eldoc-posframe-buffer
         :string (apply 'format format-string args)
         :background-color (face-background 'eldoc-posframe-background-face nil t)
         :internal-border-width eldoc-posframe-padding
         :left-fringe eldoc-posframe-left-fringe
         :right-fringe eldoc-posframe-right-fringe
         :max-width eldoc-posframe-max-width
         :poshandler eldoc-posframe-poshandler)
        (dolist (hook eldoc-posframe-hide-posframe-hooks)
          (add-hook hook #'eldoc-posframe-maybe-hide-posframe nil t)))
    (eldoc-posframe-hide-posframe)))

(defface eldoc-posframe-background-face
  '((t :inherit highlight))
  "The background color of the eldoc-posframe frame.
Only the `background' is used in this face."
  :group 'eldoc-posframe)

(defun eldoc-posframe-enable ()
  "Enable `eldoc-posframe-mode' minor mode."
  (eldoc-posframe-mode 1))

(defun eldoc-posframe-disable ()
  "Disable `eldoc-posframe-mode' minor mode."
  (eldoc-posframe-mode 0))

(defun global-eldoc-posframe-enable ()
  "Globally enable `eldoc-posframe-mode' minor mode."
  (global-eldoc-posframe-mode 1))

(defun global-eldoc-posframe-disable ()
  "Globally disable `eldoc-posframe-mode' minor mode."
  (global-eldoc-posframe-mode 0))

;;;###autoload
(define-minor-mode eldoc-posframe-mode
  "A minor mode to show eldoc in a posframe."
  :require 'eldoc-posframe-mode
  :group 'eldoc-posframe
  :init-value t
  :lighter " ElDocPosframe"

  (if eldoc-posframe-mode
      (progn
        (setq-local eldoc-message-function #'eldoc-posframe-show-posframe)
        (eldoc-mode 1))
    (setq-local eldoc-message-function #'eldoc-minibuffer-message)))

;;;###autoload
(define-globalized-minor-mode global-eldoc-posframe-mode eldoc-posframe-mode eldoc-posframe-enable
  :group 'eldoc-posframe
  :init-value t)

(provide 'eldoc-posframe)
;;; eldoc-posframe.el ends here
