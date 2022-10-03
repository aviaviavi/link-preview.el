;;; link-preview.el --- Fill in link preview details

;; Copyright (C) 2022 Avi Press
;; Author: Avi Press <mail@avi.press>
;; Version: 1.0
;; URL: https://github.com/aviaviavi/link-preview-emacs

;;; Commentary:

;; Full documentation is available as an Info manual.

;;; Code:

(require 'json)
(require 'request)

(setq link-preview-api "https://api.peekalink.io/")

(defun lp/expand-link-at-cursor ()
  (interactive)
  (setq link-preview-url (thing-at-point 'url))
  (message "json: %S" (json-encode `(("link" . ,link-preview-url))))
  (request link-preview-api
    :type "POST"
    :sync t
    :loglevel 'debug
    :data (json-encode `(("link" . ,link-preview-url)))
    :parser 'json-read
    :headers `(("Content-Type" . "application/json") ("X-API-Key" . ,(getenv "PEEKALINK_API_KEY")))
    :success (cl-function
              (lambda (&key data &allow-other-keys)
                (message "%S" (assoc-default 'title data))
                (message "%S" (assoc-default 'description data))
                (end-of-line)
                (forward-line 1)
                (insert (assoc-default 'title data))
                (newline-and-indent)
                (insert (assoc-default 'description data))
                (newline-and-indent)
                ))
    :complete (lambda (&rest _) (message "Finished!"))
    :error
    (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                  (message "Got error: %S" error-thrown)))))



