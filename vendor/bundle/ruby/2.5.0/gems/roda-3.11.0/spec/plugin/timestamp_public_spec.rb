require_relative "../spec_helper"

describe "timestamp_public plugin" do 
  it "adds r.timestamp_public for serving static files from timestamp_public folder" do
    app(:bare) do
      plugin :timestamp_public, :root=>'spec/views'

      route do |r|
        r.timestamp_public
      end
    end

    status("/about/_test.erb\0").must_equal 404
    status("/about/_test.erb").must_equal 404
    status("/static/a/about/_test.erb").must_equal 404
    status("/static/1/about/_test.erb\0").must_equal 404
    body("/static/1/about/_test.erb").must_equal File.read('spec/views/about/_test.erb')
  end

  it "adds r.timestamp_public for serving static files from timestamp_public folder" do
    app(:bare) do
      plugin :timestamp_public, :root=>'spec/views', :prefix=>'foo'

      route do |r|
        r.timestamp_public
      end
    end

    body("/foo/1/about/_test.erb").must_equal File.read('spec/views/about/_test.erb')
  end

  it "adds r.timestamp_public for serving static files from timestamp_public folder" do
    app(:bare) do
      plugin :timestamp_public, :root=>'spec/plugin'
      
      route do |r|
        r.timestamp_public
        timestamp_path('../views/about/_test.erb')
      end
    end

    mtime = File.mtime('spec/views/about/_test.erb')
    body.must_equal "/static/#{sprintf("%i%06i", mtime.to_i, mtime.usec)}/../views/about/_test.erb"
    status("/static/1/../views/about/_test.erb").must_equal 404
  end

  it "respects the application's :root option" do
    app(:bare) do
      opts[:root] = File.expand_path('../../', __FILE__)
      plugin :timestamp_public, :root=>'views'

      route do |r|
        r.timestamp_public
      end
    end

    body('/static/1/about/_test.erb').must_equal File.read('spec/views/about/_test.erb')
  end

  it "handles serving gzip files in gzip mode if client supports gzip" do
    app(:bare) do
      plugin :timestamp_public, :root=>'spec/views', :gzip=>true

      route do |r|
        r.timestamp_public
      end
    end

    body('/static/1/about/_test.erb').must_equal File.read('spec/views/about/_test.erb')
    header('Content-Encoding', '/about/_test.erb').must_be_nil

    body('/static/1/about.erb').must_equal File.read('spec/views/about.erb')
    header('Content-Encoding', '/about.erb').must_be_nil

    body('/static/1/about/_test.erb', 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip').must_equal File.binread('spec/views/about/_test.erb.gz')
    h = req('/static/1/about/_test.erb', 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip')[1]
    h['Content-Encoding'].must_equal 'gzip'
    h['Content-Type'].must_equal 'text/plain'

    body('/static/1/about/_test.css', 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip').must_equal File.binread('spec/views/about/_test.css.gz')
    h = req('/static/1/about/_test.css', 'HTTP_ACCEPT_ENCODING'=>'deflate, gzip')[1]
    h['Content-Encoding'].must_equal 'gzip'
    h['Content-Type'].must_equal 'text/css'
  end
end
