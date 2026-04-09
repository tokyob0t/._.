(require-macros :macros)
(local awful (require :awful))
(local wibox (require :wibox))
(local asztalify (require :fnl.core.asztalify))
(local bful (require :beautiful))
(local bind (require :fnl.core.binding))
(local gearsify (require :fnl.core.gearsify))
(local gshape (require :gears.shape))
(local lgi (require :lgi))
(local Wp (lgi.require :AstalWp))
(local Widgets (require :fnl.widgets.init))
(local Variable (require :fnl.core.variable))

(defpoll date 1000 #(os.date "%a %b %d, %H:%M:%S"))

; (defpoll date 1000 "date '+%a %b %d, %H:%M:%S'")

; (local date (let [v (Variable (os.date "%a %b %d, %H:%M"))]
;               (v:poll 60000 #(os.date "%a %b %d, %H:%M"))))

(local speaker (let [wp (Wp.get_default)]
                 (gearsify wp.audio.default_speaker)))

(fn AudioSlider [] ; using https://aylur.github.io/libastal/wireplumber/
  (let [{: Icon : Constraint : Slider : Fixed} Widgets
        $volume-icon (bind speaker :volume-icon)
        $volume (bind speaker :volume #(math.floor (* 100 $)))]
    (Fixed {:spacing (dpi 5)} ;
           (Icon {:icon $volume-icon :size (dpi 16) :scaling-quality :nearest})
           (Constraint {:width (dpi 100)}
                       (Slider {:value $volume
                                :bar-shape gshape.rounded_rect
                                :bar-height (dpi 5)
                                :bar-color bful.bg-minimize
                                :bar-active-color bful.bg-focus
                                :handle-width (dpi 12)
                                :handle-color bful.fg-focus
                                :handle-shape gshape.circle
                                :on_scroll_up #(set speaker.volume
                                                    (- speaker.volume 0.05))
                                :on_scroll_down #(set speaker.volume
                                                      (+ speaker.volume 0.05))
                                :on_property_value (λ [_ value]
                                                     (set speaker.volume
                                                          (/ value 100)))})))))

(fn Tag [tag]
  (let [{: Text : Background : Margin} Widgets
        $name (bind tag :name)
        $bg (bind tag :selected #(if $ bful.bg_focus bful.bg_normal))]
    (Background {:bg $bg
                 :border-strategy :inner
                 :on_primary_released #(tag:view_only)}
                (Margin {:left (dpi 4) :right (dpi 4)} (Text {:text $name})))))

(fn TagList [args]
  (let [{: screen} args
        {: Fixed} Widgets
        $tags (bind screen :tags #(icollect [_ t (ipairs $)] (Tag t)))]
    (Fixed {:children $tags
            :orientation :horizontal
            :on_scroll_up #(awful.tag.viewprev)
            :on_scroll_down #(awful.tag.viewnext)})))

(fn Client [client]
  (let [{: Background : Margin : Icon} Widgets
        $class (bind client :class)
        $bg (bind client :active #(if $ bful.bg_focus bful.bg_normal))]
    (Background {:bg $bg
                 :border-strategy :inner
                 :on_primary_pressed #(client:activate {:action :toggle_minimization
                                                        :context :tasklist})}
                (Margin {:left 4 :right 4} (Icon {:icon $class})))))

(fn TaskList [args]
  (let [{: screen} args
        {: Fixed} Widgets
        get #screen.all_clients
        clients* (let [v (Variable (get))] ; TODO: create a macro for this shit
                   (v:observe _G.capi.client "request::manage" get)
                   (v:observe _G.capi.client "request::unmanage" get))
        $clients (bind clients* #(icollect [_ c (ipairs $)] (Client c)))]
    (Fixed {:children $clients :on_destroyed #(clients*:drop)})))

(fn [s]
  (let [Wibar (asztalify awful.wibar {:set_children #($:set_widget (. $2 1))})
        {: Align : Fixed : Text : LayoutBox : KbdLayout : SysTray} Widgets
        prompt (awful.widget.prompt)
        $date (bind date)]
    (Wibar {:screen s
            :position :top
            :bg bful.bar-bg
            :setup (λ [self]
                     (set self.prompt #(prompt:run)))}
           (Align ;
                  (Fixed _G.mylauncher (TagList {:screen s}) prompt)
                  (TaskList {:screen s})
                  (Fixed {:spacing 10} ;
                         (KbdLayout) ;
                         (SysTray) ;
                         (AudioSlider) ;
                         (Text {:text $date}) ;
                         (LayoutBox {:screen s
                                     :on_primary_pressed #(awful.layout.inc 1)
                                     :on_secondary_pressed #(awful.layout.inc -1)}))))))

