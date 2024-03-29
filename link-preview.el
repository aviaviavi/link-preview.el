;;; link-preview.el --- Fill in link preview details

;; Copyright (C) 2022 Avi Press
;; Author: Avi Press <mail@avi.press>
;; Version: 1.0
;; URL: https://github.com/aviaviavi/link-preview.el
;; Package-Requires: ((request "0.3.2"))

;;; Commentary:

;; This somewhat hacky code can be polished if it proves useful enough to people

;;; Code:

(require 'json)
(require 'request)

(defun link-preview-insert ()
  "Injects a link preview for the URL under your cursor."
  (interactive)
  (let ((link-preview-api "https://api.peekalink.io/")
        (link-preview-url (thing-at-point 'url)))
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
                  (insert "#+begin_preview")
                  (newline-and-indent)
                  (insert (assoc-default 'title data))
                  (newline-and-indent)
                  (insert (assoc-default 'description data))
                  (newline-and-indent)
                  (insert "#+end_preview")
                  (newline-and-indent)))
      :complete (cl-function
                 (lambda (&key response  &allow-other-keys)
                 (message "Complete: %s" (request-response-status-code response))))
      :error
      (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                     (message "Got error: %S" error-thrown))))))

(provide 'link-preview)
;;; link-preview.el ends here
