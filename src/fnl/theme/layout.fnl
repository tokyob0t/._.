(local gfs (require :gears.filesystem))

(let [themes-dir (gfs.get_themes_dir)
      layouts [:fairh
               :fairv
               :floating
               :magnifier
               :max
               :fullscreen
               :tilebottom
               :tileleft
               :tile
               :tiletop
               :spiral
               :dwindle
               :cornernw
               :cornerne
               :cornersw
               :cornerse]]
  (collect [_ v (ipairs layouts)]
    (values v (.. themes-dir :default/layouts/ v :w.png))))

