;;; offlineimap.el --- Run OfflineIMAP from Emacs

;; Copyright (C) 2010 Julien Danjou

;; Author: Julien Danjou <julien@danjou.info>
;; URL: http://julien.danjou.info/offlineimap-el.html

;; This file is NOT part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; M-x offlineimap

(require 'comint)

(defgroup offlineimap nil
  "Run OfflineIMAP."
  :group 'comm)

(defcustom offlineimap-buffer-name "*OfflineIMAP*"
  "Name of the buffer used to run offlineimap."
  :group 'offlineimap
  :type 'string)

(defcustom offlineimap-command "offlineimap -u Noninteractive.Basic"
  "Command to run to launch OfflineIMAP."
  :group 'offlineimap
  :type 'string)

(defcustom offlineimap-buffer-maximum-size comint-buffer-maximum-size
  "The maximum size in lines for OfflineIMAP buffer."
  :group 'offlineimap
  :type 'integer)

(defvar offlineimap-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "q") 'offlineimap-quit)
    (define-key map (kbd "g") 'offlineimap-resync)
    map)
  "Keymap for offlineimap-mode.")

(defface offlineimap-syncing-face
  '((t (:foreground "cyan")))
  "Face used to highlight syncing lines.")

(defface offlineimap-scanning-face
  '((t (:foreground "green")))
  "Face used to highlight scanning lines.")

(defface offlineimap-copying-face
  '((t (:foreground "blue")))
  "Face used to highlight copying lines.")

(defface offlineimap-copy-message-face
  '((t (:foreground "yellow")))
  "Face used to highlight message copy lines.")

(defface offlineimap-adding-flags-face
  '((t (:foreground "yellow" :weight bold)))
  "Face used to highlight flags adding lines.")

(defface offlineimap-next-sync-face
  '((t (:foreground "red")))
  "Face used to highlight next sync lines.")

(defvar offlineimap-mode-font-lock-keywords
  '(("^Syncing .*$" . 'offlineimap-syncing-face)
    ("^Scanning .*$" . 'offlineimap-scanning-face)
    ("^Copying .*$" . 'offlineimap-copying-face)
    ("^Adding flags .*$" . 'offlineimap-adding-flags-face)
    ("^Next sync .*$" . 'offlineimap-next-sync-face)
    ("^Copy message .*$" . 'offlineimap-copy-message-face))
  "Faces used to highlight things in OfflineIMAP mode.")

(defun offlineimap-make-buffer ()
  "Get the offlineimap buffer."
  (let ((buffer (get-buffer-create offlineimap-buffer-name)))
    (with-current-buffer buffer
      (offlineimap-mode))
    buffer))

;;;###autoload
(defun offlineimap ()
  "Start OfflineIMAP."
  (interactive)
  (comint-exec
   (offlineimap-make-buffer)
   "offlineimap"
   shell-file-name nil
   `("-c" ,offlineimap-command)))

(defun offlineimap-quit ()
  "Quit OfflineIMAP."
  (interactive)
  (kill-buffer (current-buffer)))

(defun offlineimap-resync ()
  "Send a USR1 signal to OfflineIMAP to force accounts synchronization."
  (interactive)
  (signal-process (get-buffer-process (get-buffer offlineimap-buffer-name) 'SIGUSR1)))

(define-derived-mode offlineimap-mode comint-mode "OfflineIMAP"
  "A major mode for OfflineIMAP interaction."
  :group 'comm
  (set (make-local-variable 'comint-output-filter-functions)
       '(comint-postoutput-scroll-to-bottom comint-truncate-buffer))
  (set (make-local-variable 'comint-buffer-maximum-size)
                            offlineimap-buffer-maximum-size)
  (font-lock-add-keywords nil offlineimap-mode-font-lock-keywords))

(provide 'offlineimap)
