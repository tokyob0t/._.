;; gearsify.fnl
;; https://gist.github.com/tokyob0t/2f7c8047536956f70ec83c07183f4846
;; transpiled using antifennel https://git.sr.ht/~technomancy/antifennel

(local gobject (require :gears.object))
(local gtable (require :gears.table))
(local GObject ((. (require :lgi) :require) :GObject :2.0))
(local gearsified {:mt {}})
(set gearsified.__type :Gearsified)
(fn gearsified.mt.__index [self key]
  (when (. gobject key)
    (let [___antifnl_rtn_1___ (. gobject key)]
      (lua "return ___antifnl_rtn_1___")))
  (when (rawget self key)
    (let [___antifnl_rtns_1___ [(rawget self key)]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  (local object (rawget self._private :object))
  (set-forcibly! key (string.gsub key "-" "_"))
  (when (self:is_method key)
    (local m (. object key))
    (let [___antifnl_rtn_1___ (fn [_ ...] (m object ...))]
      (lua "return ___antifnl_rtn_1___")))
  (when (self:is_function key)
    (local f (. object key))
    (let [___antifnl_rtn_1___ (fn [...] (f ...))]
      (lua "return ___antifnl_rtn_1___")))
  (when (self:is_something key)
    (let [___antifnl_rtn_1___ (. object key)]
      (lua "return ___antifnl_rtn_1___")))
  nil)
(fn gearsified.mt.__newindex [self key value]
  (let [object self._private.object]
    (set-forcibly! key (string.gsub key "-" "_"))
    (when (self:is_property key) (tset object key value))
    (when (self:is_something key) (tset object key value))))
(fn gearsified.mt.__tostring [self]
  (.. :gearsified.object< (tostring self._private.object) ">"))
(fn gearsified.is_method [self name]
  (let [(ok result) (pcall (fn []
                             (and (. self._private.object name)
                                  (= (: (tostring (. self._private.object name))
                                        :sub 1 7)
                                     :lgi.fun))))]
    (and ok result)))
(fn gearsified.is_function [self name]
  (let [(ok result) (pcall (fn []
                             (and (. self._private.object name)
                                  (= (type (. self._private.object name))
                                     :function))))]
    (and ok result)))
(fn gearsified.is_property [self name]
  (let [(ok result) (pcall (fn []
                             (not= (. self._private.object._property name) nil)))]
    (and ok result)))
(fn gearsified.is_something [self name]
  (let [(ok result) (pcall (fn [] (not= (. self._private.object name) nil)))]
    (and ok result)))
(fn gearsified.dispose [self]
  (each [_ id (pairs self._private.unsubs)]
    (GObject.signal_handler_disconnect self._private.object id))
  (set self._private.object nil))
(fn gearsified.connect_signal [self name func]
  (let [object self._private.object
        key (: (tostring func) :gsub "function: " "")]
    (var id nil)
    (if (= (string.sub name 1 10) "property::")
        (let [prop (string.gsub name "property::" "")]
          (set id (object.on_notify:connect (fn [] (func self (. object prop)))
                                            prop false)))
        (set id (: (. object (.. :on_ name)) :connect
                   (fn [_ ...] (func self ...)))))
    (tset self._private.unsubs key id)))
(fn gearsified.disconnect_signal [self _ func]
  (let [key (: (tostring func) :gsub "function: " "")
        id (. self._private.unsubs key)]
    (GObject.signal_handler_disconnect self._private.object id)))
(setmetatable gearsified gearsified.mt)
(local cache {})
(fn [object]
  (when (or (not gobject) (not (GObject.Object:is_type_of object)))
    (let [___antifnl_rtns_1___ [(error (debug.traceback (.. (tostring object)
                                                            " is not a GObject.Object")))]]
      (lua "return (table.unpack or _G.unpack)(___antifnl_rtns_1___)")))
  (local ret (gobject {}))
  (local id (: (tostring object) :gsub "lgi.obj " ""))
  (when (. cache id)
    (let [___antifnl_rtn_1___ (. cache id)] (lua "return ___antifnl_rtn_1___")))
  (rawset ret :_private {})
  (set ret._private.object object)
  (set ret._private.unsubs {})
  (gtable.crush ret gearsified true)
  (setmetatable ret gearsified.mt)
  (tset cache id ret)
  ret)	
