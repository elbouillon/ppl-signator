# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The class_matchers plugin allows you do define custom regexps and
    # conversion procs to use for specific classes.  For example, if you
    # have multiple routes similar to:
    #
    #   r.on /(\d\d\d\d)-(\d\d)-(\d\d)/ do |y, m, d|
    #     date = Date.new(y.to_i, m.to_i, d.to_i)
    #     # ...
    #   end
    #
    # You can register a Date class matcher for that regexp (note that
    # the block must return an array):
    #
    #   class_matcher(Date, /(\d\d\d\d)-(\d\d)-(\d\d)/) do |y, m, d|
    #     [Date.new(y.to_i, m.to_i, d.to_i)]
    #   end
    #
    # And then use the Date class as a matcher, and it will yield a Date object:
    #
    #   r.on Date do |date|
    #     # ...
    #   end
    #
    # This is useful to DRY up code if you are using the same type of pattern and
    # type conversion in multiple places in your application.
    #
    # This plugin does not work with the params_capturing plugin, as it does not
    # offer the ability to associate block arguments with named keys.
    module ClassMatchers
      module ClassMethods
        # Set the regexp to use for the given class.  The block given will be
        # called with all matched values from the regexp, and should return an
        # array with the captures to yield to the match block.
        def class_matcher(klass, re, &block)
          meth = :"_match_class_#{klass}"
          self::RodaRequest.class_eval do
            consume_re = consume_pattern(re)
            define_method(meth){consume(consume_re, &block)}
            private meth
          end
        end
      end
    end

    register_plugin(:class_matchers, ClassMatchers)
  end
end
