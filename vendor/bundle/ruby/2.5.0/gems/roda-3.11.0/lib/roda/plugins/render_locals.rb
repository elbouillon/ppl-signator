# frozen-string-literal: true

#
class Roda
  module RodaPlugins
    # The render_locals plugin allows setting default locals for rendering templates.
    #
    #   plugin :render_locals, render: {heading: 'Hello'}
    #
    #   route do |r|
    #     r.get "foo" do
    #       view 'foo', locals: {name: 'Foo'} # locals: {:heading=>'Hello', :name=>'Foo'}
    #     end
    #
    #     r.get "bar" do
    #       view 'foo', locals: {heading: 'Bar'} # locals: {:heading=>'Bar'}
    #     end
    #
    #     view "default" # locals: {:heading=>'Hello'}
    #   end
    #
    # The render_locals plugin accepts the following options:
    #
    # render :: The default locals to use for template rendering
    # layout :: The default locals to use for layout rendering
    # merge :: Whether to merge template locals into layout locals
    module RenderLocals
      def self.load_dependencies(app, opts=OPTS)
        app.plugin :render
      end

      def self.configure(app, opts=OPTS)
        app.opts[:render_locals] = (app.opts[:render_locals] || {}).merge(opts[:render]||{}).freeze
        app.opts[:layout_locals] = (app.opts[:layout_locals] || {}).merge(opts[:layout]||{}).freeze
        if opts.has_key?(:merge)
          app.opts[:merge_locals] = opts[:merge]
          app.opts[:layout_locals] = app.opts[:render_locals].merge(app.opts[:layout_locals]).freeze
        end
      end

      module InstanceMethods
        private

        def render_locals
          opts[:render_locals]
        end

        def layout_locals
          opts[:layout_locals]
        end

        # If this isn't the layout template, then use the plugin's render locals as the default locals.
        def render_template_opts(template, opts)
          opts = super
          return opts if opts[:_is_layout]

          plugin_locals = render_locals
          if locals = opts[:locals]
            plugin_locals = Hash[plugin_locals].merge!(locals)
          end
          opts[:locals] = plugin_locals
          opts
        end

        # If using a layout, then use the plugin's layout locals as the default locals.
        def view_layout_opts(opts)
          if layout_opts = super
            merge_locals = layout_opts.has_key?(:merge_locals) ? layout_opts[:merge_locals] : self.opts[:merge_locals] 

            locals = {}
            locals.merge!(layout_locals)
            if merge_locals && (method_locals = opts[:locals])
              locals.merge!(method_locals)
            end
            if method_layout_locals = layout_opts[:locals]
              locals.merge!(method_layout_locals)
            end

            layout_opts[:locals] = locals
            layout_opts
          end
        end
      end
    end

    register_plugin(:render_locals, RenderLocals)
  end
end
