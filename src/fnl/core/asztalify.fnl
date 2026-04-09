(local Binding (require :fnl.core.binding))
(local textbox (require :wibox.widget.textbox))
(local base (require :wibox.widget.base))

(fn idle [cb ...]
  (let [lgi (require :lgi)
        GLib (lgi.require :GLib :2.0)
        args [...]
        id (GLib.idle_add GLib.PRIORITY_DEFAULT_IDLE
                          (fn [] (cb (unpack args)) false))]
    #(GLib.source_remove id)))

;; fnlfmt: skip
(local SCROLL_MAP {
   4 [0 -1]
   5 [0 1]
   6 [-1 0]
   7 [1 0]})

(local input-handlers {:on_button_pressed true
                       :on_button_released true
                       :on_primary_pressed true
                       :on_primary_released true
                       :on_secondary_pressed true
                       :on_secondary_released true
                       :on_middle_pressed true
                       :on_middle_released true
                       :on_click true
                       :on_scroll true
                       :on_scroll_up true
                       :on_scroll_down true
                       :on_scroll_left true
                       :on_scroll_right true
                       :on_hover true
                       :on_hover_enter true
                       :on_hover_leave true})

(fn extract-bindings [props]
  (collect [k v (pairs props)]
    (when (Binding:type-of? v)
      (set (. props k) (v:get))
      (values k v))))

(fn extract-input-handlers [props]
  (collect [k v (pairs props)]
    (when (and (= (k:sub 1 2) :on) (= (type v) :function) (. input-handlers k))
      (set (. props k) nil)
      (values k v))))

(fn extract-property-handlers [props]
  (collect [k v (pairs props)]
    (when (and (= (k:sub 1 11) :on_property) (= (type v) :function))
      (set (. props k) nil)
      (values (.. "property::" (k:sub 13 (length k))) v))))

(fn extract-children [?args]
  (var args {})
  (let [children []]
    (each [_ v (ipairs ?args)]
      (if (not= (type v) :table)
          (table.insert children (textbox (tostring v)))
          (rawget v :is_widget)
          (table.insert children v)
          (or (. v :widget) (. v :layout))
          (table.insert children (base.make_widget_declarative v))
          (next v)
          (set args v)))
    (each [k v (pairs args)]
      (set (. args k) nil)
      (set (. args (k:gsub "-" "_")) v))
    [args children]))

(fn connect-bindings [widget bindings]
  (each [prop binding (pairs bindings)]
    (widget:connect_signal :destroyed
                           (binding:subscribe #(set (. widget prop) $...))))
  widget)

(fn normalize-handlers [h]
  (let [table? #(= (type $) :table)
        click (if (table? h.on_click) h.on_click {})
        scroll (if (table? h.on_scroll) h.on_scroll {})
        hover (if (table? h.on_hover) h.on_hover {})
        button {}]
    ;; BUTTON
    (set button.press h.on_button_pressed)
    (set button.release h.on_button_released)
    ;; CLICK
    (when h.on_primary_pressed
      (set click.primary_press h.on_primary_pressed))
    (when h.on_primary_released
      (set click.primary_release h.on_primary_released))
    (when h.on_secondary_pressed
      (set click.secondary_press h.on_secondary_pressed))
    (when h.on_secondary_released
      (set click.secondary_release h.on_secondary_released))
    (when h.on_middle_pressed
      (set click.middle_press h.on_middle_pressed))
    (when h.on_middle_released
      (set click.middle_release h.on_middle_released))
    ;; SCROLL
    (when (= (type h.on_scroll) :function)
      (set scroll.any h.on_scroll))
    (when h.on_scroll_up
      (set scroll.up h.on_scroll_up))
    (when h.on_scroll_down
      (set scroll.down h.on_scroll_down))
    (when h.on_scroll_left
      (set scroll.left h.on_scroll_left))
    (when h.on_scroll_right
      (set scroll.right h.on_scroll_right))
    ;; HOVER
    (when (= (type h.on_hover) :function)
      (set hover.any h.on_hover))
    (when h.on_hover_enter
      (set hover.enter h.on_hover_enter))
    (when h.on_hover_leave
      (set hover.leave h.on_hover_leave))
    {: button : click : scroll : hover}))

(fn connect-input-handlers [widget handlers]
  (let [h (normalize-handlers handlers)]
    (when (or (?. h :button :press) (?. h :click :primary_press)
              (?. h :click :secondary_press) (?. h :click :middle_press)
              (?. h :scroll :any) (?. h :scroll :up) (?. h :scroll :down)
              (?. h :scroll :left) (?. h :scroll :right))
      (widget:connect_signal "button::press"
                             (fn [self lx ly button]
                               (when (?. h :button :press)
                                 (idle #((?. h :button :press) self lx ly
                                                               button)))
                               (case button
                                 1 (when (?. h :click :primary_press)
                                     (idle #((?. h :click :primary_press) self
                                                                          lx ly)))
                                 2 (when (?. h :click :middle_press)
                                     (idle #((?. h :click :middle_press) self
                                                                         lx ly)))
                                 3 (when (?. h :click :secondary_press)
                                     (idle #((?. h :click :secondary_press) self
                                                                            lx
                                                                            ly))))
                               (let [delta (. SCROLL_MAP button)]
                                 (when delta
                                   (let [[dx dy] delta]
                                     (when (?. h :scroll :any)
                                       (idle #((?. h :scroll :any) self dx dy)))
                                     (case button
                                       4 (when (?. h :scroll :up)
                                           (idle #((?. h :scroll :up) self)))
                                       5 (when (?. h :scroll :down)
                                           (idle #((?. h :scroll :down) self)))
                                       6 (when (?. h :scroll :left)
                                           (idle #((?. h :scroll :left) self)))
                                       7 (when (?. h :scroll :right)
                                           (idle #((?. h :scroll :right) self))))))))))
    (when (or (?. h :button :release) (?. h :click :primary_release)
              (?. h :click :secondary_release) (?. h :click :middle_release))
      (widget:connect_signal "button::release"
                             (fn [self lx ly button]
                               (when (?. h :button :release)
                                 (idle #((?. h :button :release) self lx ly
                                                                 button)))
                               (case button
                                 1 (when (?. h :click :primary_release)
                                     (idle #((?. h :click :primary_release) self
                                                                            lx
                                                                            ly)))
                                 2 (when (?. h :click :middle_release)
                                     (idle #((?. h :click :middle_release) self
                                                                           lx ly)))
                                 3 (when (?. h :click :secondary_release)
                                     (idle #((?. h :click :secondary_release) self
                                                                              lx
                                                                              ly)))))))
    (when (or (?. h :hover :enter) (?. h :hover :leave)
              (= (type handlers.on_hover) :function))
      (widget:connect_signal "mouse::enter"
                             (fn []
                               (when (= (type handlers.on_hover) :function)
                                 (idle #((handlers.on_hover) widget true)))
                               (when (?. h :hover :enter)
                                 (idle #((?. h :hover :enter) widget)))))
      (widget:connect_signal "mouse::leave"
                             (fn []
                               (when (= (type handlers.on_hover) :function)
                                 (idle #((handlers.on_hover) widget false)))
                               (when (?. h :hover :leave)
                                 (idle #((?. h :hover :leave) widget))))))
    widget))

(fn connect-property-handlers [widget signal-handlers]
  (each [prop callback (pairs signal-handlers)]
    (let [signal (prop:gsub "_" "-")]
      (widget:connect_signal signal #(idle callback $...))))
  widget)

(fn construct [ctor props]
  (let [custom-props (collect [k v (pairs props)]
                       (when (string.match k "^[gs]et_")
                         (set (. props k) nil)
                         (values key v)))
        is-function? (= (type ctor) :function)]
    (if is-function? (set props.layout ctor) (set props.widget ctor))
    (local ret (base.make_widget_declarative props))
    (each [k v (pairs custom-props)]
      (rawset ret k v))
    ret))

(λ [ctor ?config]
  (let [{: set_children : get_children} (or ?config {})]
    (fn [...]
      (let [[props children] (extract-children [...])
            setup (let [{: setup} props]
                    (set props.setup nil)
                    setup)
            bindings (extract-bindings props)
            input-handlers (extract-input-handlers props)
            property-handlers (extract-property-handlers props)]
        (local ret (-> (construct ctor props)
                       (connect-input-handlers input-handlers)
                       (connect-property-handlers property-handlers)
                       (connect-bindings bindings)))
        (when (> (length children) 0)
          ((or set_children ret.set_children) ret children))
        (when setup
          (setup ret))
        ret))))

