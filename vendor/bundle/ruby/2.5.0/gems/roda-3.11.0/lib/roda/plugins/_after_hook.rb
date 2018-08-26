# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # Internal after hook module, not for external use.
    # Allows for plugins to configure the order in which
    # after processing is done by using _roda_after_*
    # private instance methods that are called in sorted order.
    module AfterHook # :nodoc:
      module ClassMethods
        # Rebuild the _roda_after method whenever a plugin might
        # have added a _roda_after_* method.
        def include(*)
          res = super
          meths = private_instance_methods.grep(/\A_roda_after_\d\d\z/).sort.map{|s| "#{s}(res)"}.join(';')
          class_eval("def _roda_after(res); #{meths} end", __FILE__, __LINE__)
          private :_roda_after
          res
        end
      end

      module InstanceMethods
        # Run internal after hooks with the response
        def call
          res = super
        ensure
          _roda_after(res)
        end
      end
    end

    register_plugin(:_after_hook, AfterHook)
  end
end
