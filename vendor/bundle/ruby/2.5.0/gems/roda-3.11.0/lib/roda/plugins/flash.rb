# frozen-string-literal: true

require 'delegate'

class Roda
  module RodaPlugins
    # The flash plugin adds a +flash+ instance method to Roda,
    # for typical web application flash handling, where values
    # set in the current flash hash are available in the next
    # request.
    #
    # With the example below, if a POST request is submitted,
    # it will redirect and the resulting GET request will
    # return 'b'.
    #
    #   plugin :flash
    #
    #   route do |r|
    #     r.is '' do
    #       r.get do
    #         flash['a']
    #       end
    #
    #       r.post do
    #         flash['a'] = 'b'
    #         r.redirect('')
    #       end
    #     end
    #   end
    #
    # You can modify the flash for the current request (instead of
    # the next request) by using the +flash.now+ method:
    #
    #   r.get do
    #     flash.now['a'] = 'b'
    #     flash['a'] # = >'b'
    #   end
    module Flash
      def self.load_dependencies(app)
        app.plugin :_after_hook
      end

      # Simple flash hash, where assiging to the hash updates the flash
      # used in the following request.
      class FlashHash < DelegateClass(Hash)
        # The flash hash for the next request.  This
        # is what gets written to by #[]=.
        attr_reader :next 

        # The flash hash for the current request
        alias now __getobj__

        # Setup the next hash when initializing, and handle treat nil
        # as a new empty hash.
        def initialize(hash={})
          super(hash||{})
          @next = {}
        end

        # Update the next hash with the given key and value.
        def []=(k, v)
          @next[k] = v
        end

        # Remove given key from the next hash, or clear the next hash if
        # no argument is given.
        def discard(key=(no_arg=true))
          if no_arg
            @next.clear
          else
            @next.delete(key)
          end
        end

        # Copy the entry with the given key from the current hash to the
        # next hash, or copy all entries from the current hash to the
        # next hash if no argument is given.
        def keep(key=(no_arg=true))
          if no_arg
            @next.merge!(self)
          else
            self[key] = self[key]
          end
        end

        # Replace the current hash with the next hash and clear the next hash.
        def sweep
          replace(@next)
          @next.clear
          self
        end
      end

      module InstanceMethods
        # Access the flash hash for the current request, loading
        # it from the session if it is not already loaded.
        def flash
          # :_flash to support transparent upgrades from previous key
          @_flash ||= FlashHash.new(session['_flash'] || (session['_flash'] = session.delete(:_flash)))
        end

        private

        # If the routing doesn't raise an error, rotate the flash
        # hash in the session so the next request has access to it.
        def _roda_after_40(_)
          if f = @_flash
            f = f.next
            if f.empty?
              session.delete('_flash')
            else
              session['_flash'] = f
            end
          end
        end
      end
    end

    register_plugin(:flash, Flash)
  end
end
