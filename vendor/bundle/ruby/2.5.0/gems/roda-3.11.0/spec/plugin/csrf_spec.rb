require_relative "../spec_helper"

begin
  require 'rack/csrf'
rescue LoadError
  warn "rack_csrf not installed, skipping csrf plugin test"  
else
describe "csrf plugin" do 
  include CookieJar

  it "adds csrf protection and csrf helper methods" do
    app(:bare) do
      use(*DEFAULT_SESSION_MIDDLEWARE_ARGS)
      plugin :csrf, :skip=>['POST:/foo']

      route do |r|
        r.get do
          response['TAG'] = csrf_tag
          response['METATAG'] = csrf_metatag
          response['TOKEN'] = csrf_token
          response['FIELD'] = csrf_field
          response['HEADER'] = csrf_header
          'g'
        end
        r.post 'foo' do
          'bar'
        end
        r.post do
          'p'
        end
      end
    end

    io = StringIO.new
    status('REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 403
    body('/foo', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 'bar'

    s, h, b = req
    s.must_equal 200
    field = h['FIELD']
    token = Regexp.escape(h['TOKEN'])
    h['TAG'].must_match(/\A<input type="hidden" name="#{field}" value="#{token}" \/>\z/)
    h['METATAG'].must_match(/\A<meta name="#{field}" content="#{token}" \/>\z/)
    b.must_equal ['g']
    s, _, b = req('REQUEST_METHOD'=>'POST', 'rack.input'=>io, "HTTP_#{h['HEADER']}"=>h['TOKEN'])
    s.must_equal 200
    b.must_equal ['p']

    app.plugin :csrf
    body('/foo', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 'bar'
  end

  it "can optionally skip setting up the middleware" do
    sub_app = Class.new(Roda)
    sub_app.class_eval do
      plugin :csrf, :skip_middleware=>true

      route do |r|
        r.get do
          response['TAG'] = csrf_tag
          response['METATAG'] = csrf_metatag
          response['TOKEN'] = csrf_token
          response['FIELD'] = csrf_field
          response['HEADER'] = csrf_header
          'g'
        end
        r.post 'bar' do
          'foobar'
        end
        r.post do
          'p'
        end
      end
    end

    app(:bare) do
      use(*DEFAULT_SESSION_MIDDLEWARE_ARGS)
      plugin :csrf, :skip=>['POST:/foo/bar']

      route do |r|
        r.on 'foo' do
          r.run sub_app
        end
      end
    end

    io = StringIO.new
    status('/foo', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 403
    body('/foo/bar', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 'foobar'

    s, h, b = req('/foo')
    s.must_equal 200
    field = h['FIELD']
    token = Regexp.escape(h['TOKEN'])
    h['TAG'].must_match(/\A<input type="hidden" name="#{field}" value="#{token}" \/>\z/)
    h['METATAG'].must_match(/\A<meta name="#{field}" content="#{token}" \/>\z/)
    b.must_equal ['g']
    s, _, b = req('/foo', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io, "HTTP_#{h['HEADER']}"=>h['TOKEN'])
    s.must_equal 200
    b.must_equal ['p']

    sub_app.plugin :csrf, :skip_middleware=>true
    body('/foo/bar', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io).must_equal 'foobar'

    @app = sub_app
    s, _, b = req('/bar', 'REQUEST_METHOD'=>'POST', 'rack.input'=>io)
    s.must_equal 200
    b.must_equal ['foobar']
  end
end
end
