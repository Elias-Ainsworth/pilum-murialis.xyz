;; -*- lexical-binding: t; -*-
(require 'ox-publish)

(setq org-publish-project-alist
      (let ((base-dir (file-name-directory load-file-name)))
        `(
          ;; Publish Org files to HTML
          ("website-org"
           :base-directory ,(expand-file-name "pages" base-dir)
           :base-extension "org"
           :publishing-directory ,(expand-file-name "out" base-dir)
           :recursive t
           :publishing-function org-html-publish-to-html
           :with-author t
           :with-creator t
           :section-numbers nil
           :with-toc nil
           :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"./assets/style.css\" />"
           :html-preamble t)

          ;; Publish all assets (CSS, JS, images, fonts) recursively
          ("website-assets"
           :base-directory ,(expand-file-name "assets" base-dir)
           :base-extension "css\\|js\\|png\\|jpg\\|jpeg\\|svg\\|gif\\|otf\\|ttf\\|woff\\|woff2"
           :publishing-directory ,(expand-file-name "out/assets" base-dir)
           :recursive t
           :publishing-function org-publish-attachment)

          ;; Combined publishing pipeline
          ("website" :components ("website-org" "website-assets"))
        )))

(message "Org-publish ready: Run M-x org-publish RET website RET")
