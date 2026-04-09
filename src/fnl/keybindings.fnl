(require-macros :macros)

(local awful (require :awful))
(local menubar (require :menubar))

(local ModKey {:SUPER :Mod4 :ALT :Mod1 :SHIFT :Shift :CTRL :Control})

(set awful.input.xkb_layout :us)
(set awful.input.xkb_variant :altgr-intl)
(set awful.input.keyboard_repeat_rate 40)
(set awful.input.keyboard_repeat_delay 320)

(set awful.input.rules
     (let [rule (λ [rule properties]
                  {: rule : properties})]
       [(rule {:type :touchpad}
              {:natural_scrolling 1
               :tap_to_click 1
               :middle_button_emulation 1
               :scroll_method :two_finger
               :tap_3fg_drag 1
               :tap_to_click 1})
        (rule {:type :pointer} {:accel_profile :flat})]))

(local BUTTON awful.button.names)
(local KEYGROUP awful.key.keygroup)

(fn button [modifiers button on_press]
  (let [button (if (string? button) (. BUTTON button) button)]
    (awful.button modifiers button on_press)))

(fn key [modifiers key on_press ?group ?description]
  (let [keygroup (. KEYGROUP key)
        is-keygroup? (not (nil? keygroup))]
    (awful.key {: modifiers
                :key (if is-keygroup? nil key)
                :keygroup (if is-keygroup? keygroup)
                : on_press
                :group ?group
                :description ?description})))

(let [konnect _G.capi.client.connect_signal]
  (konnect "request::default_mousebindings"
           #(let [append awful.mouse.append_client_mousebindings]
              (append [(button [] :LEFT #($:activate {:context :mouse_click}))
                       (button [ModKey.SUPER] :LEFT
                               #($:activate {:action :mouse_move
                                             :context :mouse_click}))
                       (button [ModKey.SUPER] :RIGHT
                               #($:activate {:action :mouse_resize
                                             :context :mouse_click}))])))
  (konnect "request::default_keybindings"
           #(let [append awful.keyboard.append_client_keybindings]
              (append [(key [ModKey.SUPER] :f
                            #(set $.fullscreen (not $.fullscreen)) :client
                            "toggle fullscreen")
                       (key [ModKey.SUPER] :w #($:kill) :client :close)
                       (key [ModKey.SUPER ModKey.SHIFT] :c
                            awful.client.floating.toggle :client
                            "toggle floating")]))))

(let [append awful.mouse.append_global_mousebindings]
  (append [(button [ModKey.SUPER] :RIGHT #(_G.mymainmenu:toggle))
           (button [ModKey.SUPER] :SCROLL_UP awful.tag.viewprev)
           (button [ModKey.SUPER] :SCROLL_DOWN awful.tag.viewnext)]))

(let [append awful.keyboard.append_global_keybindings]
  (append [(key [ModKey.SUPER] :NUMROW
                (λ [index]
                  (let [s (awful.screen.focused)
                        tag (. s.tags index)]
                    (when tag
                      (tag:view_only)))) :tag "only view tag")
           (key [ModKey.SUPER ModKey.SHIFT] :q awesome.quit :awesome
                "quit awesome")
           (key [ModKey.SUPER ModKey.SHIFT] :r awesome.restart :awesome
                "restart awesome")
           (key [ModKey.SUPER] :l #(awesome.lock) :awesome "lock screen")
           (key [ModKey.SUPER] :t #(awful.spawn _G.terminal) :launcher
                "open a terminal")
           (key [ModKey.SUPER] :r
                #(let [s (awful.screen.focused)]
                   (s.bar:prompt)) :launcher "run prompt")
           (key [ModKey.SUPER] :p #(menubar.show) :launcher "show the menubar")
           (key [ModKey.ALT] :Tab #(awful.client.focus.byidx 1) :client
                "focus next by index")
           (key [ModKey.ALT ModKey.SHIFT] :Tab
                #(awful.client.focus.byidx (- 1)) :client
                "focus previous by index")
           (key [ModKey.SUPER] :Return #(awful.layout.inc 1) :layout
                "select next")
           (key [ModKey.SUPER ModKey.SHIFT] :Return #(awful.layout.inc (- 1))
                :layout "select previous")]))

