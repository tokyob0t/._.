(require-macros :macros)

(local naughty (require :naughty))

(let [konnect naughty.connect_signal
      signal "request::display_error"]
  (konnect signal
           (fn [message startup?]
             (let [{: notification} naughty
                   title (.. "Oops, an error happened"
                             (or (and startup? " during startup!") "!"))]
               (notification {: message : title :urgency :critical})))))

(require :fnl.init)

