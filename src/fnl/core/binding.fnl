(require-macros :macros)

(local gtable (require :gears.table))

(local Binding {:source nil :property nil})

(fn Binding.__tostring [self]
  (var str (.. :Binding< (tostring self.source)))
  (when self.property
    (set str (.. str ", " self.property)))
  (.. str ">"))

(fn Binding.new [source ...]
  (let [property (let [prop (select 1 ...)]
                   (when (= (type prop) :string)
                     prop))
        args [(select (if property 2 1) ...)]]
    (var binding (-> {: source : property :transform_fn #$}
                     (setmetatable Binding)
                     (gtable.crush Binding)))
    (each [_ f (ipairs args)]
      (set binding (binding:as f)))
    binding))

(fn Binding.get [self]
  (self.transform_fn (let [{: source : property} self]
                       (if property (. source property)
                           source.is_variable (get! source)))))

(fn Binding.as [self transform]
  (let [b (Binding.new self.source self.property)]
    (set b.transform_fn #(transform (self.transform_fn $)))
    b))

(fn Binding.subscribe [self callback]
  (let [{: source : property} self]
    (if property
        (let [signal (.. "property::" property)
              cb #(callback (self:get))]
          (source:connect_signal signal cb)
          #(source:disconnect_signal cb))
        source.subscribe
        (source:subscribe #(callback (self:get))))))

(fn Binding.type-of? [self object]
  (and (= (type object) :table) (= (getmetatable object) self)))

(setmetatable Binding {:__call (fn [_ ...]
                                 (Binding.new ...))})

