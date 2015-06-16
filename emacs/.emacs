; users generic .emacs file for Emacs
;;;--------------------------------------------------------------------------
;;; base configuration
;;;--------------------------------------------------------------------------

;; 削除確認などで yes/no と入れる代わりに y/n を使う
(fset 'yes-or-no-p 'y-or-n-p)

(require 'tramp)

;;; Japanese environment
(set-language-environment "Japanese")
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(if (not window-system)
    (set-terminal-coding-system 'utf-8))
(set-keyboard-coding-system 'utf-8)

(setq-default tab-width 4)

;;; configure load-path
(setq load-path (cons (expand-file-name "~/local/.emacs.d/") load-path))
(setq load-path (cons (expand-file-name "~/local/.emacs.d/auto-install") load-path))
(setq load-path (cons (expand-file-name "~/local/.emacs.d/ruby") load-path))

;;; Nihongo info mojibake taisaku
(auto-compression-mode t)
(add-to-list 'Info-default-directory-list "/usr/share/info/")

;;; jaspace.el makes Japanese 2-byte whitespaces visible
;;; http://homepage3.nifty.com/satomii/software/elisp.ja.html
(require 'jaspace)

;;; Do not display startup-message
(setq inhibit-startup-message t)

;;; color customization
(global-font-lock-mode t)

;;; high speed start up
(setq gc-cons-threshold 8242880)

;;; Move cursor line by line
(setq scroll-conservatively 35
       scroll-margin 5
       scroll-step 1)

;;; nondisplay initial scratch message
(setq initial-scratch-message "")

;;; don't make back up files like '*.~'
(setq make-backup-files nil)

;;; Enable backspace by C-h
(keyboard-translate ?\C-h ?\C-?)
(global-set-key "\M-?" 'help-for-help)
;;; Kill word by M-d 
(global-set-key (kbd "M-d") 'kill-word)

;;; don't add new line at end of buffer.
(setq next-line-add-newlines nil)

;; ;;; save and kill current buffer with C-c C-c command.
;; (defun my-save-and-kill-buffer ()
;;   (interactive)
;;   (save-buffer)
;;   (kill-buffer nil))
;; (global-set-key "\C-c\C-c" 'my-save-and-kill-buffer)

;; ;; Physical Line
;; (load "physical-line")
;; (global-set-key "\C-p"  'physical-line-previous-line)
;; (global-set-key "\C-n"  'physical-line-next-line)

;;; backward kill word on mini-buffer
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)

;; ;; kill-word
;; (define-key global-map "\M-d" 'kill-word)

;;; scroll-bar tool menu clear
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;;; highlight region
(transient-mark-mode t)

;;; highlight corresponding bracket(Emacs-21)
(show-paren-mode t)

;;; delete selected region by Ctrl+H
(defadvice backward-delete-char-untabify
  (around ys:backward-delete-region activate)
  (if (and transient-mark-mode mark-active)
      (delete-region (region-beginning) (region-end))
    ad-do-it))

;;; display escape for beautiful on shell-mode 
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
   "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;; auto install
(require 'auto-install)
(setq auto-install-directory "~/local/.emacs.d/auto-install/")
;; (auto-install-update-emacswiki-package-name t)
;; (auto-install-compatibility-setup)             ; 互換性確保

;;--------------------------------------------------------------------------
;; dired-mode
;;--------------------------------------------------------------------------
;; vi key assign for Emacs Dired mode
(setq dired-mode-hook
      (lambda nil
        (define-key dired-mode-map "h" 'dired-up-directory)
        (define-key dired-mode-map "j" 'dired-next-line)
        (define-key dired-mode-map "k" 'dired-previous-line)
        (define-key dired-mode-map "l" 'dired-maybe-insert-subdir)
	;; Don't create new buffer on dired-mode. default is *a*
	(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
	;; create new buffer on dired-mode.
	(define-key dired-mode-map "a" 'dired-advertised-find-file)
	(define-key dired-mode-map "c" 'dired-up-directory)
	(define-key dired-mode-map "o" 'dired-display-file)
	(define-key dired-mode-map (kbd "C-o") 'dired-find-file-other-window)
	))

;; highlight file to edit today on dired-mode.
(defface face-file-edited-today
  '((((class color)
      (background dark))
     (:foreground "GreenYellow"))
    (((class color)
      (background light))
     (:foreground "magenta"))
    (t
     ())) nil)
(defvar face-file-edited-today
  'face-file-edited-today)
(defun my-dired-today-search (arg)
  "Fontlock search function for dired."
  (search-forward-regexp
   (concat "\\(" (format-time-string
                  "%b %e" (current-time))
           "\\|"(format-time-string
                 "%m-%d" (current-time))
           "\\)"
           " [0-9]....") arg t))
(font-lock-add-keywords
 major-mode
 (list
  '(my-dired-today-search . face-file-edited-today)
  ))
;;--------------------------------------------------------------------------

;; delete file if size of file is zero.
(if (not (memq 'delete-file-if-no-contents after-save-hook))
    (setq after-save-hook
          (cons 'delete-file-if-no-contents after-save-hook)))
(defun delete-file-if-no-contents ()
  (when (and
         (buffer-file-name (current-buffer))
         (= (point-min) (point-max)))
    (when (y-or-n-p "Delete file and kill buffer?")
      (delete-file
       (buffer-file-name (current-buffer)))
      (kill-buffer (current-buffer)))))

;; ffap.el バッファ上に書いてあるパスを開く
(ffap-bindings)

;; recent-file-mode
(recentf-mode)

;; 折り返し表示ON/OFF
(defun toggle-truncate-lines ()
  "折り返し表示をトグル動作します."
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))
(global-set-key "\C-c\C-l" 'toggle-truncate-lines) ; 折り返し表示ON/OFF

;; ;;; Line Number
;; ;;; 
;; (setq wb-line-number-scroll-bar t)
;; (require 'wb-line-number)
;; (wb-line-number-toggle)
 	
;;; etags
(defadvice find-tag (before c-tag-file activate)
  "Automatically create tags file."
  (let ((tag-file (concat default-directory "TAGS")))
    (unless (file-exists-p tag-file)
      ;; (shell-command "etags *.[ch] *.el .*.el -o TAGS 2>/dev/null"))
      (shell-command "find . -name '*.[chsS] *.el .*.el' -print | etags -"))
    (visit-tags-table tag-file)))

;; ;;; isearch-occur
;; (defun isearch-occur ()
;;   "Invoke `occur' from within isearch."
;;   (interactive)
;;   (let ((case-fold-search isearch-case-fold-search))
;;     (occur
;;      (if isearch-regexp
;;          isearch-string (regexp-quote isearch-string)))))
;; (define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;;; make file executable, when the script is saved.
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;;;--------------------------------------------------------------------------
;; anything.el
;;;--------------------------------------------------------------------------
(require 'anything-startup)
;; restrain split-width-threshold error
(setq-default split-width-threshold nil)
(define-key global-map [(control ?:)] 'anything)
(define-key global-map [(control ?')] 'anything)

;; (require 'anything-config)
;; (define-key global-map [(control ?:)] 'anything)
;; (define-key global-map [(control ?')] 'anything)
;; (setq anything-sources 
;;       (list 
;;        anything-c-source-buffers
;;        anything-c-source-files-in-current-dir
;;        anything-c-source-file-name-history
;;        anything-c-source-bookmarks
;;        anything-c-source-recentf
;;        anything-c-source-complex-command-history
;;        ))

;; ;;;--------------------------------------------------------------------------
;; ;; insert date & comment
;; ;;;--------------------------------------------------------------------------
;; (defun insert-date()
;;        (interactive)
;;        (insert 
;; 	(let ((system-time-locale "C"))
;; 	  (format-time-string "%B %d,%Y %A %H:%M:%S"))))

;; (defun insert-comment()
;;   (interactive)
;;   (insert 
;;    (let ((system-time-locale "C"))
;;      (concat 
;;       "# Created: " (format-time-string "%B %d,%Y %A %H:%M:%S\n")
;;       "# Author: kenkiti (INOUE Tadashi)\n"
;;       "# $Id$\n"
;;       "# usage:\n"))))
;; (global-set-key [(control x)(T)] 'insert-comment)
;; (global-set-key [(control x)(t)] 'insert-date)

;;--------------------------------------------------------------------------
;; key configuration
;;--------------------------------------------------------------------------
;; goto-line: Esc-g
(global-set-key (kbd "M-g") 'goto-line)

;; ;; buffer-menu
;; (global-set-key [(control x)(control b)] 'buffer-menu)

;;--------------------------------------------------------------------------
;; Move to the head of the word by forward-word command.
;; http://d.hatena.ne.jp/kitokitoki/20090817/p1
;;--------------------------------------------------------------------------
(defun forward-word+1 ()
  (interactive)
  (forward-word)
  (forward-char))
(global-set-key (kbd "M-f") 'forward-word+1)
(global-set-key (kbd "C-M-f") 'forward-word+1)

;;;--------------------------------------------------------------------------
;;; High speed moving cursor
;;;--------------------------------------------------------------------------
;; speed up each 10 moving
(defvar scroll-speedup-count 10)
;; if cursor moved 10 lines, next moving each 2 lines.
(defvar scroll-speedup-rate 1)
;; if 800ms went by, return regular moving of cursor.
(defvar scroll-speedup-time 800)

;; from here, private variable
(defvar scroll-step-default 1)
(defvar scroll-step-count 1)
(defvar scroll-speedup-zero (current-time))

(defun scroll-speedup-setspeed ()
  (let* ((now (current-time))
         (min (- (car now)
                 (car scroll-speedup-zero)))
         (sec (- (car (cdr now))
                 (car (cdr scroll-speedup-zero))))
         (msec
          (/ (- (car (cdr (cdr now)))
                (car
                 (cdr (cdr scroll-speedup-zero))))
                     1000))
         (lag
          (+ (* 60000 min)
             (* 1000 sec) msec)))
    (if (> lag scroll-speedup-time)
        (progn
          (setq scroll-step-default 1)
          (setq scroll-step-count 1))
      (setq scroll-step-count
            (+ 1 scroll-step-count)))
    (setq scroll-speedup-zero (current-time))))

(defun scroll-speedup-next-line (arg)
  (if (= (% scroll-step-count
            scroll-speedup-count) 0)
      (setq scroll-step-default
            (+ scroll-speedup-rate
               scroll-step-default)))
  (if (string= arg 'next)
      (line-move scroll-step-default)
    (line-move (* -1 scroll-step-default))))

(defadvice next-line
  (around next-line-speedup activate)
  (if (and (string= last-command 'next-line)
           (interactive-p))
      (progn
        (scroll-speedup-setspeed)
        (condition-case err
            (scroll-speedup-next-line 'next)
          (error
           (if (and
                next-line-add-newlines
                (save-excursion
                  (end-of-line) (eobp)))
               (let ((abbrev-mode nil))
                 (end-of-line)
                 (insert "\n"))
             (line-move 1)))))
    (setq scroll-step-default 1)
    (setq scroll-step-count 1)
    ad-do-it))

(defadvice previous-line
  (around previous-line-speedup activate)
  (if (and
       (string= last-command 'previous-line)
       (interactive-p))
      (progn
        (scroll-speedup-setspeed)
        (scroll-speedup-next-line 'previous))
    (setq scroll-step-default 1)
    (setq scroll-step-count 1)
    ad-do-it))

;; ;; yasnippets.el
;; ;;(require 'yasnippet-bundle)
;; (require 'yasnippet)
;; (yas/initialize)
;; (yas/load-directory "~/local/.emacs.d/yasnippet/snippets")
;; (setq yas/trigger-key " ")
;; ;; 対応するsnippetがない場合はSPCを挿入する
;; (fset 'yas/default-trigger-fallback
;;       (lambda ()
;;         (interactive)
;;         (insert yas/trigger-key)))

;;-----------------------------------------------------------------
;; ChangeLog-mode
;;-----------------------------------------------------------------
(setq user-full-name "Tadashi Inoue")
(setq user-mail-address "nrg27943@gmail.com")

;; (defun memo ()
;;   (interactive)
;;     (add-change-log-entry 
;;      nil
;;      (expand-file-name "~/Dropbox/Document/diary.txt")))
;;      ;;(expand-file-name "~/local/memo/diary.txt")))
;; (define-key ctl-x-map "m" 'memo)

;; (defun memo2 ()
;;   (interactive)
;;     (add-change-log-entry 
;;      nil
;;      (expand-file-name "~/local/memo/stock.txt")))
;; (define-key ctl-x-map "c" 'memo2)

;; (defvar change-log-diary-file-name-regexp "[a-z]*.txt")
;; (defun add-log-iso8601-time-string-with-weekday ()
;;   (let ((system-time-locale "C"))
;;     (concat (add-log-iso8601-time-string)
;;             " " "(" (format-time-string "%a") ")")))
;; (add-hook 'change-log-mode-hook
;;           (function
;;            (lambda ()
;;              (if (and (buffer-file-name)
;;                       (string-match change-log-diary-file-name-regexp
;;                                     (buffer-file-name)))
;;                  (set (make-local-variable 'add-log-time-format)
;;                       'add-log-iso8601-time-string-with-weekday)))))

;;-----------------------------------------------------------------
;; find library file
;;-----------------------------------------------------------------
(defun find-library-file (library)
  (interactive "sFind libraly file: ")
  (let ((path (cons "" load-path)) exact match elc test fount)
    (while (and (not match) path)
      (setq test (concat (car path) "/" library)
	    match (if (condition-case nil
			  (file-readable-p test)
			(error nil))
		      test)
	    path (cdr path)))
    (setq path (cons "" load-path))
    (or match
	(while (and (not elc) path)
	  (setq test (concat (car path) "/" library ".elc")
		elc (if (condition-case nil
			    (file-readable-p test)
			  (error nil))
			test)
		path (cdr path))))
    (setq path (cons "" load-path))
    (while (and (not match) path)
      (setq test (concat (car path) "/" library ".el")
	    match (if (condition-case nil
			  (file-readable-p test)
			(error-nil))
		      test)
	    path (cdr path)))
    (setq found (or match elc))
    (if found
	(progn
	  (find-file found)
	  (and match elc
	       (message "(library file %s exists)" elc)
	       (sit-for 1))
	  (message "Found library file %s" found))
      (error "Library file \"%s\" not found." library))))

;; -----------------------------------------------------------------
;; backward-kill-word-or-region
;; -----------------------------------------------------------------
(defun backward-kill-word-or-region ()
  (interactive)
  (if mark-active
      (kill-region (region-beginning) (region-end))
    (backward-kill-word 1)))
(global-set-key "\C-w" 'backward-kill-word-or-region)

;; -----------------------------------------------------------------
;; Don't kill * scratch * buffer
;; -----------------------------------------------------------------
(defun my-make-scratch (&optional arg)
  (interactive)
  (progn
    ;; create "*scratch*" buffer and throws buffer-list.
    (set-buffer (get-buffer-create "*scratch*"))
    (funcall initial-major-mode)
    (erase-buffer)
    (when (and initial-scratch-message (not inhibit-startup-message))
      (insert initial-scratch-message))
    (or arg (progn (setq arg 0)
                   (switch-to-buffer "*scratch*")))
    (cond ((= arg 0) (message "*scratch* is cleared up."))
          ((= arg 1) (message "another *scratch* is created")))))

(add-hook 'kill-buffer-query-functions
          ;; The content deleted if kill-buffer on scratch buffer.
          (lambda ()
            (if (string= "*scratch*" (buffer-name))
                (progn (my-make-scratch 0) nil)
              t)))

(add-hook 'after-save-hook
          ;; Create scratch-buffer if saved *scratch* buffer.
          (lambda ()
            (unless (member (get-buffer "*scratch*") (buffer-list))
              (my-make-scratch 1))))


;; -----------------------------------------------------------------
;; mini-buffer
;; -----------------------------------------------------------------
; It is complete in M-x in a mini-buffer.
(require 'mcomplete)
; give priority to a history to use well.
(load "mcomplete-history")
(turn-on-mcomplete-mode)

;; (require 'cycle-mini)
;; (define-key minibuffer-local-map [up] 'previous-history-element)
;; (define-key minibuffer-local-completion-map [up] 'previous-history-element)
;; (define-key minibuffer-local-must-match-map [up] 'previous-history-element)
;; (define-key minibuffer-local-ns-map [up] 'previous-history-element)
;; (define-key minibuffer-local-ns-map [down] 'next-history-element)
;; (define-key minibuffer-local-map [down] 'next-history-element)
;; (define-key minibuffer-local-completion-map [down] 'next-history-element)
;; (define-key minibuffer-local-must-match-map [down] 'next-history-element)

;; -----------------------------------------------------------------
;; custom-set-variables
;; -----------------------------------------------------------------
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.32")
 '(ecb-source-path (quote ("~/")))
 '(eshell-output-filter-functions (quote (eshell-handle-control-codes eshell-watch-for-password-prompt eshell-postoutput-scroll-to-bottom)) t)
 '(eshell-scroll-show-maximum-output t)
 '(eshell-scroll-to-bottom-on-output nil)
 '(safe-local-variable-values (quote ((encoding . utf-8))))
 '(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
;;; end of file
;;;

;; ;; -----------------------------------------------------------------
;; ;; visible bookmark
;; ;; http://home.online.no/~jood/emacs/bm.el
;; ;; -----------------------------------------------------------------
;; (require 'bm)
;; (global-set-key [?\C-\,] 'bm-previous)
;; (global-set-key [?\C-\.] 'bm-next)
;; (global-set-key [?\C-\@] 'bm-toggle)

;; ;; -----------------------------------------------------------------
;; ;; bookmark autosave
;; ;; -----------------------------------------------------------------
;; (defadvice bookmark-set (around bookmark-set-ad activate)
;;   (bookmark-load bookmark-default-file t t) ;; 登録前に最新のブックマークを読み直す
;;   ad-do-it
;;   (bookmark-save))

;; (defadvice bookmark-jump (before bookmark-set-ad activate)
;;   (bookmark-load bookmark-default-file t t))

;; ;; bookmark
;; (global-set-key [(meta @)] 'bookmark-set)

;; -----------------------------------------------------------------
;; physical-line
;; -----------------------------------------------------------------
(global-set-key "\C-p" 'previous-window-line)
(global-set-key "\C-n" 'next-window-line)
(global-set-key [up] 'previous-window-line)
(global-set-key [down] 'next-window-line)
(defun previous-window-line (n)
  (interactive "p")
  (let ((cur-col
         (- (current-column)
            (save-excursion (vertical-motion 0) (current-column)))))
    (vertical-motion (- n))
    (move-to-column (+ (current-column) cur-col)))
  (run-hooks 'auto-line-hook)
  )
(defun next-window-line (n)
  (interactive "p")
  (let ((cur-col
         (- (current-column)
            (save-excursion (vertical-motion 0) (current-column)))))
    (vertical-motion n)
    (move-to-column (+ (current-column) cur-col)))
  (run-hooks 'auto-line-hook)
  )
 	
;; -----------------------------------------------------------------
;; Kill all open buffers. 
;; http://d.hatena.ne.jp/Ubuntu/20090501/1241143579
;; -----------------------------------------------------------------
(defun kill-all-buffers ()
  (interactive)
  (dolist (buf (buffer-list))
    (if (buffer-file-name buf) ; visit している buffer のみ削除
    (kill-buffer buf))))

;; revert buffer
(defun revert-current-buffer ()
  (interactive)
  (revert-buffer t t))
(defun revert-all-buffers ()
  (interactive)
  (let ((cbuf (current-buffer)))
    (dolist (buf (buffer-list))
      (if (not (buffer-file-name buf))
   nil
 (switch-to-buffer buf)
 (revert-buffer t t)))
    (switch-to-buffer cbuf)
    ))
;; (define-key global-map "\C-c\C-c\C-p" 'revert-current-buffer)
;; (define-key global-map "\C-c\C-c\ p" 'revert-all-buffers)
(define-key global-map "\C-x\C-k" 'kill-all-buffers)

;;-----------------------------------------------------------------
;; http://d.hatena.ne.jp/rubikitch/20100210/emacs
;;-----------------------------------------------------------------
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(global-set-key (kbd "C-o") 'other-window-or-split)

;; ;;-----------------------------------------------------------------
;; ;; tramp
;; ;;-----------------------------------------------------------------
;; (require 'tramp)
;; (setq tramp-default-method "ssh")

;;-----------------------------------------------------------------
;; dynamic macro
;; http://pitecan.com/papers/JSSSTDmacro/dmacro.el
;;-----------------------------------------------------------------
(defconst *dmacro-key* "\C-t" "repeat-key")
(global-set-key *dmacro-key* 'dmacro-exec)
(autoload 'dmacro-exec "dmacro" nil t)

;;-----------------------------------------------------------------
;; ispell
;;-----------------------------------------------------------------
;; ignore word of Japanese in ispell
(eval-after-load "ispell"
  '(setq ispell-skip-region-alist (cons '("[^\000-\377]")
                                        ispell-skip-region-alist)))
;; C-h prefix
(define-key help-map "/" 'ispell-complete-word)

;; ;;-----------------------------------------------------------------
;; ;; elscreen
;; ;;   * create: \C-o c
;; ;;   * kill: \C-o k
;; ;;   * next: \C-o n
;; ;;   * previous: \C-o p
;; ;;-----------------------------------------------------------------
;; (load "elscreen" "ElScreen" t) 
;; (elscreen-set-prefix-key "\C-o")

;; ;; -----------------------------------------------------------------
;; ;; translate by excite
;; ;; -----------------------------------------------------------------
;; (defun excite ()
;;   "translate by excite"
;;   (interactive)
;;   (if mark-active
;;       (progn
;;         (translate-by-excite (buffer-substring (region-beginning) (region-end)))
;;         (setq mark-active nil))
;;     (translate-by-excite (read-string "翻訳こんにゃく : "))))
;; (defun translate-by-excite (string)
;;   (get-buffer-create "*translated*")
;;   (display-buffer "*translated*")
;;   (shell-command (concat "ruby ~/local/bin/translate.rb \"" string "\"") "*translated*"))
;; (global-set-key (kbd "C-M-d") 'excite)

;;;--------------------------------------------------------------------------
;;; iimage.el
;;;--------------------------------------------------------------------------
(autoload 'iimage-mode "iimage" "Support Inline image minor mode." t)
(autoload 'turn-on-iimage-mode "iimage" "Turn on Inline image minor mode." t)
(setq iimage-mode-image-search-path '("image-dir"))
;; の検索時に iimage を自動 ON するには、次の設定を .emacs に加える。
(add-hook 'change-log-mode-hook 'turn-on-iimage-mode)

;;;--------------------------------------------------------------------------
;;; auto-complete
;;;--------------------------------------------------------------------------
;; (require 'auto-complete)
;; (global-auto-complete-mode t)
;; (setq map (make-sparse-keymap))
;; (define-key map "\C-s" 'ac-complete)

;; -----------------------------------------------------------------
;; (put 'erase-buffer 'disabled nil) ????
;; -----------------------------------------------------------------

;; -----------------------------------------------------------------
;; load user configuration
;; -----------------------------------------------------------------
;; (load "~/.emacs.tools.el") ;; mew etc
;; (load "~/.emacs.c.el")     ;; c language
;;(load "~/.emacs.ruby.el")     ;; c language
;; (load "~/.emacs.python.el")     ;; c language


;; 10 回ごとに加速
(defvar scroll-speedup-count 10)
;; 10 回下カーソルを入力すると，次からは 1+1 で 2 行ずつの
;; 移動になる
(defvar scroll-speedup-rate 1)
;; 800ms 経過したら通常のスクロールに戻す
(defvar scroll-speedup-time 800)

;; 以下，内部変数
(defvar scroll-step-default 1)
(defvar scroll-step-count 1)
(defvar scroll-speedup-zero (current-time))

(defun scroll-speedup-setspeed ()
  (let* ((now (current-time))
         (min (- (car now)
                 (car scroll-speedup-zero)))
         (sec (- (car (cdr now))
                 (car (cdr scroll-speedup-zero))))
         (msec
          (/ (- (car (cdr (cdr now)))
                (car
                 (cdr (cdr scroll-speedup-zero))))
                     1000))
         (lag
          (+ (* 60000 min)
             (* 1000 sec) msec)))
    (if (> lag scroll-speedup-time)
        (progn
          (setq scroll-step-default 1)
          (setq scroll-step-count 1))
      (setq scroll-step-count
            (+ 1 scroll-step-count)))
    (setq scroll-speedup-zero (current-time))))

(defun scroll-speedup-next-line (arg)
  (if (= (% scroll-step-count
            scroll-speedup-count) 0)
      (setq scroll-step-default
            (+ scroll-speedup-rate
               scroll-step-default)))
  (if (string= arg 'next)
      (line-move scroll-step-default)
    (line-move (* -1 scroll-step-default))))

(defadvice next-line
  (around next-line-speedup activate)
  (if (and (string= last-command 'next-line)
           (interactive-p))
      (progn
        (scroll-speedup-setspeed)
        (condition-case err
            (scroll-speedup-next-line 'next)
          (error
           (if (and
                next-line-add-newlines
                (save-excursion
                  (end-of-line) (eobp)))
               (let ((abbrev-mode nil))
                 (end-of-line)
                 (insert "\n"))
             (line-move 1)))))
    (setq scroll-step-default 1)
    (setq scroll-step-count 1)
    ad-do-it))

(defadvice previous-line
  (around previous-line-speedup activate)
  (if (and
       (string= last-command 'previous-line)
       (interactive-p))
      (progn
        (scroll-speedup-setspeed)
        (scroll-speedup-next-line 'previous))
    (setq scroll-step-default 1)
    (setq scroll-step-count 1)
    ad-do-it))

;;;--------------------------------------------------------------------------
;;; autocomplete
;;;--------------------------------------------------------------------------
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/local/.emacs.d//ac-dict")
(ac-config-default)
;;;--------------------------------------------------------------------------

(cond
 ((featurep 'meadow)
  (load "~/.emacs.meadow.el"))
 ((string-match "22.0.93.1" (emacs-version))
  (load "~/.emacs.nt.el"))
 ((string-match "23.0.0.2" (emacs-version))
  (load "~/.emacs.freebsd.el"))
 ((string-match "i686-pc-linux-gnu" (emacs-version))
  (load "~/.emacs.ubuntu.el"))
 ((string-match "i386-apple-darwin" (emacs-version))
  (load "~/.emacs.macbook.el"))
)


(put 'dired-find-alternate-file 'disabled nil)
