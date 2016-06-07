;;; eswap-mode.el --- Toggle src/target files

;; Copyright (C) 2015 Djangoliv'

;; Author: Djangoliv <djangoliv@mailoo.com>
;; URL:  https://github.com/djangoliv/conf
;; Version: 0.1
;; Keywords: project, toggle, src

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; eswap-mode is a minor mode for toggling between src and target files
;; the mode just toggle path of the current buffer file

;; To use eswap-mode, make sure that this file is in Emacs load-path
;; (add-to-list 'load-path "/path/to/directory/")
;;
;; Then require eswap-mode
;; (require 'eswap-mode)

;; To start eswap-mode
;; (deswap-mode t) or M-x eswap-mode
;;
;; eswap-mode is buffer local, so hook it up
;; (add-hook 'python-mode-hook 'eswap-mode)
;;
;; Or use the global mode to activate it in all buffers.
;; (eswap-global-mode t)

;; eswap stores a list (`eswap-except-modes') of modes in
;; which `eswap-mode' should not be activated in (note, only if
;; you use the global mode) because of conflicting use.
;;
;; You can add new except modes:
;;   (add-to-list 'eswap-except-modes 'conflicting-mode)

;; eswap-mode need to know about the path of your source and target files
;; please replace the path of the `eswap-toggle-path-alist' variable
;; (setq eswap-toggle-path-alist ;; (srcPath . targetPath )
;;       (quote
;;        (("/path/to/root/of/project1/src/files" . "/path/to/root/of/project1/target/files")
;;         ("/path/to/root/of/project2/src/files" . "/path/to/root/of/project2/target/files")
;;         ;; ("" . "") ;;...
;;         )))

;; example:
;; source path is /path/to/my/sourceDir/subdir1/subdir2/fileName
;; target path is /path/to/my/targetDir/subdir1/subdir2/fileName
;; (setq eswap-toggle-path-alist
;;       (quote
;;        (("/path/to/my/sourceDir" . "path/to/my/targetDir"))))

;;; Code:

(eval-when-compile
  (require 'cl))

(defvar eswap-except-modes '(calc-mode dired-mode)
  "A list of modes in which `eswap-mode' should not be activated.")

(defvar eswap-mode-map (make-sparse-keymap)
  "Keymap for `eswap-mode'.")

(defvar eswap-toggle-path-alist ()
  "list of path correspondence for `eswap-mode'.")

(defvar eswap-line)

(defun eswap-current-file ()
  "toggle src/target file"
  (interactive)
  (setq eswap-line (line-number-at-pos))
  (setq es-do-it nil)
  (dolist (paths eswap-toggle-path-alist)
    (let ((srcPath (file-name-as-directory (car paths)))
          (targetPath (file-name-as-directory (cdr paths))))
      (if (string-match-p srcPath (buffer-file-name)) ;; src file goto target
          (progn
            (find-file (replace-regexp-in-string srcPath targetPath (buffer-file-name) t))
            (setq es-do-it t)
            (forward-line (- eswap-line (line-number-at-pos))))
        (progn
          (if (string-match-p targetPath (buffer-file-name)) ;; target file goto src
              (progn
                (find-file (replace-regexp-in-string targetPath srcPath (buffer-file-name) t))
                (setq es-do-it t)
                (forward-line (- eswap-line (line-number-at-pos)))))))))
  (if (not es-do-it)
      (message "not a project file")
    (message "toggle")))

(defun eswap-replace-target-file ()
  "copy src file as target file"
  (interactive)
  (setq es-do-it nil)
  (dolist (paths eswap-toggle-path-alist)
    (let ((srcPath (file-name-as-directory (car paths)))
          (targetPath (file-name-as-directory (cdr paths))))
      (if (string-match-p (car paths) (buffer-file-name)) ;; src file copy as target
          (progn
            (copy-file (buffer-file-name) (replace-regexp-in-string srcPath targetPath (buffer-file-name) t) t)
            (message (concat "copy as " (replace-regexp-in-string srcPath targetPath (buffer-file-name) t)))
            (setq es-do-it t)))))
  (if (not es-do-it)
      (message "not a src file")))

(defun eswap-replace-src-file ()
  "copy target file as src file"
  (interactive)
  (setq es-do-it nil)
  (dolist (paths eswap-toggle-path-alist)
    (let ((srcPath (file-name-as-directory (car paths)))
          (targetPath (file-name-as-directory (cdr paths))))
      (if (string-match-p (cdr paths) (buffer-file-name)) ;; target file copy as src
          (progn
            (copy-file (buffer-file-name) (replace-regexp-in-string targetPath srcPath (buffer-file-name) t) t)
            (message (concat "copy as " (replace-regexp-in-string targetPath srcPath (buffer-file-name) t)))
            (setq es-do-it t)))))
  (if (not es-do-it)
      (message "not a target file")))

(defun eswap-define-keys ()
  "Defines keys for `drag-stuff-mode'."
  (define-key eswap-mode-map (kbd "<f5>") 'eswap-current-file)
  (define-key eswap-mode-map (kbd "C-<f5>") 'eswap-replace-target-file)
  (define-key eswap-mode-map (kbd "C-S-<f5>") 'eswap-replace-src-file))

;;;###autoload
(define-minor-mode eswap-mode
  "Toggle and copy files between sources and install folders"
  :init-value nil
  :lighter " eswap"
  :keymap eswap-mode-map
  (when eswap-mode
    (eswap-define-keys)))
  
;;;###autoload
(defun turn-on-eswap-mode ()
  "Turn on `eswap-mode'."
  (interactive)
  (unless (member major-mode eswap-except-modes)
    (eswap-mode +1)))

;;;###autoload
(defun turn-off-eswap-mode ()
  "Turn off `eswap-mode'."
  (interactive)
  (eswap-mode -1))

;;;###autoload
(define-globalized-minor-mode eswap-global-mode
  eswap-mode
  turn-on-eswap-mode)

(provide 'eswap-mode)

;;; eswap-mode.el ends here
