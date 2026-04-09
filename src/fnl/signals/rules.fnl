(local ruled (require :ruled))
(local awful (require :awful))
(local bful (require :beautiful))

(let [konnect ruled.client.connect_signal
      signal "request::rules"]
  (konnect signal #(let [rule ruled.client.append_rule]
                     (rule {:id :general
                            :properties {:border_color bful.border_normal
                                         :border_width bful.border_width
                                         :focus awful.client.focus.filter
                                         :placement (+ awful.placement.no_overlap
                                                       awful.placement.no_offscreen)
                                         :raise true
                                         :screen awful.screen.preferred}
                            :rule {}})
                     (rule {:id :titlebars-enabled
                            :properties {:titlebars_enabled true}
                            :rule_any {:type [:normal]}})
                     (rule {:id :polkit-floating
                            :properties {:floating true
                                         :placement awful.placement.centered
                                         :raise true
                                         :screen awful.screen.preferred
                                         :sticky true}
                            :rule_any {:class [:soteria]}}))))

(let [konnect ruled.notification.connect_signal
      signal "request::rules"]
  (konnect signal
           #(ruled.notification.append_rule {:properties {:implicit_timeout 5
                                                          :screen awful.screen.preferred}
                                             :rule {}})))

