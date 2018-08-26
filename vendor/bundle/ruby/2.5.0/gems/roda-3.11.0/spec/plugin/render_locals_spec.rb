require_relative "../spec_helper"

begin
  require 'tilt/erb'
rescue LoadError
  warn "tilt not installed, skipping render_locals plugin test"  
else
describe "render_locals plugin with :merge option" do
  before do
    app(:bare) do
      plugin :render_locals, :render=>{:a=>1, :b=>2, :c=>3, :d=>4, :e=>5}, :layout=>{:a=>-1, :f=>6}, :merge=>true
      plugin :render, :views=>"./spec/views", :check_paths=>true, :layout_opts=>{:inline=>'<%= a %>|<%= b %>|<%= c %>|<%= d %>|<%= e %>|<%= f %>|<%= yield %>'}

      route do |r|
        r.on "base" do
          view(:inline=>'(<%= a %>|<%= b %>|<%= c %>|<%= d %>|<%= e %>)')
        end
        r.on "override" do
          view(:inline=>'(<%= a %>|<%= b %>|<%= c %>|<%= d %>|<%= e %>)', :locals=>{:b=>-2, :d=>-4, :f=>-6}, :layout_opts=>{:locals=>{:d=>0, :c=>-3, :e=>-5}})
        end
        r.on "no_merge" do
          view(:inline=>'(<%= a %>|<%= b %>|<%= c %>|<%= d %>|<%= e %>)', :locals=>{:b=>-2, :d=>-4, :f=>-6}, :layout_opts=>{:merge_locals=>false, :locals=>{:d=>0, :c=>-3, :e=>-5}})
        end
      end
    end
  end

  it "should choose method opts before plugin opts, and layout specific before locals" do
    body("/base").must_equal '-1|2|3|4|5|6|(1|2|3|4|5)'
    body("/override").must_equal '-1|-2|-3|0|-5|-6|(1|-2|3|-4|5)'
    body("/no_merge").must_equal '-1|2|-3|0|-5|6|(1|-2|3|-4|5)'
  end
end

describe "render_locals plugin" do
  it "locals overrides" do
    app(:bare) do
      plugin :render, :views=>"./spec/views", :layout_opts=>{:template=>'multiple-layout'}
      plugin :render_locals, :render=>{:title=>'Home', :b=>'B'}, :layout=>{:title=>'Roda', :a=>'A'}
      
      route do |r|
        view("multiple", :locals=>{:b=>"BB"}, :layout_opts=>{:locals=>{:a=>'AA'}})
      end
    end

    body.strip.must_equal "Roda:AA::Home:BB"
  end

  it ":layout=>true/false/string/hash/not-present respects plugin layout switch and template" do
    app(:bare) do
      plugin :render, :views=>"./spec/views", :layout_opts=>{:template=>'layout-yield'}
      plugin :render_locals, :layout=>{:title=>'a'}
      
      route do |r|
        opts = {:content=>'bar'}
        opts[:layout] = true if r.path == '/'
        opts[:layout] = false if r.path == '/f'
        opts[:layout] = 'layout' if r.path == '/s'
        opts[:layout] = {:template=>'layout'} if r.path == '/h'
        view(opts)
      end
    end

    body.gsub("\n", '').must_equal "HeaderbarFooter"
    body('/a').gsub("\n", '').must_equal "HeaderbarFooter"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render
    body.gsub("\n", '').must_equal "HeaderbarFooter"
    body('/a').gsub("\n", '').must_equal "HeaderbarFooter"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render, :layout=>true
    body.gsub("\n", '').must_equal "HeaderbarFooter"
    body('/a').gsub("\n", '').must_equal "HeaderbarFooter"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render, :layout=>'layout-alternative'
    body.gsub("\n", '').must_equal "<title>Alternative Layout: a</title>bar"
    body('/a').gsub("\n", '').must_equal "<title>Alternative Layout: a</title>bar"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render, :layout=>nil
    body.gsub("\n", '').must_equal "HeaderbarFooter"
    body('/a').gsub("\n", '').must_equal "bar"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render, :layout=>false
    body.gsub("\n", '').must_equal "HeaderbarFooter"
    body('/a').gsub("\n", '').must_equal "bar"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"

    app.plugin :render, :layout_opts=>{:template=>'layout-alternative'}
    app.plugin :render_locals, :layout=>{:title=>'a'}
    body.gsub("\n", '').must_equal "<title>Alternative Layout: a</title>bar"
    body('/a').gsub("\n", '').must_equal "bar"
    body('/f').gsub("\n", '').must_equal "bar"
    body('/s').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
    body('/h').gsub("\n", '').must_equal "<title>Roda: a</title>bar"
  end
end
end
