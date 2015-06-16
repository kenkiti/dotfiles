;; -----------------------------------------------------------------
;; Mew
;; -----------------------------------------------------------------
(autoload 'mew "mew" nil t)
(autoload 'mew-send "mew" nil t)

(if (boundp 'read-mail-command)
    (setq read-mail-command 'mew))
(autoload 'mew-user-agent-compose "mew" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'mew-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'mew-user-agent
      'mew-user-agent-compose
      'mew-draft-send-message
      'mew-draft-kill
      'mew-send-hook))

(setq mew-fcc "+backup")
(setq my-mew-password "e3d8yrw7")

;;; メールアドレスの @ より前（ユーザ名）を指定する。
(setq mew-user "nrg27943")

;;; メールアドレスの @ 以降を指定する。
(setq mew-mail-domain "nifty.com")

;;; POPの認証方式。APOPならば設定する必要はないが、私のアドレスはユーザー／パスワードで認証するので'passとする。パスワードはその都度入力が必要。
;; (setq mew-pop-auth 'pass)

;;; POPサーバのアカウントを指定する。
(setq mew-pop-user "nrg27943")

;;; 利用するPOPサーバを指定する。
(setq mew-pop-server "pop.nifty.com")

;;; 利用するSMTPサーバ（メールサーバ）を指定する。
(setq mew-smtp-server "smtp.nifty.com")

;;; メールアドレスの代わりに表示される名前を指定する。
(setq mew-name "Tadashi Inoue") 

;; パスワードをメモリに保持する（mewの起動中20分間有効）
(setq mew-use-cached-passwd t)
;; パスワードを暗号化してファイルに保存する（GnuPGのインストールが必要）
;; (setq mew-use-master-passwd t)

;; ウィンドウの分割時の移動設定
(windmove-default-keybindings)
(setq qindmove-wrap-around t)

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
	       (:base "html"
		      :path "~/local/html/Private"
		      :style-sheet "core.css")))
(add-to-list 'muse-project-alist
	     '("Default"
	       ("~/local/Wiki/Public" :default "index")
	       (:base "html" 
		      :path "~/local/html/Public"
		      :style-sheet "core.css"
		      :author "Tadashi Inoue"
;; 		      :base-url "http://localhost/~tadashi/"
		      )))
(add-to-list 'muse-project-alist
	     '("Default"
	       ("~/local/Wiki/PublicOld" :default "index")
	       (:base "html" 
		      :path "~/local/html/Public_old")))
(setq muse-html-style-sheet
;;       "<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"all\" href=\"core.css\">")
      "<link rel=\"stylesheet\" type=\"text/css\" charset=\"utf-8\" media=\"all\" href=\"another.css\">")
(defcustom muse-footer-date-format "%Y-%m-%d %H:%M:%S"
  "Format of current date for `muse-html-footer'.
This string must be a valid argument to `format-time-string'."
  :type 'string
  :group 'muse-publish)

(defun open-my-wiki ()
  (interactive)
  (find-file "~/local/Wiki/Private/index.muse"))
(define-key ctl-x-map "w" 'open-my-wiki)

;;; ヘッダ
(setq muse-html-header
"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<html>
  <head>
    <title>
    <lisp> (concat (muse-publishing-directive \"title\")) </lisp>
    </title>
    <meta name=\"generator\" content=\"EmacsMuse\">
    <meta http-equiv=\"<lisp>muse-html-meta-http-equiv</lisp>\"
          content=\"<lisp>muse-html-meta-content-type</lisp>\">
    <lisp>muse-html-style-sheet</lisp>
  </head>
  <body>
    <!-- header -->
    <div id=\"header\">
    <a href=\"hoge\">作業備忘録まとめWiki</a>
    </div>

    <!-- ナビゲーションとか置くならここに記述 -->
    <!-- main contents -->
    <div id=\"content\">

    <div id=\"menu\">
    <lisp>(muse-html-insert-contents 1)</lisp>
    </div>

    <div id=\"main\">
    <h1>
    <lisp>
    (concat (muse-publishing-directive \"title\")
            (let ((author (muse-publishing-directive \"author\")))
            (if (not (string= author (user-full-name)))
                (concat \" (by \" author \")\"))))
    </lisp>
    </h1>

    <!-- Page published by Emacs Muse begins here -->
")
;;; footer
(setq muse-html-footer
"
<!-- Page published by Emacs Muse ends here -->
  </div>
  </div>
  <div id=\"footer\">
  <!-- 適当に(連絡先とか最終更新日とか) -->
  </div>
  </body>
</html>
")

;; (setq muse-html-footer
;;   "
;;     <!-- Page published by Emacs Muse ends here -->
;;     <div class=\"navfoot\">
;;       <hr />
;;       <table width=\"100%\" border=\"0\" summary=\"Footer navigation\">
;;         <col width=\"33%\" /><col width=\"34%\" /><col width=\"33%\" />
;;         <tr>
;;           <td align=\"left\">
;;             <lisp>
;;               (concat
;;                 \"<span><em><a href=\\\"mailto:kenkiti@gmail.com\\\">Tadashi Inoue</a></em></span><br>\"
;;                 (if (muse-current-file)
;;                   (concat
;;                    \"<span class=\\\"footdate\\\">Updated: \"
;;                    (format-time-string muse-footer-date-format
;;                     (nth 5 (file-attributes (muse-current-file))))
;;                    \"</span>\")))
;;             </lisp>
;;           </td>
;;           <td align=\"center\">
;;             <span class=\"foothome\">
;;             </span>
;;           </td>
;;           <td align=\"right\">
;;             <lisp>
;;                 (if
;;                   (string-match
;;                      (car (or muse-current-project (muse-project-of-file)))
;;                      \"Default\")
;;                   \"<a href=\\\"../index.html\\\">Home</a>\"
;;                   (concat
;;                    \"<a href=\\\"../index.html\\\">Home</a> / <a href=\\\"index.html\\\">\"
;;                    (car (or muse-current-project (muse-project-of-file)))
;;                    \"Home</a>\"))
;;             </lisp>
;;           </td>
;;         </tr>
;;       </table>
;;     </div>
;;   </body>
;; </html>\n")

;;-----------------------------------------------------------------
;; howm
;;-----------------------------------------------------------------
(setq howm-menu-lang 'ja)
(setq howm-directory "~/Dropbox/Document/howm/")
(global-set-key "\C-c,," 'howm-menu)
(mapc
 (lambda (f)
   (autoload f
     "howm" "Hitori Otegaru Wiki Modoki" t))
 '(howm-menu howm-list-all howm-list-recent
             howm-list-grep howm-create
             howm-keyword-to-kill-ring))
;; リンクを TAB で辿る
(eval-after-load "howm-mode"
  '(progn
     (define-key howm-mode-map [tab] 'action-lock-goto-next-link)
     (define-key howm-mode-map [(meta tab)] 'action-lock-goto-previous-link)))
;; 「最近のメモ」一覧時にタイトル表示
(setq howm-list-recent-title t)
;; 全メモ一覧時にタイトル表示
(setq howm-list-all-title t)
;; メニューを 2 時間キャッシュ
(setq howm-menu-expiry-hours 2)

;; howm の時は auto-fill で
;;(add-hook 'howm-mode-on-hook 'auto-fill-mode)

;; RET でファイルを開く際, 一覧バッファを消す
;; C-u RET なら残る
(setq howm-view-summary-persistent nil)

;; メニューの予定表の表示範囲
;; 10 日前から
(setq howm-menu-schedule-days-before 10)
;; 3 日後まで
(setq howm-menu-schedule-days 3)

;; howm のファイル名
;; 1 メモ 1 ファイル (デフォルト)
(setq howm-file-name-format "%Y/%m/%Y-%m-%d-%H%M%S.howm")
;; 検索しないファイルの正規表現
(setq
 howm-excluded-file-regexp
 "/\\.#\\|[~#]$\\|\\.bak$\\|/CVS/\\|\\.doc$\\|\\.pdf$\\|\\.ppt$\\|\\.xls$")

;; いちいち消すのも面倒なので
;; 内容が 0 ならファイルごと削除する
(if (not (memq 'delete-file-if-no-contents after-save-hook))
    (setq after-save-hook
          (cons 'delete-file-if-no-contents after-save-hook)))
(defun delete-file-if-no-contents ()
  (when (and
         (buffer-file-name (current-buffer))
         (string-match "\\.howm" (buffer-file-name (current-buffer)))
         (= (point-min) (point-max)))
    (delete-file
     (buffer-file-name (current-buffer)))))

;; http://howm.sourceforge.jp/cgi-bin/hiki/hiki.cgi?SaveAndKillBuffer
;; C-cC-c で保存してバッファをキルする
(defun my-save-and-kill-buffer ()
  (interactive)
  (when (and
         (buffer-file-name)
         (string-match "\\.howm"
                       (buffer-file-name)))
    (save-buffer)
    (kill-buffer nil)))
(eval-after-load "howm"
  '(progn
     (define-key howm-mode-map
       "\C-c\C-c" 'my-save-and-kill-buffer)))

;;-----------------------------------------------------------------
;;
;; eshell
;;
;; From: http://www.emacswiki.org/cgi-bin/wiki.pl/EshellEnhancedLS
;;-----------------------------------------------------------------
(eval-after-load "em-ls"
  '(progn
     ;; (defun ted-eshell-ls-find-file-at-point (point)
     ;;          "RET on Eshell's `ls' output to open files."
     ;;          (interactive "d")
     ;;          (find-file (buffer-substring-no-properties
     ;;                      (previous-single-property-change point 'help-echo)
     ;;                      (next-single-property-change point 'help-echo))))
     (defun pat-eshell-ls-find-file-at-mouse-click (event)
       "Middle click on Eshell's `ls' output to open files.
 From Patrick Anderson via the wiki."
       (interactive "e")
       (ted-eshell-ls-find-file-at-point (posn-point (event-end event))))
     (defun ted-eshell-ls-find-file ()
       (interactive)
       (let ((fname (buffer-substring-no-properties
                     (previous-single-property-change (point) 'help-echo)
                     (next-single-property-change (point) 'help-echo))))
         ;; Remove any leading whitespace, including newline that might
         ;; be fetched by buffer-substring-no-properties
         (setq fname (replace-regexp-in-string "^[ \t\n]*" "" fname))
         ;; Same for trailing whitespace and newline
         (setq fname (replace-regexp-in-string "[ \t\n]*$" "" fname))
         (cond
          ((equal "" fname)
           (message "No file name found at point"))
          (fname
           (find-file fname)))))
     (let ((map (make-sparse-keymap)))
       ;;          (define-key map (kbd "RET")      'ted-eshell-ls-find-file-at-point)
       ;;          (define-key map (kbd "<return>") 'ted-eshell-ls-find-file-at-point)
       (define-key map (kbd "RET")      'ted-eshell-ls-find-file)
       (define-key map (kbd "<return>") 'ted-eshell-ls-find-file)
       (define-key map (kbd "<mouse-2>") 'pat-eshell-ls-find-file-at-mouse-click)
       (defvar ted-eshell-ls-keymap map))
     (defadvice eshell-ls-decorated-name (after ted-electrify-ls activate)
       "Eshell's `ls' now lets you click or RET on file names to open them."
       (add-text-properties 0 (length ad-return-value)
                            (list 'help-echo "RET, mouse-2: visit this file"
                                  'mouse-face 'highlight
                                  'keymap ted-eshell-ls-keymap)
                            ad-return-value)
       ad-return-value)))

;; ZwaX : http://www.emacswiki.org/cgi-bin/wiki/EshellScrolling
(custom-set-variables
 '(eshell-output-filter-functions (quote (eshell-handle-control-codes 
					  eshell-watch-for-password-prompt eshell-postoutput-scroll-to-bottom)))
 '(eshell-scroll-show-maximum-output t)
 '(eshell-scroll-to-bottom-on-output nil))
