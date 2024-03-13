;; set colors
(set-background-color "black")
(set-foreground-color "white")
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; global keys
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'help-command)

;; scrollbar
(set-scroll-bar-mode `right)

;; column number
(column-number-mode 1)

;; disable toolbar and menubar
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Make availble package functions
(require 'package)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; add a new package source
(customize-set-variable 'package-archives
                        (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/")))

;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

;; install use-package if not already done
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; only evaluate this when compiling this file
(eval-when-compile
  ; For each package on the list do
  (dolist (package '(use-package diminish bind-key))
    ; Install if not yet installed
    (unless (package-installed-p package)
      (package-install package))
    ; Require package making it available on the rest of the configuration
    (require package)))

;; git support
(use-package magit
  :ensure t
  :bind ("C-c m s" . magit-status))

;; Auto-complete interface
(use-package company
  :ensure t
  :diminish company-mode
  :bind ("M-/" . company-complete)  
  :config
  (global-company-mode))

;; Project management and tools
(use-package projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (setq projectile-completion-system 'ivy)
  (projectile-mode +1)
  :init
  (setq projectile-project-root-files-bottom-up '(".projectile"))
  (add-to-list 'projectile-project-root-files-bottom-up "pubspec.yaml")
  (add-to-list 'projectile-project-root-files-bottom-up "BUILD"))

;; Sidebar navigation with extras
(use-package treemacs
  :ensure t  
  :config
  (treemacs-filewatch-mode t)
  (treemacs-git-mode 'extended)
  (treemacs-follow-mode -1)
  (treemacs-resize-icons 16)
  (add-hook 'treemacs-mode-hook (lambda() (display-line-numbers-mode -1))))

(use-package elixir-mode
  :ensure t
  :init  
  (add-hook 'elixir-mode-hook
            (lambda ()
              (push '(">=" . ?\u2265) prettify-symbols-alist)
              (push '("<=" . ?\u2264) prettify-symbols-alist)
              (push '("!=" . ?\u2260) prettify-symbols-alist)
              (push '("==" . ?\u2A75) prettify-symbols-alist)
              (push '("=~" . ?\u2245) prettify-symbols-alist)
              (push '("<-" . ?\u2190) prettify-symbols-alist)
              (push '("->" . ?\u2192) prettify-symbols-alist)
              (push '("<-" . ?\u2190) prettify-symbols-alist)
              (push '("|>" . ?\u25B7) prettify-symbols-alist))))

;; LSP client interface for Emacs
;; (use-package lsp-mode
;;   :commands lsp
;;   :ensure t
;;   :diminish lsp-mode
;;   :hook
;;   (elixir-mode . lsp)
;;   :init
;;   (add-to-list 'exec-path "~/elixir-ls/release/erl24")
;;   :config
;;   (lsp-register-client
;;    (make-lsp-client :new-connection (lsp-tramp-connection "~/elixir-ls/release/erl24/language_server.sh")
;;                     :major-modes '(elixir-mode)
;;                     :remote? t
;;                     :server-id 'elixir-ls-remote)
;;    )
;; )

(use-package eglot)
;; yasnippet
(use-package yasnippet)
(yas-global-mode 1)

;; ag - silver searcher
;; (use-package ag)
(use-package ag
  :config
  (setq ag-arguments (append ag-arguments '("--ignore" "*~"))))

;; flycheck
(use-package flycheck)

(use-package ace-jump-mode)
(global-set-key (kbd "C-c n") 'ace-jump-mode)
(global-set-key (kbd "C-c b") 'ace-window)
(global-set-key (kbd "C-;") 'other-window)

;; optionally
;; (use-package lsp-ui :commands lsp-ui-mode)
;; (use-package lsp-treemacs :commands lsp-treemacs-errors-list)

; Unifies projectile and treemacs
(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

; Makes treemacs show different colors for committed, staged and modified files
(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

;; Multi-term
(use-package multi-term)

(setq multi-term-program "/usr/bin/zsh")
(set-face-foreground 'term-color-blue "deep sky blue")

(defun last-term-buffer (l)
  "Return most recently used term buffer."
  (when l
    (if (eq 'term-mode (with-current-buffer (car l) major-mode))
        (car l) (last-term-buffer (cdr l)))))

(defun get-term ()
  "Switch to the term buffer last used, or create a new one if
    none exists, or if the current buffer is already a term."
  (interactive)
  (let ((b (last-term-buffer (buffer-list))))
    (if (or (not b) (eq 'term-mode major-mode))
        (multi-term)
      (switch-to-buffer b))))

(defun my-term-switch-line-char ()
  "Switch `term-in-line-mode' and `term-in-char-mode' in `ansi-term'"
  (interactive)
  (cond
   ((term-in-line-mode)
    (term-char-mode)
    (hl-line-mode -1))
   ((term-in-char-mode)
    (term-line-mode)
    (hl-line-mode 1))))

(defun term-send-up () (interactive) (term-send-raw-string "\e[A"))
(defun term-send-down () (interactive) (term-send-raw-string "\e[B"))
(defun term-send-right () (interactive) (term-send-raw-string "\e[C"))
(defun term-send-left () (interactive) (term-send-raw-string "\e[D"))

(add-hook 'term-mode-hook (lambda ()
                             (yas-minor-mode -1)
                             (setq term-buffer-maximum-size 1000)
                             (toggle-truncate-lines 1)
                             (define-key term-raw-map (kbd "C-t") 'my-term-switch-line-char)
                             (define-key term-mode-map (kbd "C-t") 'my-term-switch-line-char)
                             (define-key term-raw-map (kbd "C-c C-z") 'term-stop-subjob)
                             (define-key term-raw-map (kbd "C-r") 'term-send-raw)
			     (define-key term-raw-map (kbd "C-p") 'term-send-up)
			     (define-key term-raw-map (kbd "C-n") 'term-send-down)
			     (define-key term-raw-map (kbd "C-b") 'term-send-left)
			     (define-key term-raw-map (kbd "C-f") 'term-send-right)
			     (define-key term-raw-map (kbd "<up>") 'term-send-up)
			     (define-key term-raw-map (kbd "<down>") 'term-send-down)
			     (define-key term-raw-map (kbd "<right>") 'term-send-right)
			     (define-key term-raw-map (kbd "<left>") 'term-send-left)
	    ))

(global-set-key [f9] 'get-term)

;;ibuffer
(require 'ibuffer)
(setq ibuffer-shrink-to-minimum-size t)
(setq ibuffer-always-show-last-buffer nil)
(setq ibuffer-sorting-mode 'recency)
(setq ibuffer-use-header-line t)

(setq ibuffer-saved-filter-groups
  (quote (("default"
           ("Mail"
            (or  ;; mail-related buffers
             (mode . message-mode)
             (mode . mail-mode)
             ;; etc.; all your mail related modes
             ))
            ("Programming - C" ;; prog stuff not already in MyProjectX
             (mode . c-mode))
            ("Programming - Elixir" ;; prog stuff not already in MyProjectX
             (mode . elixir-mode))
            ("Programming - Python" ;; prog stuff not already in MyProjectX
             (mode . python-mode))
            ("Programming - Ruby" ;; prog stuff not already in MyProjectX
             (mode . ruby-mode))
            ("Programming - Emacs-Lisp" ;; prog stuff not already in MyProjectX
             (mode . emacs-lisp-mode))
            ("Grep" ;; grep buffers
             (or
              (mode . grep-mode)
              (mode . ag-mode)
              ))
            ("YAML" ;; yaml
             (mode . yaml-mode))
            ("Man" ;; man
             (mode . man-mode))
            ))))

(add-hook 'ibuffer-mode-hook
  (lambda ()
    (ibuffer-switch-to-saved-filter-groups "default")))

(global-set-key (kbd "C-x C-b") 'ibuffer)

;; kill current buffer without confirmation
(global-set-key "\C-xk" 'kill-current-buffer)

;; prevent changes in mini-buffer to go into the kill-ring
(defun delete-line (&optional arg)
  "Delete the rest of the current line without affecting the kill ring."
  (interactive "P")
  (delete-region (point) (progn (forward-visible-line (or arg 1)) (point))))

(defun my-minibuffer-setup-hook ()
  (local-set-key (kbd "C-<backspace>") 'delete-backward-char)
  (local-set-key (kbd "C-k") 'delete-line))

(add-hook 'minibuffer-setup-hook 'my-minibuffer-setup-hook)

;; undo
(global-set-key "\C-z" 'undo)

;; query and replace
(defalias 'qrr 'query-replace-regexp)

;; Frame title bar formatting to show full path of file
(setq frame-title-format
  '(((:eval (if (buffer-file-name)
                (abbreviate-file-name (buffer-file-name))
                  "%b")) " [%*]")))

(setq-default
 icon-title-format
 (list '((buffer-file-name " %f" (dired-directory
                                  dired-directory
                                  (revert-buffer-function " %b"
                                  ("%b - Dir:  " default-directory)))))))

;; Hack for markdown-toc
(setq native-comp-deferred-compilation-deny-list '("markdown-toc"))

;; Winum
(use-package winum
  :ensure t
  :config
  (winum-mode))

(define-key winum-keymap (kbd "C-x C-1") 'winum-select-window-1)
(define-key winum-keymap (kbd "C-x C-2") 'winum-select-window-2)
(define-key winum-keymap (kbd "C-x C-3") 'winum-select-window-3)
(define-key winum-keymap (kbd "C-x C-4") 'winum-select-window-4)
(define-key winum-keymap (kbd "C-x C-5") 'winum-select-window-5)
(define-key winum-keymap (kbd "C-x C-6") 'winum-select-window-6)
(define-key winum-keymap (kbd "C-x C-7") 'winum-select-window-7)
(define-key winum-keymap (kbd "C-x C-8") 'winum-select-window-8)
(define-key winum-keymap (kbd "C-x C-9") 'winum-select-window-9)

;; Pop buffer from stack
(defvar my-buffer-stack nil
  "Stack of visited buffers.")

(defun my-push-buffer-stack ()
  "Push the current buffer onto the stack."
  (unless (eq (current-buffer) (car my-buffer-stack)) ; Avoid duplicates
    (push (current-buffer) my-buffer-stack)))

(defun my-pop-buffer-stack ()
  "Pop the buffer stack and switch to the top buffer."
  (interactive)
  (let ((buf (pop my-buffer-stack)))
    (while (and buf (not (buffer-live-p buf)))
      (setq buf (pop my-buffer-stack))) ; Skip over killed buffers
    (if buf
        (switch-to-buffer buf)
      (message "Buffer stack is empty"))))

(add-hook 'buffer-list-update-hook 'my-push-buffer-stack)

(global-set-key (kbd "C-c p") 'my-pop-buffer-stack)

(with-eval-after-load 'winum
  (set-face-attribute 'winum-face nil
                      :weight 'bold
                      :foreground "Red"))

;; save history
(savehist-mode 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(connection-local-criteria-alist
   '(((:application tramp :protocol "flatpak")
      tramp-container-connection-local-default-flatpak-profile)
     ((:application tramp)
      tramp-connection-local-default-system-profile tramp-connection-local-default-shell-profile)))
 '(connection-local-profile-alist
   '((tramp-container-connection-local-default-flatpak-profile
      (tramp-remote-path "/app/bin" tramp-default-remote-path "/bin" "/usr/bin" "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin" "/local/bin" "/local/freeware/bin" "/local/gnu/bin" "/usr/freeware/bin" "/usr/pkg/bin" "/usr/contrib/bin" "/opt/bin" "/opt/sbin" "/opt/local/bin"))
     (tramp-connection-local-darwin-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o" "pid,uid,user,gid,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state=abcde" "-o" "ppid,pgid,sess,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etime,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . tramp-ps-time)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-busybox-ps-profile
      (tramp-process-attributes-ps-args "-o" "pid,user,group,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "stat=abcde" "-o" "ppid,pgid,tty,time,nice,etime,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (user . string)
       (group . string)
       (comm . 52)
       (state . 5)
       (ppid . number)
       (pgrp . number)
       (ttname . string)
       (time . tramp-ps-time)
       (nice . number)
       (etime . tramp-ps-time)
       (args)))
     (tramp-connection-local-bsd-ps-profile
      (tramp-process-attributes-ps-args "-acxww" "-o" "pid,euid,user,egid,egroup,comm=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "-o" "state,ppid,pgid,sid,tty,tpgid,minflt,majflt,time,pri,nice,vsz,rss,etimes,pcpu,pmem,args")
      (tramp-process-attributes-ps-format
       (pid . number)
       (euid . number)
       (user . string)
       (egid . number)
       (group . string)
       (comm . 52)
       (state . string)
       (ppid . number)
       (pgrp . number)
       (sess . number)
       (ttname . string)
       (tpgid . number)
       (minflt . number)
       (majflt . number)
       (time . tramp-ps-time)
       (pri . number)
       (nice . number)
       (vsize . number)
       (rss . number)
       (etime . number)
       (pcpu . number)
       (pmem . number)
       (args)))
     (tramp-connection-local-default-shell-profile
      (shell-file-name . "/bin/sh")
      (shell-command-switch . "-c"))
     (tramp-connection-local-default-system-profile
      (path-separator . ":")
      (null-device . "/dev/null"))))
 '(package-selected-packages
   '(winum markdown-toc eglot php-mode elixir-yasnippets lsp-treemacs ag ace-jump-mode multi-term lsp-ui flycheck yasnippet compat treemacs-magit treemacs-projectile elixir-mode treemacs projectile company diminish use-package)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
