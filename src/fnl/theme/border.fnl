(local theme-variables (require :fnl.theme.variables))

(let [c theme-variables.color
      s theme-variables.state]
  {:width 0 :color {:normal c.bg :active c.primary :marked s.error}})

