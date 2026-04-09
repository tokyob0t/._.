(local awful (require :awful))

(let [{: tag} _G.capi
      konnect tag.connect_signal
      signal "request::default_layouts"]
  (konnect signal #(let [append awful.layout.append_default_layouts
                         {: suit} awful.layout]
                     (append [suit.tile suit.floating]))))

