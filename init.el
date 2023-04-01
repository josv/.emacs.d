;; set colors
(set-background-color "black")
(set-foreground-color "white")
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; global keys
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "M-h") 'help-command)

;;scrollbar
(set-scroll-bar-mode `right)

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
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :ensure t
  :diminish lsp-mode
  :hook
  (elixir-mode . lsp-deferred)
  :init
  (add-to-list 'exec-path "~/elixir-ls/release/erl24")
)

;; yasnippet
(use-package yasnippet)

;; ag - silver searcher
(use-package ag)

;; flycheck
(use-package flycheck)

(use-package ace-jump-mode)
(global-set-key (kbd "C-c n") 'ace-jump-mode)

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ag ace-jump-mode multi-term lsp-ui flycheck yasnippet compat treemacs-magit treemacs-projectile lsp-mode elixir-mode treemacs projectile company magit diminish use-package)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
