(local awful (require :awful))
(local Widgets (require :fnl.widgets.init))

(fn [c]
  (let [{: Align : Flex : Fixed : Text : Icon} Widgets
        FloatingButton awful.titlebar.widget.floatingbutton
        MaximizedButton awful.titlebar.widget.maximizedbutton
        StickyButton awful.titlebar.widget.stickybutton
        OnTopButton awful.titlebar.widget.ontopbutton
        CloseButton awful.titlebar.widget.closebutton
        titlebar (awful.titlebar c)]
    (set titlebar.widget
         (Align {:on_primary_pressed #(c:activate {:action :mouse_move
                                                   :context :titlebar})
                 :on_secondary_pressed #(c:activate {:action :mouse_resize
                                                     :context :titlebar})}
                (Fixed (Icon {:icon c.class})) ;
                (Flex (Text {:text c.name}))
                (Fixed ;
                       (FloatingButton c) (MaximizedButton c) (StickyButton c)
                       (OnTopButton c) (CloseButton c))))
    titlebar))

