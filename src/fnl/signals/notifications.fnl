(local naughty (require :naughty))

(let [konnect naughty.connect_signal
      signal "request::display"]
  (konnect signal #(naughty.layout.box {:notification $})))

