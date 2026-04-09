(local base (require :wibox.widget.base))
(local gtable (require :gears.table))
(local fixed (require :wibox.layout.fixed))

(local Fixed {})

(fn Fixed.set_orientation [self orientation]
  (let [dir (if (= orientation :vertical) :y :x)]
    (when (not= dir self._private.dir)
      (set self._private.dir dir)
      (self:emit_signal "property::orientation" orientation)
      (self:emit_signal "widget::layout_changed"))))

(fn Fixed.get_orientation [self]
  (if (= self._private.dir :y) :vertical :horizontal))

(fn [orientation ...]
  (let [ret (base.make_widget nil nil {:enable_properties true})]
    (gtable.crush ret fixed true)
    (gtable.crush ret Fixed true)
    (set ret._private.dir (if (= orientation :vertical) :y :x))
    (set ret._private.widgets [])
    (ret:set_spacing 0)
    (ret:fill_space false)
    (when (select 1 ...)
      (ret:add ...))
    ret))
