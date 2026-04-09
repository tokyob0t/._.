(require-macros :macros)

(local gfs (require :gears.filesystem))
(local themes-path (gfs.get_themes_dir))
(local theme-assets (require :beautiful.theme_assets))
(local lgi (require :lgi))
(local GLib (lgi.require :GLib :2.0))
(local theme-variables (require :fnl.theme.variables))

(local CONFIG
       (or (os.getenv :XDG_CONFIG_HOME) (.. (os.getenv :HOME) :/.config)))

(fn snake->kebab [k]
  (string.gsub k "_" "-"))

(fn flatten [tbl ?prefix ?out]
  (let [prefix (or ?prefix "")
        out (or ?out {})]
    (each [k v (pairs tbl)]
      (let [new-key (if (= prefix "")
                        (tostring k)
                        (.. prefix "-" k))]
        (if (= (type v) :table)
            (flatten v new-key out)
            (set (. out new-key) v))))
    out))

(local theme (let [c theme-variables.color
                   s theme-variables.state
                   bar (require :fnl.theme.bar)
                   border (require :fnl.theme.border)
                   shadow (require :fnl.theme.shadow)
                   titlebar (require :fnl.theme.titlebar)
                   layout (require :fnl.theme.layout)
                   wallpaper (let [background (.. CONFIG :/background)
                                   default-background (.. themes-path
                                                          :default/background.png)]
                               (if (GLib.file_test background :EXISTS)
                                   background
                                   default-background))
                   submenu-icon (.. themes-path :default/submenu.png)]
               (-> {:font "Cantarell 8"
                    :awesome-icon (theme-assets.awesome_icon (dpi 512)
                                                             c.primary)
                    :menu {: submenu-icon :height (dpi 15) :width (dpi 100)}
                    :bg {:normal c.bg
                         :focus c.primary
                         :urgent s.urgent
                         :minimize s.minimize
                         :systray c.bg}
                    :fg {:normal c.fg
                         :focus c.fg-strong
                         :urgent c.fg-strong
                         :minimize c.fg-strong
                         :warning s.warning
                         :error s.error
                         :success s.success}
                    : bar
                    : border
                    : shadow
                    : titlebar
                    : wallpaper
                    : layout}
                   (flatten))))

(local TOTALLY-NOT-A-HACK-TO-PASS-NEXT-CHECK [])

(setmetatable {[TOTALLY-NOT-A-HACK-TO-PASS-NEXT-CHECK] true}
              {:__index #(rawget theme (snake->kebab $2))
               :__newindex #(error "Theme is read-only. Please edit theme instead.")
               :__pairs #(pairs theme)})

