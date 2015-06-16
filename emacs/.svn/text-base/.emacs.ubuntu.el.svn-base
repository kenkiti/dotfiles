;;-----------------------------------------------------------------
;; base configuration
;;-----------------------------------------------------------------
(let ((default-directory "~/local/lisp"))
  (setq load-path (cons default-directory load-path))
  (normal-top-level-add-subdirs-to-load-path))

;; window
(if window-system
    (setq default-frame-alist
	  (append (list '(foreground-color . "LemonChiffon")
			'(background-color . "black")
			'(border-color . "black")
			'(mouse-color . "white")
			'(cursor-color . "black")
			'(font . "Bitstream Vera Sans Mono-10")
			'(alpha . (85 65))
			) default-frame-alist)))


;;-----------------------------------------------------------------
;; Dictionary - Lookup configuration
;;-----------------------------------------------------------------
(autoload 'lookup "lookup" nil t)
(autoload 'lookup-region "lookup" nil t)
(autoload 'lookup-pattern "lookup" nil t)

(define-key ctl-x-map "l" 'lookup)              ;C-x l -lookup
(define-key ctl-x-map "y" 'lookup-region)       ;C-x y -lookup-region
(define-key ctl-x-map "\C-y" 'lookup-pattern)   ;C-x C-y -lookup-pattern

(setq lookup-search-agents '((ndtp "localhost")))

;;-----------------------------------------------------------------
;; Emacs Muse-mode
;;-----------------------------------------------------------------
(require 'muse-mode)                    ; load authoring mode
(require 'muse-html)                    ; load publishing styles I use
(require 'muse-latex)
(require 'muse-texinfo)
(require 'muse-docbook)
(require 'muse-project)
(require 'muse-wiki)
(add-to-list 'muse-project-alist
	     '("Default"
	       ("~/local/Wiki/Private" :default "index")
	       (:base "html" :path "~/local/html/Private")))
(add-to-list 'muse-project-alist
	     '("Default"
	       ("~/local/Wiki/Public" :default "index")
	       (:base "html" :path "~/local/html/Public")))
(add-to-list 'muse-project-alist
	     '("Default"
	       ("~/local/Wiki/PublicOld" :default "index")
	       (:base "html" :path "~/local/html/Public_old")))
(setq muse-html-style-sheet
      "<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"all\" href=\"core.css\">")
(defcustom muse-footer-date-format "%Y-%m-%d %H:%M:%S"
  "Format of current date for `muse-html-footer'.
This string must be a valid argument to `format-time-string'."
  :type 'string
  :group 'muse-publish)

(defun open-my-wiki ()
  (interactive)
  (find-file "~/local/Wiki/Private/WelcomePage.muse"))
(define-key ctl-x-map "w" 'open-my-wiki)

(setq muse-html-footer
  "
    <!-- Page published by Emacs Muse ends here -->
    <div class=\"navfoot\">
      <hr />
      <table width=\"100%\" border=\"0\" summary=\"Footer navigation\">
        <col width=\"33%\" /><col width=\"34%\" /><col width=\"33%\" />
        <tr>
          <td align=\"left\">
            <lisp>
              (concat
                \"<span><em><a href=\\\"mailto:kenkiti@gmail.com\\\">Tadashi Inoue</a></em></span><br>\"
                (if (muse-current-file)
                  (concat
                   \"<span class=\\\"footdate\\\">Updated: \"
                   (format-time-string muse-footer-date-format
                    (nth 5 (file-attributes (muse-current-file))))
                   \"</span>\")))
            </lisp>
          </td>
          <td align=\"center\">
            <span class=\"foothome\">
            </span>
          </td>
          <td align=\"right\">
            <lisp>
                (if
                  (string-match
                     (car (or muse-current-project (muse-project-of-file)))
                     \"Default\")
                  \"<a href=\\\"../index.html\\\">Home</a>\"
                  (concat
                   \"<a href=\\\"../index.html\\\">Home</a> / <a href=\\\"index.html\\\">\"
                   (car (or muse-current-project (muse-project-of-file)))
                   \"Home</a>\"))
            </lisp>
          </td>
        </tr>
      </table>
    </div>
  </body>
</html>\n")

;;-----------------------------------------------------------------
;; Python-mode
;;-----------------------------------------------------------------
(autoload 'python-mode "python-mode" "Mode for editing Python source files")
(add-to-list 'auto-mode-alist '("\\.py" . python-mode))

;;-----------------------------------------------------------------
;; ruby-mode
;;-----------------------------------------------------------------
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("\\.rb$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          '(lambda ()
            (inf-ruby-keys)))

