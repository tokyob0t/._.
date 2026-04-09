(local base (require :wibox.widget.base))
(local gtable (require :gears.table))
(local align (require :wibox.layout.align))

(local Align {})

(fn Align.set_orientation [self orientation]
  (let [dir (if (= orientation :vertical) :y :x)]
    (when (not= dir self._private.dir)
      (set self._private.dir dir)
      (self:emit_signal "property::orientation" orientation)
      (self:emit_signal "widget::layout_changed"))))

(fn Align.get_orientation [self]
  (if (= self._private.dir :y) :vertical :horizontal))

(fn [orientation first second third]
  (let [ret (base.make_widget nil nil {:enable_properties true})]
    (gtable.crush ret align true)
    (gtable.crush ret Align true)
    (set ret._private.dir (if (= orientation :vertical) :y :x))
    (ret:set_expand :inside)
    (ret:set_first first)
    (ret:set_second second)
    (ret:set_third third)
    (set ret.allow_empty_widget true)
    ret))
