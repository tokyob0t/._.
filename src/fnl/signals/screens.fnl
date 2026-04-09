(local awful (require :awful))

(local Wallpaper (require :fnl.widgets.wallpaper.init))
(local Bar (require :fnl.widgets.bar.init))

(let [konnect screen.connect_signal]
  (konnect "request::wallpaper" #(set $.wallpaper (Wallpaper $)))
  (konnect "request::desktop_decoration"
           (λ [s]
             (let [output-name (and s.output s.output.name)
                   restore (and output-name
                                (. awful.permissions.saved_tags output-name))]
               (if restore
                   (do
                     (set (. awful.permissions.saved_tags output-name) nil)
                     (local client-tags {})
                     (each [_ td (ipairs restore)]
                       (local t
                              (awful.tag.add td.name
                                             {:gap td.gap
                                              :layout td.layout
                                              :master_count td.master_count
                                              :master_width_factor td.master_width_factor
                                              :screen s
                                              :selected td.selected}))
                       (each [_ c (ipairs td.clients)]
                         (when c.valid
                           (when (not (. client-tags c))
                             (set (. client-tags c) []))
                           (table.insert (. client-tags c) t))))
                     (each [c tags (pairs client-tags)]
                       (c:move_to_screen s)
                       (c:tags tags)))
                   (awful.tag [:1 :2 :3 :4 :5 :6 :7 :8 :9] s
                              awful.layout.suit.tile))) ; (set s.scale 1.5)
             (set s.bar (Bar s)))))

