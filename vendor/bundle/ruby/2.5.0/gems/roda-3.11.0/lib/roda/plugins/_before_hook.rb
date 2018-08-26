# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # Internal before hook module, not for external use.
    # Allows for plugins to configure the order in which
    # before processing is done by using _roda_before_*
    # private instance methods that are called in sorted order.
    module BeforeHook # :nodoc:
      # Rebuild the rack app if the rack app already exists,
      # so the before hooks are setup inside the rack app
      # route block.
      def self.configure(app)
        app.instance_exec do
          build_rack_app if @app
        end
      end

      module ClassMethods
        # Rebuild the _roda_before method whenever a plugin might
        # have added a _roda_before_* method.
        def include(*a)
          res = super
          def_roda_before
          res
        end

        private

        # Build a _roda_before method that calls each _roda_before_* method
        # in order.
        def def_roda_before
          meths = private_instance_methods.grep(/\A_roda_before_\d\d\z/).sort.join(';')
          class_eval("def _roda_before; #{meths} end", __FILE__, __LINE__)
          private :_roda_before
        end

        # Modify rack app route block to use before hook.
        def rack_app_route_block(block)
          lambda do |r|
            _roda_before
            instance_exec(r, &block)
          end
        end
      end
    end

    register_plugin(:_before_hook, BeforeHook)
  end
end
