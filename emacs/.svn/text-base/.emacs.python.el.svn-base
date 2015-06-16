;;-----------------------------------------------------------------
;; python-mode
;;-----------------------------------------------------------------
(setq auto-mode-alist
;;       (cons '("\\.py$" . python-mode) auto-mode-alist))
      (cons '("\\.(py|pyw)$" . python-mode) auto-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

(defun make-python-scratch-buffer ()
  (with-current-buffer (get-buffer-create "*python scratch*")
    (python-mode)
    (current-buffer)))
(defun python-scratch ()
  (interactive)
  (pop-to-buffer (make-python-scratch-buffer)))

;; ;;-----------------------------------------------------------------
;; ;; haskell-mode
;; ;;-----------------------------------------------------------------
;; (load "/opt/local/share/emacs/site-lisp/haskell-mode-2.3/haskell-site-file")
;; (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;; (add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;; (add-hook 'haskell-mode-hook 'font-lock-mode)
;; (add-hook 'haskell-mode-hook 'imenu-add-menubar-index)

