(require-macros :macros)
(local gobject (require :gears.object))
(local gtimer (require :gears.timer))
(local spawn (require :awful.spawn))
(local lgi (require :lgi))

(fn capi? [object]
  (each [_ v (pairs _G.capi)]
    (when (= object v)
      (lua "return true")))
  false)

(fn function? [object]
  (= (type object) :function))

(local Variable {:mt {}})

(fn Variable.mt.__tostring [self]
  (string.format "Variable<%s>" (self:get_value)))

(fn Variable.get [self]
  self._private.value)

(fn Variable.set [self new-value]
  (when (not= self.value new-value)
    (set self._private.value new-value)
    (self:emit_signal "property::value" new-value)))

(set Variable.set_value Variable.set)
(set Variable.get_value Variable.get)

(fn Variable.subscribe [self callback]
  (let [signal "property::value"
        cb #(callback (self:get_value))]
    (self:connect_signal signal cb)
    #(self:disconnect_signal signal cb)))

(fn Variable.polling? [self] (not= self._private.poll nil))

(fn Variable.stop-poll [self]
  (when (self:polling?)
    (self._private.poll:stop)
    (set self._private.poll nil)))

(fn Variable.start-poll [self]
  (when (self:polling?) (lua :return))
  (let [{: poll_interval : poll_fn : poll_exec : poll_transform} self._private
        timeout poll_interval
        t poll_transform]
    (local callback
           (if ;
               poll_fn
               #(self:set_value (poll_fn (self:get_value)))
               poll_exec
               #(spawn.easy_async_with_shell poll_exec
                                             #(set! self (t $ (get! self))))))
    (set self._private.poll
         (gtimer {: timeout
                  :autostart true
                  :call_now true
                  :callback (λ []
                              (callback)
                              true)})))
  self)

(fn Variable.poll [self interval exec ?transform]
  (self:stop-poll)
  (set self._private.poll_interval (/ interval 1000))
  (set self._private.poll_transform (if ?transform ?transform #$))
  (if (function? exec)
      (do
        (set self._private.poll_fn exec)
        (set self._private.poll_exec nil))
      (do
        (set self._private.poll_fn nil)
        (set self._private.poll_exec exec)))
  (self:start-poll)
  self)

(fn Variable.drop [self] (self:emit_signal :dropped)
  (self:stop-poll))

(fn Variable.observe [self gobject signal callback]
  (let [is-capi? (capi? gobject)
        cb #(self:set_value (callback $...))]
    (if is-capi?
        (do
          (gobject.connect_signal signal cb)
          (self:connect_signal :dropped #(gobject.disconnect_signal signal cb)))
        (do
          (gobject:connect_signal signal cb)
          (self:connect_signal :dropped #(gobject:disconnect_signal signal cb))))
    self))

(fn new [value]
  (let [ret (gobject {:enable_properties true :class Variable})]
    (rawset ret :_private {})
    (rawset ret :is_variable true)
    (let [mt (getmetatable ret)]
      (set mt.__tostring Variable.mt.__tostring))
    (set ret._private.value value)
    ret))

(fn Variable.mt.__call [_ ...]
  (new ...))

(setmetatable Variable Variable.mt)

