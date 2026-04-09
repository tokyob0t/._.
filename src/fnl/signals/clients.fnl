(client.connect_signal "mouse::enter"
                       #($:activate {:context :mouse_enter :raise false}))

(client.connect_signal "request::titlebars"
                       (fn [c]
                         (let [Titlebar (require :fnl.widgets.titlebar.init)]
                           (set c.titlebar (Titlebar c)))))
