(local awful (require :awful))
(local menubar (require :menubar))
(local bful (require :beautiful))

(global terminal :ghostty)
(global editor :nvim)
(global editor-cmd (string.format "%s -e %s" terminal editor))

(global capi {: awesome
              : client
              : screen
              : tag
              : mouse
              : root
              : mousegrabber
              : selection
              : drawin
              : key
              : keygrabber})

(global myawesomemenu [[:manual (.. terminal " -e man awesome")]
                       ["edit config" (.. editor-cmd " " awesome.conffile)]
                       [:restart awesome.restart]
                       [:quit #(awesome.quit)]])

(global mymainmenu
        (awful.menu {:items [[:awesome myawesomemenu bful.awesome-icon]
                             ["open terminal" terminal]]}))

(global mylauncher
        (awful.widget.launcher {:image bful.awesome-icon :menu mymainmenu}))

(set menubar.utils.terminal terminal)

