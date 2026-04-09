(local wibox (require :wibox))
(local awful (require :awful))
(local asztalify (require :fnl.core.asztalify))

;; fnlfmt: skip
{;; Primitives
 :Text (asztalify wibox.widget.textbox)
 :Slider (asztalify wibox.widget.slider)
 :Icon (asztalify (require :fnl.widgets.custom.icon))
 :Calendar (asztalify wibox.widget.calendar)
 :Checkbox (asztalify wibox.widget.checkbox)
 :Graph (asztalify wibox.widget.graph)
 :ImageBox (asztalify wibox.widget.imagebox)
 :PieChart (asztalify wibox.widget.piechart)
 :ProgressBar (asztalify wibox.widget.progressbar)
 :Separator (asztalify wibox.widget.separator)
 :Systray (asztalify wibox.widget.systray)
 ;; Layouts
 :Align (asztalify (require :fnl.widgets.custom.align))
 :Fixed (asztalify (require :fnl.widgets.custom.fixed))
 :Flex (asztalify (require :fnl.widgets.custom.flex))
 ;; Containers
 :Constraint (asztalify wibox.container.constraint)
 :ArcChart (asztalify wibox.container.arcchart)
 :Background (asztalify wibox.container.background)
 :Border (asztalify wibox.container.border)
 :Margin (asztalify wibox.container.margin)
 :Mirror (asztalify wibox.container.mirror)
 :Place (asztalify wibox.container.place)
 :RadialProgressBar (asztalify wibox.container.radialprogressbar)
 :Rotate (asztalify wibox.container.rotate)
 :Scroll (asztalify wibox.container.scroll)
 :Tile (asztalify wibox.container.tile)
 ;; Other
 :SysTray (asztalify wibox.widget.systray)
 :KbdLayout (asztalify awful.widget.keyboardlayout)
 :LayoutBox (asztalify awful.widget.layoutbox)}

