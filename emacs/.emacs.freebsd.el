;;-----------------------------------------------------------------
;; general 
;;-----------------------------------------------------------------
(let ((default-directory "/usr/local/share/emacs/21.3/site-lisp/"))
  (setq load-path (cons default-directory load-path))
  (normal-top-level-add-subdirs-to-load-path))

;; emacs-client
(server-start)

;; shell
(setq shell-file-name "/bin/tcsh")

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
                    ) default-frame-alist))
)

;; font
;; (set-face-font 'default "-sazanami-gothic-medium-r-normal--0-0-0-0-c-0-jisx0212.1990-0")

;;-----------------------------------------------------------------
;; anthy
;;-----------------------------------------------------------------
;; (push "/usr/local/share/emacs/site-lisp/anthy" load-path)
;; (load-file "/usr/local/share/emacs/site-lisp/anthy/leim-list.el")
;; (load-library "anthy")
;; (setq default-input-method 'japanese-anthy)
(push "/usr/local/share/emacs/site-lisp/" load-path)
(require 'init-mell)
(require 'init-suikyo)
(require 'init-prime)
;; (setq default-input-method "japanese-prime")
;;-----------------------------------------------------------------
;; ECB
;;-----------------------------------------------------------------
(load-file "/usr/local/share/emacs/21.3/site-lisp/cedet/common/cedet.el")
(setq semantic-load-turn-useful-things-on t)
(add-to-list 'load-path "/usr/local/share/emacs/21.3/site-lisp/ecb/")

(require 'ecb)
(setq ecb-tip-of-the-day nil)
(setq ecb-windows-width 0.20)

(defun ecb-toggle ()
  (interactive)
  (if ecb-minor-mode
      (ecb-deactivate) 
    (ecb-activate)))
(global-set-key [f2] 'ecb-toggle)
;;(global-set-key [f5] 'ecb-goto-window-directories)
(global-set-key [f5] 'ecb-goto-window-methods)
(global-set-key [f6] 'ecb-goto-window-sources)
(global-set-key [f7] 'ecb-goto-window-edit-last)
(setq ecb-layout-name "left9")
;; (define-key tree-buffer-key-map (kbd "<C-p>") 'tree-buffer-arrow-pressed)
;; (define-key tree-buffer-key-map (kbd "<C-n>") 'tree-buffer-arrow-pressed)
;; (define-key tree-buffer-key-map (kbd "<C-f>") 'tree-buffer-arrow-pressed)
;; (define-key tree-buffer-key-map (kbd "<C-b>") 'tree-buffer-arrow-pressed))
'(ecb-wget-setup (quote 'cons))
;; '(ecb-wget-setup '(quote cons)) 

;;-----------------------------------------------------------------
;; Python-mode
;;-----------------------------------------------------------------
(autoload 'python-mode "python-mode" "Mode for editing Python source files")
(add-to-list 'auto-mode-alist '("\\.py" . python-mode))

;;-----------------------------------------------------------------
;; Taken from the comment section in inf-ruby.el
;;-----------------------------------------------------------------
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files")
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby" "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook '(lambda () (inf-ruby-keys)))

;; refe
(require 'refe)

;;-----------------------------------------------------------------
;; rails.el
;;-----------------------------------------------------------------
(defun try-complete-abbrev (old)
  (if (expand-abbrev) t nil))

(setq hippie-expand-try-functions-list
  '(try-complete-abbrev
    try-complete-file-name
    try-expand-dabbrev))
(require 'rails)

;; switch controller <--> view
(define-key rails-minor-mode-map "\C-c\C-p" 'rails-lib:run-primary-switch)
;; switch file
(define-key rails-minor-mode-map "\C-c\C-n" 'rails-lib:run-secondary-switch)

;; rhtml wo html-mode ni.
(setq auto-mode-alist  (cons '("\\.rhtml$" . html-mode) auto-mode-alist))

;;-----------------------------------------------------------------
;; auto etags
;;-----------------------------------------------------------------
;; (defadvice find-tag (before c-tag-file activate)
;;   "Automatically create tags file."
;;   (let ((tag-file (concat default-directory "TAGS")))
;;     (unless (file-exists-p tag-file)
;;       (shell-command "etags *.[ch] *.el .*.el -o TAGS 2>/dev/null"))
;;     (visit-tags-table tag-file)))


;; タグファイルの自動生成
(defadvice find-tag (before c-tag-file activate)
  "Automatically create tags file."
  (let ((tag-file (concat default-directory "TAGS")))
    (unless (file-exists-p tag-file)
      (shell-command "eptags.py *.py"))
    (visit-tags-table tag-file)))

;;-----------------------------------------------------------------
;; vc-svn
;;-----------------------------------------------------------------
(add-to-list 'vc-handled-backends 'SVN)  

;; ;;-----------------------------------------------------------------
;; ;; psvn.el
;; ;;-----------------------------------------------------------------
;; (require 'psvn)

;; (define-key svn-status-mode-map "Q" 'egg-self-insert-command)
;; (define-key svn-status-mode-map "q" 'svn-status-bury-buffer)
;; (define-key svn-status-mode-map "p" 'svn-status-previous-line)
;; (define-key svn-status-mode-map "n" 'svn-status-next-line)
;; (define-key svn-status-mode-map "<" 'svn-status-examine-parent)

;; (add-hook 'dired-mode-hook
;;           '(lambda ()
;;              (require 'dired-x)
;;              ;;(define-key dired-mode-map "V" 'cvs-examine)
;;              (define-key dired-mode-map "V" 'svn-status)
;;              (turn-on-font-lock)
;;              ))

;; (setq svn-status-hide-unmodified t)
;; (setq process-coding-system-alist
;;       (cons '("svn" . euc-jp) process-coding-system-alist))
