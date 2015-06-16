;;-----------------------------------------------------------------
;; cc-mode
;;-----------------------------------------------------------------
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "gnu")
             ;; Change indent
             (setq c-basic-offset 4)
             ))


;; -----------------------------------------------------------------
;; for mode-compile
;; -----------------------------------------------------------------
(autoload 'mode-compile "mode-compile"
  "Command to compile current buffer file dependently of the major mode" t)
(global-set-key "\C-c\C-c" 'mode-compile)
(autoload 'mode-compile-kill "mode-compile"
  "Command to kill a compilation launched by `mode-compile'" t)
(global-set-key "\C-c\C-k" 'mode-compile-kill)

(defconst cc-default-compiler
  "gcc"
  "*Default C compiler to use when everything else fails")

(defvar cc-default-compiler-options
  "-g -O2 "
  "*Default options to give to the C compiler")

(setq mode-compile-always-save-buffer-p t)
(setq mode-compile-never-edit-command-p t)
(setq mode-compile-expert-p t)
(setq mode-compile-reading-time 0)

;; edit mode-copmpile.el to not check argument.
;; ----- here -----
;; (defun mc--shell-compile (shell dbgflags &optional errors-regexp-alist)
;;   ;; Run SHELL with debug flags DBGFLAGS on current-buffer
;;   (let* ((shcmd   (or (mc--which shell)
;;                       (error "Compilation abort: command %s not found" shell)))
;;          (shfile  (or (buffer-file-name) 
;;                       (error "Compilation abort: Buffer %s has no filename"
;;                              (buffer-name))))
;;          (run-cmd (concat shcmd " " dbgflags " " shfile " "))) ;;;カッコを足すこと
;; ;;                          (setq mc--shell-args 
;; ;;                                 (read-string (if mode-compile-expert-p
;; ;;                                                  "Argv: "
;; ;;                                                (format "Arguments to %s %s script: "
;; ;;                                                        shfile shell))
;; ;;                                              mc--shell-args)))))
;;     ;; Modify compilation-error-regexp-alist if needed
;;     (if errors-regexp-alist
;;         (progn
;;           ;; Set compilation-error-regexp-alist from compile
;;           (or (listp errors-regexp-alist)
;;               (error "Compilation abort: In mc--shell-compile errors-regexp-alist not a list."))
;;           ;; Add new regexp alist to compilation-error-regexp-alist
;;           (mapcar '(lambda(x)
;;                      (if (mc--member x compilation-error-regexp-alist) nil
;;                        (setq compilation-error-regexp-alist 
;;                              (append (list x)
;;                                      compilation-error-regexp-alist))))
;;                   errors-regexp-alist)))
;;     ;; Run compile with run-cmd
;;     (mc--compile run-cmd)))
;; ----- end -----

