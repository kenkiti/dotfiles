;;;;;;;;;;�������� Meadow��;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Windows������ǥե�����򳫤�
(load "gnuserv")
(gnuserv-start)
(setq gnuserv-frame (selected-frame))

;;ime �� ON/OFF �ǥ�������ο����Ѥ���
(add-hook 'mw32-ime-on-hook
          (function (lambda () (set-cursor-color "Blue"))))
(add-hook 'mw32-ime-off-hook
          (function (lambda () (set-cursor-color "Black"))))

;;; IME������
(mw32-ime-initialize)
(setq default-input-method "MW32-IME")
(setq-default mw32-ime-mode-line-state-indicator "[--]")
(setq mw32-ime-mode-line-state-indicator-list '("[--]" "[��]" "[--]"))
;;(add-hook 'mw32-ime-on-hook
;;        (function (lambda () (set-cursor-height 2))))
;;(add-hook 'mw32-ime-off-hook
;;        (function (lambda () (set-cursor-height 4))))

;;; �������������
;; (set-cursor-type 'box)            ; Meadow-1.10�ߴ� (SKK���ǿ����Ѥ�����)
;; (set-cursor-type 'hairline-caret) ; ���������å�

;;; �ޥ������������ä�����
(setq w32-hide-mouse-on-key t)
(setq w32-hide-mouse-timeout 5000)

;;; TrueType �ե��������
(let ((make-spec 
       (function 
	(lambda (size charset fontname &optional windows-charset)
	  (setq size (- size))
	  (if (not windows-charset)
	      (setq windows-charset 
		    (cadr (assq charset mw32-charset-windows-font-info-alist))))
	  `(((:char-spec ,charset :height any)
	     strict
	     (w32-logfont ,fontname 0 ,size 400 0 nil nil nil ,windows-charset 1 3 0))
	    ((:char-spec ,charset :height any :weight bold)
	     strict
	     (w32-logfont ,fontname 0 ,size 700 0 nil nil nil ,windows-charset 1 3 0)
	     ((spacing . -1)))
	    ((:char-spec ,charset :height any :slant italic)
	     strict
	     (w32-logfont ,fontname 0 ,size 400 0   t nil nil ,windows-charset 1 3 0))
	    ((:char-spec ,charset :height any :weight bold :slant italic)
	     strict
	     (w32-logfont ,fontname 0 ,size 700 0   t nil nil ,windows-charset 1 3 0)
	     ((spacing . -1)))))))
       (make-spec-list
	(function
	 (lambda (size params-list)
	   (list (cons 'spec 
		       (apply 'append 
			      (mapcar (lambda (params)
					(apply make-spec (cons size params)))
				      params-list))))
	   )))
       (define-fontset 
	 (function
	  (lambda (fontname size fontset-list)
	    (let ((spec (funcall make-spec-list size fontset-list)))
	      (if (w32-list-fonts fontname)
		  (w32-change-font fontname spec)
		(w32-add-font fontname spec)
		)))))
       (meiryo-fontset-list
	'(
	  (ascii "ARISAKA-����")
	  (katakana-jisx0201 "�ᥤ�ꥪ")
	  (japanese-jisx0208 "�ᥤ�ꥪ")
	  ))
       (arisaka-fontset-list
	'(
	  (ascii "ARISAKA-����")
	  (katakana-jisx0201 "ARISAKA-����")
	  (japanese-jisx0208 "ARISAKA-����")
	  ))
       )
  (funcall define-fontset "Meiryo 10" 10 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 12" 12 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 14" 14 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 16" 16 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 18" 18 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 20" 20 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 22" 22 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 24" 24 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 36" 36 meiryo-fontset-list)
  (funcall define-fontset "Meiryo 48" 48 meiryo-fontset-list)

  (funcall define-fontset "Arisaka 10" 10 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 12" 12 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 14" 14 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 16" 16 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 18" 18 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 20" 20 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 22" 22 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 24" 24 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 36" 36 arisaka-fontset-list)
  (funcall define-fontset "Arisaka 48" 48 arisaka-fontset-list)
  )

;:; ����ե졼�������
(setq default-frame-alist
      (append (list '(foreground-color . "LemonChiffon")
                    '(background-color . "black")
                    '(border-color . "black")
                    '(mouse-color . "white")
                    '(cursor-color . "black")

                    '(font . "Meiryo 12")
                    '(ime-font . (w32-logfont "Meiryo"
                                              0 16 400 0 nil nil nil
                                              128 1 3 49)) ; TrueType �Τ�
		    '(alpha . (85 80))

;;                  '(font . "MS Gothic 14")
;;                  '(ime-font . (w32-logfont "�ͣ� �����å�"
;;                                            0 14 400 0 nil nil nil
;;                                            128 1 3 49)) ; TrueType �Τ�
                    ) default-frame-alist))

;;; shell ������

;;; Cygwin �� bash ��Ȥ����
;;(setq explicit-shell-file-name "bash")
(setq explicit-shell-file-name "tcsh")
(setq shell-file-name "tcsh")
(setq shell-command-switch "-c") 
(setq shell-file-name-chars "~/A-Za-z0-9_^$!#%&{}@`'.,:()-")
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
          "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


;;; argument-editing ������
(require 'mw32script)
(mw32script-init)

;; ;;; browse-url ������
;; (global-set-key [S-mouse-2] 'browse-url-at-mouse)


;;; ����������
;; ��������� M-x print-buffer RET �ʤɤǤΰ������Ǥ���褦�ˤʤ�ޤ�
;;
;;  notepad ��Ϳ����ѥ�᡼���η���������
(define-process-argument-editing "notepad"
  (lambda (x) (general-process-argument-editing-function x nil t)))

 (defun w32-print-region (start end
                                &optional lpr-prog delete-text buf display
                                &rest rest)
   (interactive)
   (let ((tmpfile (convert-standard-filename (buffer-name)))
         (w32-start-process-show-window t)
         ;; �⤷��dos �뤬�����Ƥ���ʿͤϾ嵭�� `t' �� `nil' �ˤ��ޤ�
         ;; ��������`nil' �ˤ���� Meadow ���Ǥޤ�Ķ��⤢�뤫�⤷��ޤ���
         (coding-system-for-write w32-system-coding-system))
     (while (string-match "[/\\]" tmpfile)
       (setq tmpfile (replace-match "_" t nil tmpfile)))
     (setq tmpfile (expand-file-name (concat "_" tmpfile "_")
                                     temporary-file-directory))
     (write-region start end tmpfile nil 'nomsg)
     (call-process "notepad" nil nil nil "/p" tmpfile)
     (and (file-readable-p tmpfile) (file-writable-p tmpfile)
            (delete-file tmpfile))))

(setq print-region-function 'w32-print-region)


;;; Meadow �� install ���Ƥ��� application

;;; emacs wiki
(require 'emacs-wiki)
(global-set-key [f5] #'emacs-wiki-find-file)
(setq emacs-wiki-projects
      '(
	("public" . (
	 (emacs-wiki-directories . ("~/Wiki/public"))
         (emacs-wiki-publishing-directory . "~/html/public_html")
         (emacs-wiki-default-page . "index")
         (emacs-wiki-index-page . "WebIndex")
         ))
;;         ("private" . (
;;          (emacs-wiki-directories . ("~/Wiki/private"))
;;          (emacs-wiki-publishing-directory . "~/html/private_html")
;;          (emacs-wiki-default-page . "index")
;;          (emacs-wiki-index-page . "WebIndex")
;;          ))
        ))
(setq emacs-wiki-directories  '("~/Wiki/")
      emacs-wiki-publishing-directory "~/html/private_html/"
      emacs-wiki-maintainer  "kenkiti_at_gmail.com"
      emacs-wiki-inline-images t
      emacs-wiki-meta-content-coding "EUC-JP"
      emacs-wiki-charset-default "EUC-JP"
      emacs-wiki-style-sheet "<link rel=\"stylesheet\" type=\"text/css\" href=\"core.css\">"
      emacs-wiki-footer-date-format "%Y-%m-%d %H:%M:%S"
      )

;;; snippet
(require 'snippet)
(add-hook 'emacs-wiki-mode-hook
	  '(lambda ()
	     (setq-default abbrev-mode t) ;; abbrev-mode ��on
	     (snippet-with-abbrev-table 'local-abbrev-table 
					("ti" . "#title")
					("ex" . "<example>\n$${contents}\n</example>")
					("ve" . "<verse>$${contents}</verse>")
					("nw" . "<nowiki>$${contents}</nowiki>")
					("cn" . "<contents depth=\"$${depth}\">")
					("np" . "<nop>")
	     ))
)
(add-hook 'shell-mode-hook 'pcomplete-shell-setup)
;; sample abbrev talbe
;; (snippet-with-abbrev-table 'local-abbrev-table ;; �⡼�ɻ���
;;   ("hthref" .  "<a href=\"\"></a>") 
;;   ("hthref" .  "<a href=\"$${url}\">$${title}</a>") ;; ���ǻ��ꤢ��)
;;   ("htdiv3" . "<div class=\"section\">\n$>$><h3>$${title}</h3>\n$><p>$${body}</p>\n$.</div>$>")  
;; )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
