;; emacs kicker --- kick start emacs setup

;; disable loading of "default.el" at startup
(setq inhibit-default-init t)

;; enable visual feedback on selections
(setq transient-mark-mode t)

;; always end a file with a newline
(setq require-final-newline 'query)

;; Line by line scrolling
;; This makes the buffer scroll by only a single line when the up or
;; down cursor keys push the cursor (tool-bar-mode) outside the
;; buffer. The standard emacs behaviour is to reposition the cursor in
;; the center of the screen, but this can make the scrolling confusing
(setq scroll-step 1)

;; enable deletion of selected text
(delete-selection-mode t)
(transient-mark-mode t)

(require 'cl)                           ; common lisp goodies, loop

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

;; now either el-get is `require'd already, or has been `load'ed by the
;; el-get installer

;; set local recipes
(setq
 el-get-sources
 '((:name buffer-move                   ; have to add your own keys
          :after (progn
                   (global-set-key (kbd "<C-S-up>")     'buf-move-up)
                   (global-set-key (kbd "<C-S-down>")   'buf-move-down)
                   (global-set-key (kbd "<C-S-left>")   'buf-move-left)
                   (global-set-key (kbd "<C-S-right>")  'buf-move-right)))))

;;   (:name smex                          ; a better (ido like) M-x
;;          :after (progn
;;                   (setq smex-save-file "~/.emacs.d/.smex-items")
;;                   (global-set-key (kbd "M-x") 'smex)
;;                   (global-set-key (kbd "M-X") 'smex-major-mode-commands)))

;;   (:name magit                               ; git meets emacs and a binding
;;        :after (progn
;;                 (global-set-key (kbd "C-x C-z") 'magit-status)))

;;   (:name goto-last-change            ; move pointer back to last change
;;        :after (progn
;;                 ;; when using AZERTY keyboard, consider C-x C-_
;;                 (global-set-key (kbd "C-x C-/") 'goto-last-change)))))

;; now set our own packages
(setq
 my:el-get-packages
 '(el-get                               ; el-get is self-hosting
   cmake-mode                           ; synatx highlighting for CMake files
   escreen                              ; screen for emacs, C-\ C-h
   switch-window                        ; takes over C-x o
   auto-complete                        ; complete as you type with overlays
   yasnippet                            ; powerful snippet mode
   git-modes                            ; git modes
   ido-vertical-mode                    ; ido vertical mode
   ido-ubiquitous                       ; ido everywhere
   projectile                           ; project wide interaction library
   color-theme-solarized))

;; append the non standard one to the list above
(setq my:el-get-packages
      (append my:el-get-packages
               (mapcar 'el-get-source-name el-get-sources)))

;; install the new packages and init already installed packages
(el-get 'sync my:el-get-packages)

;; enable the color-theme-solarized
(load-theme 'solarized t)

;; on to the visual settings
(setq inhibit-splash-screen t)          ; no splash screen
(line-number-mode 1)                    ; have line numbers and
(column-number-mode 1)                  ; column numbers in the mode line
(global-hl-line-mode)                 ; highlight current line
(global-linum-mode 1)                   ; add line numbers on the left
(menu-bar-mode -1)                      ; no menu bar at the top

;; when mwheel present enable mouse-wheel-mode
(when (require 'mwheel nil 'noerror)
  (mouse-wheel-mode t))                 ; support wheel mouse scrolling

(when (display-graphic-p)
  (scroll-bar-mode -1)                  ; no scroll bars
  (tool-bar-mode   -1))                 ; no tool bar with icons

(unless (string-match "apple-darwin" system-configuration)
  ;; on mac, there's always a menu bar drown, don't have it empty
  (menu-bar-mode -1))

;; avoid compiz manager rendering bugs
(add-to-list 'default-frame-alist '(alpha . 100))

;; copy/paste with C-c and C-v and C-x, check out C-RET too
(cua-mode)

;; under mac, have Command as Meta and keep Option for localized input
(when (string-match "apple-darwin" system-configuration)
  (setq mac-allow-anti-aliasing t)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

;; navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its
;; content to reflect what's on-disk.
(global-auto-revert-mode 1)

;; M-x shell is a nice shell interface to use, let's make it colorful.  If
;; you need a terminal emulator rather than just a shell, consider M-x term
;; instead.
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; If you do use M-x term, you will notice there's line mode that acts like
;; emacs buffers, and there's the default char mode that will send your
;; input char-by-char, so that curses application see each of your key
;; strokes.
;;
;; The default way to toggle between them is C-c C-j and C-c C-k, let's
;; better use just one key to do the same.
(require 'term)
(define-key term-raw-map  (kbd "C-'") 'term-line-mode)
(define-key term-mode-map (kbd "C-'") 'term-char-mode)

;; Have C-y act as usual in term-mode, to avoid C-' C-y C-'
;; Well the real default would be C-c C-j C-y C-c C-k.
(define-key term-raw-map  (kbd "C-y") 'term-paste)

;; use ido for minibuffer completion
(require 'ido)
(ido-mode 1)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-show-dot-for-dired t)
(setq ido-default-buffer-method 'selected-window)

;; default key to switch buffer is C-x b, but that's not easy enough
;; when you do that, to kill emacs either close its frame from the window
;; manager or do M-x kill-emacs.  Don't need a nice shortcut for a once a
;; week (or day) action.
;;(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
;;(global-set-key (kbd "C-x C-c") 'ido-switch-buffer)
(global-set-key (kbd "C-x B") 'ibuffer)

;; have vertical ido completion lists
(setq ido-decorations
      '("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"))

;; Vertical completion menu
(require 'ido-vertical-mode)
(ido-vertical-mode 1)

;; ido support everywhere
(require 'ido-ubiquitous)
(ido-ubiquitous-mode 1)

;; C-x C-j opens dired with the cursor right on the file you're editing
(require 'dired-x)

;; full screen
(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
                     (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)

;; enable projectile and caching
(projectile-global-mode)
(setq projectile-enable-caching t)

;; Enable formatting using Astyle in emacs
(defun astyle-this-buffer (pmin pmax)
  (interactive "r")
  (shell-command-on-region pmin pmax "astyle"
                         (current-buffer) t
                         (get-buffer-create "*Astyle Errors*") t))

;; save the files that are opened for next time in the same directory
(setq my-path default-directory)
(if (file-exists-p (concat my-path ".emacs.desktop"))
    (if (y-or-n-p "Read .emacs.desktop and add hook?")
        (progn
          (desktop-read my-path)
          (add-hook 'kill-emacs-hook
                    `(lambda ()
                       (desktop-save ,my-path t))))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(frame-background-mode (quote dark)))


