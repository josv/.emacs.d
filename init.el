(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(case-fold-search t)
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(global-font-lock-mode t nil (font-lock))
 '(grep-command "grep -nH -e")
 '(grep-find-command "find -L . -type f -print0 | xargs -0 -e grep -nH -e")
 '(grep-find-template "find -L . <X> -type f <F> -print0 | xargs -0 -e grep <C> -nH -e <R>")
 '(grep-template "grep <C> -nH -e <R> <F>")
 '(hippie-expand-try-functions-list (quote (try-complete-file-name-partially try-complete-file-name try-expand-all-abbrevs try-expand-list try-expand-dabbrev try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill try-complete-lisp-symbol-partially try-complete-lisp-symbol try-expand-line)))
 '(svn-status-verbose nil))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(whitespace-tab ((((class color) (background light)) (:background "LightBlue1" :foreground "black")))))

;; set colors
(set-background-color "black")
(set-foreground-color "white")

(add-to-list 'load-path "~/.emacs.d/site-lisp/misc")

;; enable functions
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; move my shell buffer to the dir the file is in
;; cough hairball if not visiting file
;; make cli if don't exist
(defun sw-move-cli-here ()
  "Move the cli buffer to the directory where the currently visited file is located,
 or prompt user if the buffer is not visiting the file ."
  (interactive)
  (if buffer-file-name
      (let* (
             (file-dir (file-name-directory buffer-file-name))
             (cli-buffer-name (format "cli-%s" file-dir))
             (cli-buffer (get-buffer cli-buffer-name))
             )
        (if (bufferp cli-buffer)
            (switch-to-buffer-other-window cli-buffer)
          ;; else make the shell buffer called "cli"
            (shell)
            (switch-to-buffer-other-window "*shell*")
            (rename-buffer cli-buffer-name)
          )
        ;; make sure we're at point-max, insert and send input
        (goto-char (point-max))
        (insert (format "cd %s" file-dir))
        (comint-send-input)
        )
    ;; else buffer-file-name was nil, cough up the hairball
    (let* (
           (def-dir default-directory)
           (prompt-string
            (format "This buffer is not visiting a file. Move cli to %s? " def-dir))
           )
      (if (yes-or-no-p prompt-string)
          ;; cheap job for now: assumes cli exists. need to refactor whole thing now.
          (let* (
                 (cli-buffer-name (format "cli-%s" def-dir))
                 (cli-buffer (get-buffer cli-buffer-name))
                 )
            (if (bufferp cli-buffer)
                (switch-to-buffer-other-window cli-buffer)
              ;; else make the shell buffer called "cli"
              (shell)
              (switch-to-buffer-other-window "*shell*")
              (rename-buffer cli-buffer-name)
              )
            ;; make sure we're at point-max, insert and send input
            (goto-char (point-max))
            (insert (format "cd %s" def-dir))
            (comint-send-input)
            )
        )
      )
    )
  )

;;
(defun swap-windows ()
 "If you have 2 windows, it swaps them." (interactive) (cond ((not (= (count-windows) 2)) (message "You need exactly 2 windows to do this."))
 (t
 (let* ((w1 (first (window-list)))
	 (w2 (second (window-list)))
	 (b1 (window-buffer w1))
	 (b2 (window-buffer w2))
	 (s1 (window-start w1))
	 (s2 (window-start w2)))
 (set-window-buffer w1 b2)
 (set-window-buffer w2 b1)
 (set-window-start w1 s2)
 (set-window-start w2 s1)))))

(if (not (fboundp 'switch-to-other-buffer))
;; Code stolen Xemacs' files.el
(defun switch-to-other-buffer (arg)
  "Switch to the previous buffer.  With a numeric arg, n, switch to the nth
most recent buffer.  With an arg of 0, buries the current buffer at the
bottom of the buffer stack."
  (interactive "p")
  (if (eq arg 0)
      (bury-buffer (current-buffer)))
  (switch-to-buffer
   (if (<= arg 1) (other-buffer (current-buffer))
     (nth (1+ arg) (buffer-list)))))
)

(if (not (fboundp 'next-buffer))
    (defun next-buffer ()
  "Switch to the next buffer in cyclic order."
  (interactive)
  (switch-to-other-buffer 0)))

(if (not (fboundp 'previous-buffer))
     (defun previous-buffer ()
  "Switch to the previous buffer in cyclic order."
  (interactive)
  (while (string-match "\\` "
                       (buffer-name (switch-to-other-buffer
                                     (- (length (buffer-list)) 2)))))))

(setq grep-find-ignored-directories '(".svn"))

(defun back-to-indentation-or-beginning ()
  (interactive)
  (if (= (point) (save-excursion (back-to-indentation) (point)))
      (beginning-of-line)
    (back-to-indentation)))

;;recentf
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-saved-items 500)
(setq recentf-max-menu-items 60)
(setq recentf-save-file (expand-file-name "recentf" user-emacs-directory))

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
            ("Kernel"
             (filename . "linux-2.6"))
            ("User Space"
             (filename . "user"))
            ("Programming - C" ;; prog stuff not already in MyProjectX
             (mode . c-mode))
            ("Programming - Perl" ;; prog stuff not already in MyProjectX
             (mode . perl-mode))
            ("Programming - Python" ;; prog stuff not already in MyProjectX
             (mode . python-mode))
            ("Programming - Ruby" ;; prog stuff not already in MyProjectX
             (mode . ruby-mode))
            ("Programming - Emacs-Lisp" ;; prog stuff not already in MyProjectX
             (mode . emacs-lisp-mode))
            ("YAML" ;; yaml
               (mode . yaml-mode))
            ("Expect" ;; expect
               (filename . ".exp"))
            ("Configuration" ;; conf
             (or
               (mode . conf-mode)
               (filename . ".conf")
               ))
            ("reStructured text" ;; restructured text
               (mode . rst-mode))
            ("ERC"   (mode . erc-mode))))))

(add-hook 'ibuffer-mode-hook
  (lambda ()
    (ibuffer-switch-to-saved-filter-groups "default")))

(global-set-key (kbd "C-x C-b") 'ibuffer)

;;scrollbar
(set-scroll-bar-mode `right)

;; disable toolbar and menubar
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; keybindings
(global-set-key (kbd "C-SPC") 'hippie-expand)
(global-set-key (kbd "S-SPC") 'set-mark-command)
(global-set-key "\M-n" 'etags-select-find-tag-at-point)
(global-set-key "\M-p" 'pop-tag-mark)
(global-set-key [f1] 'help-command)
(global-set-key [f5] 'split-window-horizontally)
(global-set-key [S-f5] 'split-window-vertically)
(global-set-key [M-f5] 'delete-window)
(global-set-key [C-f5] 'swap-windows)
(global-set-key [f6] 'gud-step)
(global-set-key [S-f6] 'gud-watch)
(global-set-key [f7] 'gud-next)
(global-set-key [f8] 'compile)
(global-set-key [S-f8] 'gtags-find-rtag)
(global-set-key [f9] 'sw-move-cli-here)
(global-set-key [(f12)] 'recentf-open-files)
(global-set-key "\C-a" 'back-to-indentation-or-beginning)
(global-set-key "\C-l" 'goto-line)          ;; was: redraw garbled screen
(global-set-key "\C-z" 'undo)               ;; was: suspend-frame
(global-set-key "\C-o" 'ffap-other-window)  ;; was: open-line
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-g" 'find-file-other-window)
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\M-r" 'isearch-backward-regexp)
(global-set-key "\M-s" 'isearch-forward-regexp)
(global-set-key [?\C-x prior] 'previous-error)
(global-set-key [?\C-x next]  'next-error)

(defalias 'qrr 'query-replace-regexp)

(require 'psvn)

(put 'dired-find-alternate-file 'disabled nil)
(require 'dired)
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)

(mouse-wheel-mode t)
(column-number-mode t)
(flyspell-prog-mode)

;; Security Settings
;; Dont echo the password when logging in form the emacs shell
(add-hook 'comint-output-filter-functions
	  'comint-watch-for-password-prompt)

;; Frame title bar formatting to show full path of file
(setq-default
 frame-title-format
 (list '((buffer-file-name " %f" (dired-directory
	 			  dired-directory
				  (revert-buffer-function " %b"
				  ("%b - Dir:  " default-directory)))))))

(setq-default
 icon-title-format
 (list '((buffer-file-name " %f" (dired-directory
                                  dired-directory
                                  (revert-buffer-function " %b"
                                  ("%b - Dir:  " default-directory)))))))


;; Make the % key jump to the matching {}[]() if on another, like VI
(global-set-key "%" 'match-paren)

(defun match-paren (arg)
  "Go to the matching parenthesis if on parenthesis otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))


;; kill current buffer without confirmation
(global-set-key "\C-xk" 'kill-current-buffer)

(defun kill-current-buffer ()
  "Kill the current buffer, without confirmation."
  (interactive)
  (kill-buffer (current-buffer)))

;; Better etags handling
(require 'etags-table)
(setq etags-table-search-up-depth 10)
(require 'etags-select)

;; Use also gnu-global - update with global -u
(require 'gtags)

(require 'repository-root) ; optional: needed for repository-wide search
(add-to-list 'repository-root-matchers repository-root-matcher/git)
(add-to-list 'repository-root-matchers repository-root-matcher/svn)

(load "dired-x")
(load "ffap")

;; save a list of open files in ~/.emacs.desktop
;; save the desktop file automatically if it already exists
(setq desktop-save 'if-exists)
(desktop-save-mode 1)

;; save a bunch of variables to the desktop file
;; for lists specify the len of the maximal saved data also
(setq desktop-globals-to-save
      (append '((extended-command-history . 30)
                (file-name-history        . 100)
                (grep-history             . 30)
                (compile-history          . 30)
                (minibuffer-history       . 50)
                (query-replace-history    . 60)
                (read-expression-history  . 60)
                (regexp-history           . 60)
                (regexp-search-ring       . 20)
                (search-ring              . 20)
                (shell-command-history    . 50)
                tags-file-name
                register-alist)))

;; transparency
;;(set-frame-parameter (selected-frame) 'alpha '(<active> [<inactive>]))
(set-frame-parameter (selected-frame) 'alpha '(90 60))
(add-to-list 'default-frame-alist '(alpha 90 60))

;; change scrollbar behaviour
(setq
  scroll-margin 10
  scroll-conservatively 100000
  scroll-preserve-screen-position 1)

;; unique buffer names (append path)
(require 'uniquify)
(setq
  uniquify-buffer-name-style 'post-forward
  uniquify-separator ":")

;; customize bookmarks settings
(setq
  bookmark-default-file "~/.emacs.d/bookmarks" ;; keep my ~/ clean
  bookmark-save-flag 1)                        ;; autosave each change

;; use <windows> key in combination with arrow keys to move to a visible buffer
(require 'windmove)
(require 'framemove)
(windmove-default-keybindings 'meta)
(setq framemove-hook-into-windmove t)

;; hide/show blocks in c-code
(add-hook 'c-mode-common-hook
  (lambda()
    (local-set-key (kbd "C-c <right>") 'hs-show-block)
    (local-set-key (kbd "C-c <left>")  'hs-hide-block)
    (local-set-key (kbd "C-c <up>")    'hs-hide-all)
    (local-set-key (kbd "C-c <down>")  'hs-show-all)
    (hs-minor-mode t)))

(require 'rect-mark)

(global-set-key (kbd "C-x r C-SPC") 'rm-set-mark)
(global-set-key (kbd "C-w")
  '(lambda(b e) (interactive "r")
     (if rm-mark-active
       (rm-kill-region b e) (kill-region b e))))
(global-set-key (kbd "M-w")
  '(lambda(b e) (interactive "r")
     (if rm-mark-active
       (rm-kill-ring-save b e) (kill-ring-save b e))))
(global-set-key (kbd "C-x C-x")
  '(lambda(&optional p) (interactive "p")
     (if rm-mark-active
       (rm-exchange-point-and-mark p) (exchange-point-and-mark p))))
(put 'scroll-left 'disabled nil)

;; show which function point is in
(load "which-func")
(which-func-mode 1)

(delete (assoc 'which-func-mode mode-line-format) mode-line-format)
(setq which-func-header-line-format
              '(which-func-mode
                ("" which-func-format
                 )))
(defadvice which-func-ff-hook (after header-line activate)
  (when which-func-mode
    (delete (assoc 'which-func-mode mode-line-format) mode-line-format)
    (setq header-line-format which-func-header-line-format)))

;; saves last position of point
(require 'saveplace)                          ;; get the package
(setq save-place-file (expand-file-name "saveplace" user-emacs-directory))
(setq-default save-place t)                   ;; activate it for all buffers

;; guess-style
;;(autoload 'guess-style-set-variable "guess-style" nil t)
;;(autoload 'guess-style-guess-variable "guess-style")
;;(autoload 'guess-style-guess-all "guess-style" nil t)

;;(add-hook 'c-mode-common-hook 'guess-style-guess-all)

;; white space
(require 'whitespace)
(add-hook 'c-mode-common-hook
  (setq show-trailing-whitespace t))

;; linux c coding guidelines
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8))

(setq auto-mode-alist (cons '("linux-2.6.x.*\\.[ch]$" . linux-c-mode) auto-mode-alist))

;; git support
(require 'magit)
(set-face-foreground 'magit-diff-add "green1")
(set-face-foreground 'magit-diff-del "red4")

;; really big files are opened read-only
(defun find-file-check-make-large-file-read-only-hook ()
 "If a file is over a given size, make the buffer read only."
 (when (> (buffer-size) (* 204800 1024))
   (setq buffer-read-only t)
   (buffer-disable-undo)
   (message "Buffer is set to read-only because it is large.  Undo also disabled.")))

(add-hook 'find-file-hooks 'find-file-check-make-large-file-read-only-hook)

;; clean old and unused buffers
(require 'midnight)

;;clean-buffer-list-kill-buffer-names
;;clean-buffer-list-kill-regexps
;;clean-buffer-list-kill-never-buffer-names
;;clean-buffer-list-kill-never-regexps
;;clean-buffer-list-delay-general
;;clean-buffer-list-delay-special

;; find rfc
(require 'get-rfc)
(require 'rfcview)
(put 'rfc 'bounds-of-thing-at-point
         (lambda ()
           (and (thing-at-point-looking-at "[Rr][Ff][Cc][- #]?\\([0-9]+\\)")
                (cons (match-beginning 0) (match-end 0)))))

(autoload 'get-rfc-view-rfc "get-rfc" "Get and view an RFC" t nil)
(autoload 'get-rfc-view-rfc-at-point "get-rfc" "View the RFC at point" t nil)
(autoload 'get-rfc-grep-rfc-index "get-rfc" "Grep rfc-index.txt" t nil)

(setq get-rfc-open-in-new-frame nil)

;; ansi color for shell
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; autopairing
(require 'autopair)
(autopair-global-mode 1)
(setq autopair-autowrap t)

;; highlight FIXME/TODO and similar
(require 'fic-mode)
(add-hook 'c-mode-hook 'turn-on-fic-mode)
(add-hook 'emacs-lisp-mode-hook 'turn-on-fic-mode)

;; css
(require 'css-complete)

;; enable clipboard, see also http://stackoverflow.com/questions/64360/how-to-copy-text-from-emacs-to-another-application-on-linux
(setq x-select-enable-clipboard t)

;; Interactively Do Things
(require 'ido)
(ido-mode t)
(setq ido-enable-prefix nil
      ido-enable-flex-matching t
      ido-case-fold t
      ido-auto-merge-work-directories-length 0
      ido-create-new-buffer 'always
      ido-use-filename-at-point nil
      ido-max-prospects 10)

;; tabs
(setq-default indent-tabs-mode nil)

;; add coffee-mode
(add-to-list 'load-path "~/.emacs.d/site-lisp/coffee-mode")
(require 'coffee-mode)

;; God files are ruby files
(setq auto-mode-alist (cons '("\\.god$" . ruby-mode) auto-mode-alist))

;; add grep-a-lot - manages multiple grep buffers
(require 'grep-a-lot)
(grep-a-lot-setup-keys)

;; generate TAGS file
(setq path-to-ctags "/usr/bin/ctags-exuberant") ;; <- your ctags path here

(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f %s/TAGS -e -R %s" path-to-ctags dir-name (directory-file-name dir-name)))
  )

;; auto update TAGS file (on save)
(require 'ctags-update)
(ctags-update-minor-mode 1)

;; revert without asking
(setq tags-revert-without-query 1)

;; markdown mode
(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.md$" . markdown-mode) auto-mode-alist))

;; move point forward n words and place cursor at the beginning
(defun forward-word-to-beginning (&optional n)
  "Move point forward n words and place cursor at the beginning."
  (interactive "p")
  (let (myword)
    (setq myword
      (if (and transient-mark-mode mark-active)
        (buffer-substring-no-properties (region-beginning) (region-end))
        (thing-at-point 'symbol)))
    (if (not (eq myword nil))
      (forward-word n))
    (forward-word n)
    (backward-word n)))

(global-set-key [C-right] 'forward-word-to-beginning)

;; start emacs server
(server-start)

;; use C-x k iso C-x # to kill buffer and warn emacsclient
(add-hook 'server-switch-hook
          (lambda ()
            (when (current-local-map)
              (use-local-map (copy-keymap (current-local-map))))
            (when server-buffer-clients
              (local-set-key (kbd "C-x k") 'server-edit))))

;; markdown mode
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
   (cons '("\\.md" . markdown-mode) auto-mode-alist))
;; w3m

(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; optional keyboard short-cut
(global-set-key "\C-xm" 'browse-url-at-point)
(setq w3m-default-display-inline-images t)
(setq w3m-use-cookies t)

;; browse-kill-ring (M-y)
(add-to-list 'load-path "~/.emacs.d/site-lisp/browse-kill-ring")
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; yasnippet
(add-to-list 'load-path "~/.emacs.d/site-lisp/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)

;; copy/paste
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
(setq lpr-command "xpp")

;; breadcrumbs
(add-to-list 'load-path "~/.emacs.d/site-lisp/breadcrumb")
(require 'breadcrumb)

(setq bc-bookmark-file (expand-file-name "breadcrumb" user-emacs-directory))

(global-set-key "\C-xj"         'bc-set)            ;; Shift-SPACE for set bookmark
(global-set-key [f2]            'bc-previous)       ;; M-j for jump to previous
(global-set-key [S-f2]          'bc-next)           ;; Shift-M-j for jump to next
;;(global-set-key [(meta up)]     'bc-local-previous) ;; M-up-arrow for local previous
;;(global-set-key [(meta down)]   'bc-local-next)     ;; M-down-arrow for local next
(global-set-key [C-f2]          'bc-goto-current)   ;; C-c j for jump to current bookmark
(global-set-key [C-S-f2]        'bc-list)           ;; C-x M-j for the bookmark menu list

;; ace jump mode major function
(add-to-list 'load-path "~/.emacs.d/site-lisp/ace-jump-mode")
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
;; you can select the key you prefer to
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)

;;indent whole buffer
(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))
(define-key global-map (kbd "C-c n") 'iwb)

;; expand region
(add-to-list 'load-path "~/.emacs.d/site-lisp/expand-region")
(require 'expand-region)
(global-set-key (kbd "C-c m") 'er/expand-region)

;; multiple cursors
(add-to-list 'load-path "~/.emacs.d/site-lisp/multiple-cursors")
(require 'multiple-cursors)

(global-set-key (kbd "C-c e") 'mc/edit-lines)
(global-set-key (kbd "C-c j") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c k") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c l") 'mc/mark-all-like-this-dwim)

;; load project files
;; Functions (load all files in project-dir and one sublevel of project-dir)
(setq projects-dir (expand-file-name "projects" user-emacs-directory))
(dolist (file (directory-files projects-dir t "\\w+"))
  (when (file-regular-p file)
    (when (string= "el" (file-name-extension file))
      (load file)))
  (when (file-directory-p file)
    (dolist (project-file (directory-files file t "\\w+"))
      (when (file-regular-p project-file)
        (when (string= "el" (file-name-extension project-file))
          (load project-file))))))

;; tramp does not like zsh
(eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))
