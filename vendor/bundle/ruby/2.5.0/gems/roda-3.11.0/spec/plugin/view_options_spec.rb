require_relative "../spec_helper"

begin
  require 'tilt/erb'
rescue LoadError
  warn "tilt not installed, skipping view_options plugin test"  
else
describe "view_options plugin view subdirs" do
  before do
    app(:bare) do
      plugin :render, :views=>"."
      plugin :view_options

      route do |r|
        append_view_subdir 'spec' 

        r.on "home" do
          set_view_subdir 'spec/views'
          view("home", :locals=>{:name => "Agent Smith", :title => "Home"}, :layout_opts=>{:locals=>{:title=>"Home"}})
        end

        r.on "about" do
          append_view_subdir 'views'
          render("about", :locals=>{:title => "About Roda"})
        end

        r.on "path" do
          render('spec/views/about', :locals=>{:title => "Path"}, :layout_opts=>{:locals=>{:title=>"Home"}})
        end
      end
    end
  end

  it "should use set subdir if template name does not contain a slash" do
    body("/home").strip.must_equal "<title>Roda: Home</title>\n<h1>Home</h1>\n<p>Hello Agent Smith</p>"
  end

  it "should not use set subdir if template name contains a slash" do
    body("/about").strip.must_equal "<h1>About Roda</h1>"
  end

  it "should not change behavior when subdir is not set" do
    body("/path").strip.must_equal "<h1>Path</h1>"
  end
end

describe "view_options plugin" do
  it "should not use :views view option for layout" do
    app(:bare) do
      plugin :render, :views=>'spec/views', :allowed_paths=>['spec/views']
      plugin :view_options

      route do
        set_view_options :views=>'spec/views/about'
        set_layout_options :template=>'layout-alternative'
        view('_test', :locals=>{:title=>'About Roda'}, :layout_opts=>{:locals=>{:title=>'Home'}})
      end
    end

    body.strip.must_equal "<title>Alternative Layout: Home</title>\n<h1>Subdir: About Roda</h1>"
  end

  it "should set view and layout options to use" do
    app(:bare) do
      plugin :render, :allowed_paths=>['spec/views']
      plugin :view_options
      plugin :render_locals, :render=>{:title=>'About Roda'}, :layout=>{:title=>'Home'}

      route do
        set_view_options :views=>'spec/views'
        set_layout_options :views=>'spec/views', :template=>'layout-alternative'
        view('about')
      end
    end

    body.strip.must_equal "<title>Alternative Layout: Home</title>\n<h1>About Roda</h1>"
  end

  it "should merge multiple calls to set view and layout options" do
    app(:bare) do
      plugin :render, :allowed_paths=>['spec/views']
      plugin :view_options
      plugin :render_locals, :render=>{:title=>'Home', :b=>'B'}, :layout=>{:title=>'About Roda', :a=>'A'}

      route do
        set_layout_options :views=>'spec/views', :template=>'multiple-layout', :engine=>'str'
        set_view_options :views=>'spec/views', :engine=>'str'

        set_layout_options :engine=>'erb'
        set_view_options :engine=>'erb'

        view('multiple')
      end
    end

    body.strip.must_equal "About Roda:A::Home:B"
  end
end
end
