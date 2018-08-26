# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The middleware_stack plugin adds methods to remove middleware
    # from the middleware stack, and insert new middleware at specific
    # positions in the middleware stack.
    #
    #   plugin :middleware_stack
    #
    #   # Remove csrf middleware
    #   middleware_stack.remove{|m, *args| m == Rack::Csrf}
    #
    #   # Insert csrf middleware
    #   middleware_stack.before{|m, *args| m == Rack::CommonLogger}.use(Rack::Csrf, raise: true)
    #   middleware_stack.after{|m, *args| m == Rack::CommonLogger}.use(Rack::Csrf, raise: true)
    module MiddlewareStack
      # Represents a specific position in the application's middleware stack where new
      # middleware can be inserted.
      class StackPosition
        def initialize(app, middleware, position)
          @app = app
          @middleware = middleware
          @position = position
        end

        # Insert a new middleware into the current position in the middleware stack.
        # Increments the position so that calling this multiple times adds later
        # middleware after earlier middleware, similar to how +Roda.use+ works.
        def use(*args, &block)
          @middleware.insert(@position, [args, block])
          @app.send(:build_rack_app)
          @position += 1
          nil
        end
      end

      # Represents the applications middleware as a stack, allowing for easily
      # removing middleware or finding places to insert new middleware.
      class Stack
        def initialize(app, middleware)
          @app = app
          @middleware = middleware
        end

        # Return a StackPosition representing the position after the middleware where
        # the block returns true. Yields the middleware and any middleware arguments
        # given, but not the middleware block.
        # It the block never returns true, returns a StackPosition that will insert
        # new middleware at the end of the stack.
        def after(&block)
          handle(1, &block)
        end

        # Return a StackPosition representing the position before the middleware where
        # the block returns true. Yields the middleware and any middleware arguments
        # given, but not the middleware block.
        # It the block never returns true, returns a StackPosition that will insert
        # new middleware at the end of the stack.
        def before(&block)
          handle(0, &block)
        end

        # Removes any middleware where the block returns true. Yields the middleware
        # and any middleware arguments given, but not the middleware block
        def remove
          @middleware.delete_if do |m, _|
            yield(*m)
          end
          @app.send(:build_rack_app)
          nil
        end

        private

        # Internals of before and after.
        def handle(offset)
          @middleware.each_with_index do |(m, _), i|
            if yield(*m)
              return StackPosition.new(@app, @middleware, i+offset)
            end
          end

          StackPosition.new(@app, @middleware, @middleware.length)
        end
      end

      module ClassMethods
        # Return a new Stack that allows removing middleware and inserting
        # middleware at specific places in the stack.
        def middleware_stack
          Stack.new(self, @middleware)
        end
      end
    end

    register_plugin(:middleware_stack, MiddlewareStack)
  end
end

