;;#! -*- coding: utf-8 -*-
;; ;;-----------------------------------------------------------------
;; ;; hatena-mode
;; ;;-----------------------------------------------------------------
;; (setq load-path (cons (expand-file-name "~/local/.emacs.d/hatena-diary") load-path))
;; (load "hatena-diary-mode")
;; (setq hatena-usrid "kenkitii")
;; (setq hatena-plugin-directory "~/local/.emacs.d/hatena-diary")

;; ;;-----------------------------------------------------------------
;; ;; emacs muse
;; ;;-----------------------------------------------------------------
;; (require 'muse-mode)     ; load authoring mode

;; (require 'muse-html)     ; load publishing styles I use
;; (require 'muse-latex)
;; (require 'muse-texinfo)
;; (require 'muse-docbook)
;; (require 'muse-wiki)
;; (setq muse-file-extension nil muse-mode-auto-p t)
;; ;; muse-html-encoding-default is a variable defined in `muse-html.el'.
;; ;; Its value is iso-8859-1

;; ;; Documentation:
;; ;; The default Emacs buffer encoding to use in published files.
;; ;; This will be used if no special characters are found.

;; (setq muse-html-encoding-default 'iso-2022-jp-unix)

;; ;; muse-latexcjk-encoding-default is a variable defined in `muse-latex.el'.
;; ;; Its value is "{GB}{song}"

;; ;; Documentation:
;; ;; The default Emacs buffer encoding to use in published files.
;; ;; This will be used if no special characters are found.
;; (setq muse-latexcjk-encoding-default
;;       (cdr (assoc 'japanese-iso-8bit muse-latexcjk-encoding-map)))

;; (require 'muse-project)
;; ;; project の定義
;; (setq muse-project-alist
;;       '(("Default"
;; 	("~/Dropbox/muse/default" :default "index")
;; 	(:base "html" :path "~/Dropbox/muse-web"))))
;; (add-to-list 'muse-project-alist
;;              '("Public"
;;                ("~/Dropbox/muse/public" :default "index")
;;                (:base "html" :path "~/Dropbox/muse-web/public")))

;; (defun my-muse-project-find-file (project)
;;   (interactive)
;;   (let ((muse-current-project (muse-project project)))
;;     (call-interactively 'muse-project-find-file)))

;; ;;(define-key ctl-x-map "M" 'my-muse-project-find-file "Default")
;; (define-key ctl-x-map "M" #'(lambda () (interactive)
;; 			      (my-muse-project-find-file "Default")))
;; ;; (global-set-key "\C-cpL" #'(lambda () (interactive)
;; ;;                              (my-muse-project-find-file "Blog")))

;; ;;-----------------------------------------------------------------
;; ;; Changelog Memo
;; ;;-----------------------------------------------------------------
;; (defun memo ()
;;   (interactive)
;;     (add-change-log-entry 
;;      nil
;;      (expand-file-name "~/Dropbox/memo.txt")))
;; (global-set-key "\C-xm" 'memo)

;; ;;-----------------------------------------------------------------
;; ;; howm
;; ;;-----------------------------------------------------------------
;; (add-to-list 'load-path "~/Dropbox/howm/")
;; (setq howm-menu-lang 'ja)
;; (setq howm-file-name-format "%Y-%m-%d.howm")
;; (setq howm-process-coding-system 'utf-8-unix)
;; (require 'howm-mode)

;; ;; http://howm.sourceforge.jp/cgi-bin/hiki/hiki.cgi?SaveAndKillBuffer
;; ;; C-cC-c で保存してバッファをキルする
;; (defun my-save-and-kill-buffer ()
;;   (interactive)
;;   (when (and
;;          (buffer-file-name)
;;          (string-match "\\.howm"
;;                        (buffer-file-name)))
;;     (save-buffer)
;;     (kill-buffer nil)))
;; (eval-after-load "howm"
;;   '(progn
;;      (define-key howm-mode-map
;;        "\C-c\C-c" 'my-save-and-kill-buffer)))

;;-----------------------------------------------------------------
;; autoit mode
;;-----------------------------------------------------------------
(require 'autoit-mode)
(add-to-list 'auto-mode-alist
	     '("\\.au3" . autoit-mode))


;;-----------------------------------------------------------------
;; EShell config
;;-----------------------------------------------------------------
;;; ENV
(setq exec-path (cons "/opt/local/bin" exec-path))
(setenv "PATH"
	(concat "/opt/local/bin:" (getenv "PATH")))
;; 補完時に大文字小文字を区別しない
(setq eshell-cmpl-ignore-case t)
;; 確認なしでヒストリ保存
(setq eshell-ask-to-save-history (quote always))
;; 補完時にサイクルする
(setq eshell-cmpl-cycle-completions t)
;;補完候補がこの数値以下だとサイクルせずに候補表示
(setq eshell-cmpl-cycle-cutoff-length 5)
;; 履歴で重複を無視する
(setq eshell-hist-ignoredups t)
;; キーバインドの変更
(add-hook 'eshell-mode-hook
          '(lambda ()
             (progn
               (define-key eshell-mode-map "\C-a" 'eshell-bol)
               (define-key eshell-mode-map "\C-p" 'eshell-previous-matching-input-from-input)
               (define-key eshell-mode-map "\C-n" 'eshell-next-matching-input-from-input)
               )
             ))
(setq eshell-output-filter-functions (list 'eshell-handle-ansi-color
                                           'eshell-handle-control-codes
                                           'eshell-watch-for-password-prompt))
(add-hook 'eshell-mode-hook 'ansi-color-for-comint-mode-on)


;; ;;-----------------------------------------------------------------
;; ;; It is preventing system from depriving of the shortcut key. 
;; ;;-----------------------------------------------------------------
;; (setq mac-pass-control-to-system nil)
;; (setq mac-pass-command-to-system nil)
;; (setq mac-pass-option-to-system nil)

;;-----------------------------------------------------------------
;; Share clipboard
;;-----------------------------------------------------------------
(setq x-select-enable-clipboard t) 

;;-----------------------------------------------------------------
;; font and window configuration etc.
;;-----------------------------------------------------------------
(if window-system
;;     (setq-default line-spacing
;; 		  (if (featurep 'ma-carbon) nil 2))
    (setq default-frame-alist
	  (append (list '(foreground-color . "white")
			'(background-color . "black")
			'(alpha . (80 80))
			) default-frame-alist))
    (setq initial-frame-alist
        (append
         '((fullscreen . fullboth))
         default-frame-alist)))

;; -----------------------------------------------------------------
;; 丸文字 font
;; -----------------------------------------------------------------
(if (eq window-system 'mac)
   (progn
    (require 'carbon-font)
     (fixed-width-set-fontset "hiramaru" 12)))

;;-----------------------------------------------------------------
;; fullscreen 
;;-----------------------------------------------------------------
;; http://groups.google.com/group/carbon-emacs/msg/55e93ee1f9c93d15
;; (set-frame-parameter nil 'fullscreen 'fullboth)
(defun toggle-fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen (if (frame-parameter
					    nil 'fullscreen)
                                           nil 'fullboth)))
(global-set-key [(meta return)] 'toggle-fullscreen)
(set-frame-parameter nil 'fullscreen 'fullboth) 

;;-----------------------------------------------------------------
;; ignore kotoeri shortcut key
;; http://un-q.net/2007/10/carbon_emacs_mac.html
;;-----------------------------------------------------------------
;; (mac-add-ignore-shortcut '(ctl ?@))
(when (fboundp 'mac-add-ignore-shortcut) (mac-add-ignore-shortcut '(control)))

;; ;; KeyRemap for Emacs-mode
;; (global-set-key [(control x)(right)] 'find-file)
;; (global-set-key [(control x)(left)] 'buffer-menu)

;; ;;-----------------------------------------------------------------
;; ;; titanium reload
;; ;;-----------------------------------------------------------------
;; (defun ti-send-run ()
;;   (setq proc (open-network-stream "titanium" nil "127.0.0.1" 9090))
;;   (process-send-string proc "GET /run HTTP/1.0\r\n\r\n")
;;   (sleep-for 1)
;;   (delete-process proc))

;; (defun reload-titanium ()
;;   (if (string-match "Resources" (buffer-file-name))
;;         (ti-send-run)))

;; (add-hook 'after-save-hook 'reload-titanium)

;; ;;-----------------------------------------------------------------
;; ;; Safari reload
;; ;;-----------------------------------------------------------------
;; (require 'moz)
;; (defvar moz-use-mozilla nil)
;; ;;(defvar moz-use-mozilla t)
;; (defun moz-send-reload ()
;;   (interactive)
;;   (unless (not moz-use-mozilla)
;;   (comint-send-string (inferior-moz-process)
;;                       (concat moz-repl-name ".pushenv('printPrompt', 'inputMode'); "
;;                               moz-repl-name ".setenv('inputMode', 'line'); "
;;                               moz-repl-name ".setenv('printPrompt', false); undefined; "))
;;   (comint-send-string (inferior-moz-process)
;;                       (concat "content.location.reload(true);\n"
;;                               moz-repl-name ".popenv('inputMode', 'printPrompt'); undefined;\n"))
;;   ))

;; (defun reload-moz()
;;   (unless (condition-case nil
;;               (run-mozilla)
;;             (error nil))
;;     (if (string-match "\.\\(css\\|js\\|php\\|html\\|htm\\|tpl\\|thtml\\|ctp\\|po\\|rb\\|haml\\|sass\\|cgi\\)$" (buffer-file-name))
;;         (moz-send-reload))))
;; (add-hook 'after-save-hook 'reload-moz)

;; (defun toggle-reload-moz ()
;;   "toggle reload moz"
;;   (interactive)
;;   (if moz-use-mozilla
;;       (setq moz-use-mozilla nil)
;;     (setq moz-use-mozilla t)))

;; (defun moz-switch-host ()
;;   "Show the inferior mozilla buffer.  Start the process if needed."
;;   (interactive)
;;   (if inferior-moz-buffer
;;     (kill-buffer inferior-moz-buffer))
;;     (setq moz-repl-host (read-string "Host: " "localhost"))
;;   (pop-to-buffer (process-buffer (inferior-moz-process)))
;;   (goto-char (process-mark (inferior-moz-process))))

;; ;; rsense
;; (setq rsense-home (expand-file-name "~/.emacs.d/elisp/rsense"))
;; (add-to-list 'load-path (concat rsense-home "/etc"))
;; (require 'rsense)
;; (add-hook 'ruby-mode-hook
;;           '(lambda ()
;;              ;; .や::を入力直後から補完開始
;;              (add-to-list 'ac-sources 'ac-source-rsense-method)
;;              (add-to-list 'ac-sources 'ac-source-rsense-constant)
;;              ;; C-x .で補完出来るようキーを設定
;;              (define-key ruby-mode-map (kbd "C-x .") 'ac-complete-rsense)))


;; auto-comlete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/local/.emacs.d//ac-dict")
(ac-config-default)

;; R-mode
(setq auto-mode-alist
     (cons (cons "\\.r$" 'R-mode) auto-mode-alist))
(autoload 'R-mode "ess-site" "Emacs Speaks Statistics mode" t)
