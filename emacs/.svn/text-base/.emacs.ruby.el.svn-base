;;-----------------------------------------------------------------
;; ruby-mode
;;-----------------------------------------------------------------
;; ruby-mode
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)                                               
(setq auto-mode-alist
      (append '(("\\.(rb|god)$" . ruby-mode)) auto-mode-alist))

(setq auto-mode-alist
      (append '(("Rakefile" . ruby-mode)) auto-mode-alist))
;; (setq auto-mode-alist
;;       (append (list
;; 	       '("\\.(rb|god)$" . ruby-mode)
;; 	       '("Rakefile" . ruby-mode)
;; 	       auto-mode-alist)))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))
(setq ruby-deep-indent-paren-style nil) ;; change indent-style

;; inf-ruby
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")                                  
(autoload 'inf-ruby-keys "inf-ruby" "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby-keys)))

;; ruby-electric
(require 'ruby-electric)
(add-hook 'ruby-mode-hook (lambda () (ruby-electric-mode 1)))
(setq ruby-electric-expand-delimiters-list '( ?\{)) ;; expand only {}

;; rcodetools
;; install:
;;  # gem install rcodetools
;;  # cp /Library/Ruby/Gems/1.8/gems/rcodetools-0.7.0.0/rcodetools.el ~/local/.emacs.d/ruby
(require 'rcodetools)
(setq rct-find-tag-if-available nil)
(defun make-ruby-scratch-buffer ()
  (with-current-buffer (get-buffer-create "*ruby scratch*")
    (ruby-mode)
    (current-buffer)))
(defun ruby-scratch ()
  (interactive)
  (pop-to-buffer (make-ruby-scratch-buffer)))
(defun ruby-mode-hook-rcodetools ()
  (define-key ruby-mode-map "\M-\C-i" 'rct-complete-symbol)
;;   (define-key ruby-mode-map "\C-c\C-t" 'ruby-toggle-buffer) ;; tukaenai?
  (define-key ruby-mode-map "\C-c\C-d" 'xmp)
  ;;(define-key ruby-mode-map "\C-c\C-f" 'rct-ri))
  (define-key ruby-mode-map "\C-c\C-f" 'refe))
(add-hook 'ruby-mode-hook 'ruby-mode-hook-rcodetools)

;; refe
(require 'refe)
;; ;; etags for ruby #### umaku ugokanai....
;; (defvar etags-tag-rebuild-command-ruby
;;       (concat "find ./ -name \\*.rb | xargs etags --language=none --regex="
;;               "'/[ \\t]*\\(def\\|class\\|module\\)[ \\t]\\([^ \\t]+\\)/\\2/'")
;;       "Create tag file for Ruby script.")
;; (defun etags-tag-rebuild-ruby (command)
;;   (interactive
;;    (list (read-shell-command "Etags command: " etags-tag-rebuild-command-ruby))
;;    (list etags-tag-rebuild-command-ruby))
;;   (shell-command command))

(defun ruby-insert-magic-comment-if-needed ()
  "バッファの coding-system をもとに magic comment をつける。"
  (when (and (eq major-mode 'ruby-mode)
             (find-multibyte-characters (point-min) (point-max) 1))
    (save-excursion
      (goto-char 1)
      (when (looking-at "^#!") 
        (forward-line 1))
      (if (re-search-forward "^#.+coding" (point-at-eol) t)
          (delete-region (point-at-bol) (point-at-eol))
        (open-line 1))
      (let* ((coding-system (symbol-name buffer-file-coding-system))
             (encoding (cond ((string-match "japanese-iso-8bit\\|euc-j" coding-system)
                              "euc-jp")
                             ((string-match "shift.jis\\|sjis\\|cp932" coding-system)
                              "shift_jis")
                             ((string-match "utf-8" coding-system)
                              "utf-8"))))
        (insert (format "# -*- coding: %s -*-" encoding))))))

(add-hook 'before-save-hook 'ruby-insert-magic-comment-if-needed)

;;-----------------------------------------------------------------
;; ruby-mode-compile
;;-----------------------------------------------------------------
(defvar ruby-dbg-flags "-w"
  "*Flags to give to perl for debugging a Ruby script.")

(defvar ruby-compilation-error-regexp-alist
  '( ("^\\([^:]+rb\\):\\([0-9]+\\):.*" 1 2))
    "Alist that specifies how to match errors in Ruby output.
See variable compilation-error-regexp-alist for more details.")

(defun ruby-compile ()
  (mc--shell-compile "ruby" ruby-dbg-flags ruby-compilation-error-regexp-alist))

;; ;;-----------------------------------------------------------------
;; ;; rails.el
;; ;;-----------------------------------------------------------------
;; (defun try-complete-abbrev (old)
;;   (if (expand-abbrev) t nil))

;; (setq hippie-expand-try-functions-list
;;       '(try-complete-abbrev
;;         try-complete-file-name
;;         try-expand-dabbrev))
;; (setq rails-use-mongrel t)
;; (require 'rails)

;;-----------------------------------------------------------------
;; haml-mode and sass-mode
;;-----------------------------------------------------------------
;;haml-mode
(require 'haml-mode nil 't)
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))
;;sass-mode
(require 'sass-mode nil 't)
(add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))

;; ;; -----------------------------------------------------------------
;; ;; snipet.el
;; ;; -----------------------------------------------------------------
;; (require 'snippet)
;; (add-hook 'python-mode-hook
;;   (function (lambda ()
;;     (setq-default abbrev-mode t)
;;     (snippet-with-abbrev-table 'local-abbrev-table
;;       ("def" . "def $${func_name}($${arg}):\n$>")
;;       ("for" .  "for $${element} in $${sequence}:\n$>")
;;       ("im"  .  "import $$\n")
;;       ("if"  .  "if $${True}:\n$>")
;;       ("wh"  .  "while $${True}:\n$>")
;;       ))))
 
;;-----------------------------------------------------------------
;; rspec-mode 
;;-----------------------------------------------------------------
;; 上手く動かない
;; (require 'snippet)
;; (add-hook 'ruby-mode-hook
;;           '(lambda ()
;;              (setq-default abbrev-mode t) ;; abbrev-mode をon
;;              (snippet-with-abbrev-table 'local-abbrev-table
;;                                         ("pu" . "puts")
;;                                         )
;;              ))
;; (require 'compile)
;; (require 'rspec-mode)
