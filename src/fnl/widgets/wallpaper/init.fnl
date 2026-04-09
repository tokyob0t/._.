(local awful (require :awful))
(local wibox (require :wibox))
(local asztalify (require :fnl.core.asztalify))
(local bful (require :beautiful))

(local GLib (let [lgi (require :lgi)]
              (lgi.require :GLib :2.0)))

(fn [s]
  (let [Wallpaper (asztalify awful.wallpaper
                             {:set_children #($:set_widget (?. $2 1))})
        Image (asztalify wibox.widget.imagebox)
        Tile (asztalify wibox.container.tile)]
    (Wallpaper {:screen s}
               (Tile {:halign :center :valign :center :tiled false}
                     (Image {:image bful.wallpaper
                             :downscale true
                             :upscale true})))))
