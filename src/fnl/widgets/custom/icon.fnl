(local base (require :wibox.widget.base))
(local gtable (require :gears.table))
(local imagebox (require :wibox.widget.imagebox))
(local lgi (require :lgi))
(local Rsvg (lgi.require :Rsvg))
(local bful (require :beautiful))

(local GdkPixbuf (lgi.require (.. :G :d :k :Pixbuf)))
(local Gio (lgi.require :Gio))
(local GLib (lgi.require :GLib :2.0))

(local HOME (os.getenv :HOME))
(local DATA_HOME (or (os.getenv :XDG_DATA_HOME) (.. HOME :/.local/share)))

(local icon-paths [:/usr/share/icons
                   :/usr/local/share/icons
                   (.. HOME :/.icons)
                   (.. DATA_HOME :/icons)
                   :/usr/share/pixmaps])

(local icon {:mt {}})

(fn icon.lookup-icon [icon-name ...]
  (when (not icon.icon-theme)
    (set icon.icon-theme (let [Gtk (lgi.require (.. :G :t :k) :3.0)
                               theme (Gtk.IconTheme.new)]
                           (each [_ path (ipairs icon-paths)]
                             (theme:append_search_path path))
                           theme)))
  (let [{: icon-theme} icon]
    (each [_ name (ipairs [icon-name (icon-name:lower) (icon-name:upper)])]
      (let [icon-info (icon-theme:lookup_icon name 512 :USE_BUILTIN)]
        (if (and icon-info (icon-info:get_filename))
            (lua "return icon_info:get_filename()"))))))

(fn icon.set_icon [self image]
  (local Gdk (lgi.require (.. :G :d :k) :3.0))
  (if (= (type image) :string)
      (if (string.match image "%-symbolic$")
          (let [path (icon.lookup-icon image)]
            (when (not path) (lua "return "))
            (self:set_image (Rsvg.Handle.new_from_file path))
            (self:set_color self.color))
          (GLib.FileTest image :EXISTS)
          (self:set_image image)
          (self:set_image (icon.lookup-icon image)))
      (GdkPixbuf.Pixbuf:is_type_of image)
      (self:set_image (Gdk.cairo_surface_create_from_pixbuf image 1))
      (Gio.Icon:is_type_of image)
      (self:set_image (image:to_string))
      (self:set_image image)))

(fn icon.set_shape [self shape] (set self.clip_shape shape))
(fn icon.set_size [self size] (set self.forced_width size)
  (set self.forced_height size)
  (self:emit_signal "property::size" size))

(fn icon.set_color [self color]
  (set self._private.color color)
  (when (and self._private.original_image
             (Rsvg.Handle:is_type_of self._private.original_image))
    (set self.stylesheet (let [css "* { fill: %s; } .success { fill: %s; } .error { fill: %s; } .warning { fill: %s; }"
                               {: fg-success : fg-error : fg-warning} bful]
                           (string.format css color fg-success fg-error
                                          fg-warning)))
    (self:emit_signal "widget::redraw_needed")
    (self:emit_signal "property::color")))

(fn icon.get_color [self] self._private.color)
(fn new [img size color resize-allowed clip-shape ...]
  (let [ret (base.make_widget nil nil {:enable_properties true})]
    (gtable.crush ret imagebox true)
    (gtable.crush ret icon true)
    (set ret.valign :center)
    (set ret.halign :center)
    (set ret._private.resize true)
    (ret:set_color (or color "#fff"))
    (when img (ret:set_icon img))
    (when size (ret:set_size size))
    (when (not= resize-allowed nil) (set ret.resize resize-allowed))
    (set ret._private.clip_shape clip-shape)
    (set ret._private.clip_args [...])
    ret))

(fn icon.mt.__call [_ ...] (new ...))

(setmetatable icon icon.mt)

