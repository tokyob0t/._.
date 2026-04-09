(local gtable (require :gears.table))
(local flex (require :wibox.layout.flex))
(local Fixed (require :fnl.widgets.custom.fixed))

(fn [orientation ...]
  (let [ret (Fixed orientation ...)]
    (gtable.crush ret flex true)
    (set ret._private.fill_space nil)
    ret))

