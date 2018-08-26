# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The streaming plugin adds support for streaming responses
    # from roda using the +stream+ method:
    #
    #   plugin :streaming
    #
    #   route do |r|
    #     stream do |out|
    #       ['a', 'b', 'c'].each{|v| out << v; sleep 1}
    #     end
    #   end
    #
    # In order for streaming to work, any webservers used in
    # front of the roda app must not buffer responses.
    #
    # The stream method takes the following options:
    #
    # :callback :: A callback proc to call when the connection is closed.
    # :loop :: Whether to call the stream block continuously until the connection is closed.
    #
    # If the :loop option is used, you can override the
    # handle_stream_error method to change how exceptions
    # are handled during streaming. This method is passed the
    # exception and the stream.  By default, this method
    # just reraises the exception, but you can choose to output
    # the an error message to the stream, before raising:
    #
    #   def handle_stream_error(e, out)
    #     out << 'ERROR!'
    #     raise e
    #   end
    #
    # Ignore errors completely while streaming:
    #
    #   def handle_stream_error(e, out)
    #   end
    #
    # or handle the errors in some other way.
    module Streaming
      # Class of the response body in case you use #stream.
      class Stream
        include Enumerable

        # Handle streaming options, see Streaming for details.
        def initialize(opts=OPTS, &block)
          @block = block
          @out = nil
          @callback = opts[:callback]
          @closed = false
        end

        # Add output to the streaming response body.
        def write(data)
          @out.call(data.to_s)
          self
        end
        alias << write

        # If not already closed, close the connection, and call
        # any callbacks.
        def close
          return if closed?
          @closed = true
          @callback.call if @callback
        end

        # Whether the connection has already been closed.
        def closed?
          @closed
        end

        # Yield values to the block as they are passed in via #<<.
        def each(&out)
          @out = out
          @block.call(self)
        ensure
          close
        end
      end

      module InstanceMethods
        # Immediately return a streaming response using the current response
        # status and headers, calling the block to get the streaming response.
        # See Streaming for details.
        def stream(opts=OPTS, &block)
          if opts[:loop]
            block = proc do |out|
              until out.closed?
                begin
                  yield(out)
                rescue => e
                  handle_stream_error(e, out)
                end
              end
            end
          end

          throw :halt, @_response.finish_with_body(Stream.new(opts, &block))
        end

        # Handle exceptions raised while streaming when using :loop
        def handle_stream_error(e, out)
          raise e
        end
      end
    end

    register_plugin(:streaming, Streaming)
  end
end
