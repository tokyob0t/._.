(local gfs (require :gears.filesystem))

(let [themes-path (gfs.get_themes_dir)]
  {:close-button-focus (.. themes-path :default/titlebar/close_focus.png)
   :close-button-normal (.. themes-path :default/titlebar/close_normal.png)
   :floating-button-focus-active (.. themes-path
                                     :default/titlebar/floating_focus_active.png)
   :floating-button-focus-inactive (.. themes-path
                                       :default/titlebar/floating_focus_inactive.png)
   :floating-button-normal-active (.. themes-path
                                      :default/titlebar/floating_normal_active.png)
   :floating-button-normal-inactive (.. themes-path
                                        :default/titlebar/floating_normal_inactive.png)
   :maximized-button-focus-active (.. themes-path
                                      :default/titlebar/maximized_focus_active.png)
   :maximized-button-focus-inactive (.. themes-path
                                        :default/titlebar/maximized_focus_inactive.png)
   :maximized-button-normal-active (.. themes-path
                                       :default/titlebar/maximized_normal_active.png)
   :maximized-button-normal-inactive (.. themes-path
                                         :default/titlebar/maximized_normal_inactive.png)
   :minimize-button-focus (.. themes-path :default/titlebar/minimize_focus.png)
   :minimize-button-normal (.. themes-path
                               :default/titlebar/minimize_normal.png)
   :ontop-button-focus-active (.. themes-path
                                  :default/titlebar/ontop_focus_active.png)
   :ontop-button-focus-inactive (.. themes-path
                                    :default/titlebar/ontop_focus_inactive.png)
   :ontop-button-normal-active (.. themes-path
                                   :default/titlebar/ontop_normal_active.png)
   :ontop-button-normal-inactive (.. themes-path
                                     :default/titlebar/ontop_normal_inactive.png)
   :sticky-button-focus-active (.. themes-path
                                   :default/titlebar/sticky_focus_active.png)
   :sticky-button-focus-inactive (.. themes-path
                                     :default/titlebar/sticky_focus_inactive.png)
   :sticky-button-normal-active (.. themes-path
                                    :default/titlebar/sticky_normal_active.png)
   :sticky-button-normal-inactive (.. themes-path
                                      :default/titlebar/sticky_normal_inactive.png)})

