;; This is loaded by visrc.lua which is generated by home-manager

;; TODO: * Consider binding ^w binds to tmux commands
;;       * Register :terminal to create a terminal split
;;       * Replace vis-open with fzy?
;;       * Should I change pwd to `basename win.file.path`?

;; NOTE: * if acts more like cond
;;       * macros must be in a separate file

(require "vis")

;; Lisp functions

(fn car [list] (. list 1))

;; Side-effects suck
(fn cdr [list]
  (let [l list]
    (table.remove l 1)
    l))

(fn cadr [list] (car (cdr list)))

(fn foreach [fun list]
  (each [_ x (ipairs list)]
    (fun x)))

(fn ormap [fun list]
  (if (= (length list) 0)
        false
      (fun (car list))
        true
    (ormap fun (cdr list))))

(fn null?     [x] (= x nil))
(fn not-null? [x] (not (null? x)))


;; General helper functions

(fn vis/replace [file content]
  (file:delete 0 file.size)
  (file:insert 0 content))

;; :| in FILE_SAVE_PRE segfaults. Check #652
;; From vis-go
(fn vis/pipe [file cmd]
  (let [(status out err) (vis:pipe file {"start" 0 "finish" file.size} cmd)
        pos vis.win.selection.pos]
    (if (or (> 0 status) (not out))
          (do (when  err (vis:info err)) false)
      (do (vis/replace file out)
        (set vis.win.selection.pos pos)))))

;; (fn filetype [path] path)
;; (fn filetype? [path ft] true)
;; (fn dirname  [path] path)

;; String functions

(fn startswith [str prefix]
  (= (string.sub str 1 (string.len prefix))
    prefix))

(fn endswith [str suffix]
  (= (string.sub str (- (string.len str) (string.len suffix) -1) -1)
    suffix))


;; set ... functions

(fn set/multiple [list]
  (foreach (fn [x] (vis:command (.. "set " x))) list))

;; Set the global config. Called in INIT
(fn set/global []
  (set/multiple ["tw 4" "syntax off"]))

;; Set the default configuration for languages
(fn set/default []
  (set/multiple ["tw 4" "et off" "ai off"]))

;; This is absolutely broken for multiple windows
;; I will be solving it by using tmux
;; Vis events aren't flexible enough
(local flangs ["nix" "rkt" "fnl" "scm"])
(fn set/lang [win]
  (set/default)
  (when (and (not-null? win.file.path)
          (ormap (fn [x] (endswith win.file.path (.. "." x))) flangs))
    (set/multiple ["tw 2" "et on" "ai on"])))


;; Language specific functions
   
;; Run `go fmt` if file ends w/ .go
(fn go/fmt [file path]
  (when (and (not-null? path) (endswith path ".go"))
    (vis/pipe file "gofmt")))

(fn lisp/sub-lambda [file path]
  (when (and (not-null? path)
             (ormap (fn [x] (endswith path (.. "." x)))
                 ["rkt" "fnl"]))
    (local pos vis.win.selection.pos)
    (vis/replace file (string.gsub (file:content 0 file.size)
                          " %(lambda " " (λ "))
    (set vis.win.selection.pos pos)))


;; Commands/Keybinds

(fn cmd/ns [_] (vis:command "!ns"))
(fn cmd/st [_] (os.execute "st &"))
(fn cmd/0x0 [_ _ win _ range]
  (os.execute (string.format "echo '%s' >/tmp/vis";;| 0x0 | xin"
    (win.file:content range.start range.finish)))
  (vis:redraw))

(foreach (fn [x] (vis:command_register (car x) (cadr x)))
  [["ns" cmd/ns] ["oxo" cmd/0x0]
   ["st" cmd/st]])

(foreach (fn [x] (vis:map vis.modes.NORMAL (car x) (cadr x)))
  [[" ns" cmd/ns] [" st" cmd/st]])

;; Misc

;; Hijacking this function for proper selection style
(fn vis.types.window.set_syntax [win syntax]
  (set win.syntax nil)
  (foreach (fn [x] (win:style_define (car x) (cadr x)))
    [[win.STYLE_CURSOR         "back: 16"]
     [win.STYLE_STATUS         ""]
     [win.STYLE_STATUS_FOCUSED "reverse"]]))

;; Set title of the vis window
(fn *settitle* [title]
  (vis:command
    (string.format ":!printf '\\033]]0;%s: %s\\a'"
      (if (os.getenv "IN_NIX_SHELL") "!vis" "vis")
      title)))

(fn settitle [win]
  (*settitle*
    (if (null? win.file.path)
          "*new*"
        (not (startswith win.file.path (os.getenv "HOME")))
          win.file.path
      (.. "~" (string.sub win.file.path
                (+ 1 (string.len (os.getenv "HOME"))) -1)))))


;; Event subscriptions

(vis.events.subscribe vis.events.INIT set/global)
(vis.events.subscribe vis.events.FILE_SAVE_PRE (fn [file path]
  (go/fmt          file path)
  (lisp/sub-lambda file path)))
(vis.events.subscribe vis.events.WIN_OPEN (fn [win]
  (settitle win)
  (set/lang win)
  (vis:command "set rnu on")))
