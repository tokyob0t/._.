(local bful (require :beautiful))
(local gtimer (require :gears.timer))
(local lockscreen (require :lockscreen))
(local naughty (require :naughty))

(when awesome.x11_fallback_info
  (gtimer.delayed_call #(let [{: notification} naughty
                              info awesome.x11_fallback_info
                              message (string.format (.. "Your config was skipped because it contains X11-specific code that "
                                                         "won't work on Wayland."
                                                         "File: %s:%d"
                                                         "Pattern: %s"
                                                         "Code: %s"
                                                         "Suggestion: %s"
                                                         "Edit your rc.lua to remove X11 dependencies, then restart somewm.")
                                                     (or info.config_path
                                                         :unknown)
                                                     (or info.line_number 0)
                                                     (or info.pattern :unknown)
                                                     (or info.line_content "")
                                                     (or info.suggestion
                                                         "See somewm migration guide"))]
                          (notification {: message
                                         :timeout 0
                                         :title "Config contains X11 patterns - using fallback"
                                         :urgency :critical}))))

(bful.init (require :fnl.theme.init))

(lockscreen.init)

(require :fnl.globals)
(require :fnl.keybindings)
(require :fnl.signals.init)