;; This is loaded by visrc.lua which is generated by home-manager

;; TODO: * Consider binding ^w binds to tmux commands
;;       * Register :terminal to create a terminal split
;;       * Replace vis-open with fzy?
;;       * Should I change pwd to `basename win.file.path`?

;; NOTE: * if acts more like cond
;;       * macros must be in a separate file

(require "vis")

;; Lisp functions

(fn car [list] (. list 1))

;; Side-effects suck
(fn cdr [list]
  (let [l list]
    (table.remove l 1)
    l))

(fn cadr [list] (car (cdr list)))

(fn foreach [fun list]
  (each [_ x (ipairs list)]
    (fun x)))

(fn ormap [fun list]
  (if (= (length list) 0)
        false
      (fun (car list))
        true
    (ormap fun (cdr list))))

(fn null?     [x] (= x nil))
(fn not-null? [x] (not (null? x)))


;; General helper functions

(fn vis/replace [file content]
  (file:delete 0 file.size)
  (file:insert 0 content))

;; :| in FILE_SAVE_PRE segfaults. Check #652
;; From vis-go
(fn vis/pipe [file cmd]
  (let [(status out err) (vis:pipe file {"start" 0 "finish" file.size} cmd)
        pos vis.win.selection.pos]
    (if (or (> 0 status) (not out))
          (do (when  err (vis:info err)) false)
      (do (vis/replace file out)
        (set vis.win.selection.pos pos)))))

;; (fn filetype [path] path)
;; (fn filetype? [path ft] true)
;; (fn dirname  [path] path)

;; String functions

(fn startswith [str prefix]
  (= (string.sub str 1 (string.len prefix))
    prefix))

(fn endswith [str suffix]
  (= (string.sub str (- (string.len str) (string.len suffix) -1) -1)
    suffix))


;; set ... functions

(fn set/multiple [list]
  (foreach (fn [x] (vis:command (.. "set " x))) list))

;; Set the global config. Called in INIT
(fn set/global []
  (set/multiple ["tw 4" "syntax off"]))

;; Set the default configuration for languages
(fn set/default []
  (set/multiple ["tw 4" "et off" "ai off"]))

;; This is absolutely broken for multiple windows
;; I will be solving it by using tmux
;; Vis events aren't flexible enough
(local flangs ["nix" "rkt" "fnl" "scm"])
(fn set/lang [win]
  (set/default)
  (when (and (not-null? win.file.path)
          (ormap (fn [x] (endswith win.file.path (.. "." x))) flangs))
    (set/multiple ["tw 2" "et on" "ai on"])))


;; Language specific functions
   
;; Run `go fmt` if file ends w/ .go
(fn go/fmt [file path]
  (when (and (not-null? path) (endswith path ".go"))
    (vis/pipe file "gofmt")))

(fn lisp/sub-lambda [file path]
  (when (and (not-null? path)
             (ormap (fn [x] (endswith path (.. "." x)))
                 ["rkt" "fnl"]))
    (local pos vis.win.selection.pos)
    (vis/replace file (string.gsub (file:content 0 file.size)
                          " %(lambda " " (λ "))
    (set vis.win.selection.pos pos)))


;; Commands/Keybinds

(fn cmd/ns [_] (vis:command "!ns"))
(fn cmd/st [_] (os.execute "st &"))
(fn cmd/0x0 [_ _ win _ range]
  (os.execute (string.format "echo '%s' >/tmp/vis";;| 0x0 | xin"
    (win.file:content range.start range.finish)))
  (vis:redraw))

(foreach (fn [x] (vis:command_register (car x) (cadr x)))
  [["ns" cmd/ns] ["oxo" cmd/0x0]
   ["st" cmd/st]])

(foreach (fn [x] (vis:map vis.modes.NORMAL (car x) (cadr x)))
  [[" ns" cmd/ns] [" st" cmd/st]])

;; Misc

;; Hijacking this function for proper selection style
(fn vis.types.window.set_syntax [win syntax]
  (set win.syntax nil)
  (foreach (fn [x] (win:style_define (car x) (cadr x)))
    [[win.STYLE_STATUS         ""]
     [win.STYLE_STATUS_FOCUSED "reverse"]]))

;; Set title of the vis window
(fn *settitle* [title]
  (vis:command
    (string.format ":!printf '\\033]]0;%s: %s\\a'"
      (if (os.getenv "IN_NIX_SHELL") "!vis" "vis")
      title)))

(fn settitle [win]
  (*settitle*
    (if (null? win.file.path)
          "*new*"
        (not (startswith win.file.path (os.getenv "HOME")))
          win.file.path
      (.. "~" (string.sub win.file.path
                (+ 1 (string.len (os.getenv "HOME"))) -1)))))


;; Event subscriptions

(vis.events.subscribe vis.events.INIT set/global)
(vis.events.subscribe vis.events.FILE_SAVE_PRE (fn [file path]
  (go/fmt          file path)
  (lisp/sub-lambda file path)))
(vis.events.subscribe vis.events.WIN_OPEN (fn [win]
  (settitle win)
  (set/lang win)
  (vis:command "set rnu on")))
