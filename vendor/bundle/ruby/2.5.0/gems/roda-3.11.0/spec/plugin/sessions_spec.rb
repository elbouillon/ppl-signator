require_relative "../spec_helper"

if RUBY_VERSION >= '2'
describe "sessions plugin" do 
  include CookieJar

  def req(path, opts={})
    @errors ||= (errors = []; def errors.puts(s) self << s; end; errors)
    super(path, opts.merge('rack.errors'=>@errors))
  end

  def errors
    e = @errors.dup
    @errors.clear
    e
  end

  before do
    app(:bare) do
      plugin :sessions, :secret=>'1'*64
      route do |r|
        if r.GET['sut']
          session
          env['roda.session.updated_at'] -= r.GET['sut'].to_i if r.GET['sut']
        end
        r.get('s', String, String){|k, v| session[k] = v}
        r.get('g',  String){|k| session[k].to_s}
        r.get('sct'){|i| session; env['roda.session.created_at'].to_s}
        r.get('ssct', Integer){|i| session; (env['roda.session.created_at'] -= i).to_s}
        r.get('sc'){session.clear; 'c'}
        r.get('cs', String, String){|k, v| clear_session; session[k] = v}
        ''
      end
    end
  end

  it "requires appropriate :secret option" do
    proc{app(:bare){plugin :sessions}}.must_raise Roda::RodaError
    proc{app(:bare){plugin :sessions, :secret=>Object.new}}.must_raise Roda::RodaError
    proc{app(:bare){plugin :sessions, :secret=>'1'*63}}.must_raise Roda::RodaError
  end

  it "has session store data between requests" do
    req('/').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, [""]]
    body('/s/foo/bar').must_equal 'bar'
    body('/g/foo').must_equal 'bar'

    body('/s/foo/baz').must_equal 'baz'
    body('/g/foo').must_equal 'baz'

    body("/s/foo/\u1234").must_equal "\u1234"
    body("/g/foo").must_equal "\u1234"

    errors.must_equal []
  end

  it "does not add Set-Cookie header if session does not change, unless outside :skip_within seconds" do
    req('/').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"0"}, [""]]
    _, h, b = req('/s/foo/bar')
    h['Set-Cookie'].must_match(/\Aroda.session/)
    b.must_equal ["bar"]
    req('/g/foo').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"3"}, ["bar"]]
    req('/s/foo/bar').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"3"}, ["bar"]]

    _, h, b = req('/s/foo/baz')
    h['Set-Cookie'].must_match(/\Aroda.session/)
    b.must_equal ["baz"]
    req('/g/foo').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"3"}, ["baz"]]

    req('/g/foo', 'QUERY_STRING'=>'sut=3500').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"3"}, ["baz"]]
    _, h, b = req('/g/foo', 'QUERY_STRING'=>'sut=3700')
    h['Set-Cookie'].must_match(/\Aroda.session/)
    b.must_equal ["baz"]

    @app.plugin(:sessions, :skip_within=>3800)
    req('/g/foo', 'QUERY_STRING'=>'sut=3700').must_equal [200, {"Content-Type"=>"text/html", "Content-Length"=>"3"}, ["baz"]]
    _, h, b = req('/g/foo', 'QUERY_STRING'=>'sut=3900')
    h['Set-Cookie'].must_match(/\Aroda.session/)
    b.must_equal ["baz"]

    errors.must_equal []
  end

  it "removes session cookie when session is submitted but empty after request" do
    body('/s/foo/bar').must_equal 'bar'
    sct = body('/sct').to_i
    body('/g/foo').must_equal 'bar'

    _, h, b = req('/sc')
    h['Set-Cookie'].must_include "roda.session=; max-age=0; expires=Thu, 01 Jan 1970 00:00:00"
    b.must_equal ['c']

    errors.must_equal []
  end

  it "sets new session create time when clear_session is called even when session is not empty when serializing" do
    body('/s/foo/bar').must_equal 'bar'
    sct = body('/sct').to_i
    body('/g/foo').must_equal 'bar'
    body('/sct').to_i.must_equal sct
    body('/ssct/10').to_i.must_equal(sct - 10)

    body('/cs/foo/baz').must_equal 'baz'
    body('/sct').to_i.must_be :>=, sct

    errors.must_equal []
  end

  it "should include HttpOnly and secure cookie options appropriately" do
    h = header('Set-Cookie', '/s/foo/bar')
    h.must_include('; HttpOnly')
    h.wont_include('; secure')

    h = header('Set-Cookie', '/s/foo/baz', 'HTTPS'=>'on')
    h.must_include('; HttpOnly')
    h.must_include('; secure')

    @app.plugin(:sessions, :cookie_options=>{})
    h = header('Set-Cookie', '/s/foo/bar')
    h.must_include('; HttpOnly')
    h.wont_include('; secure')
  end

  it "should merge :cookie_options options into the default cookie options" do
    @app.plugin(:sessions, :cookie_options=>{:secure=>true})
    h = header('Set-Cookie', '/s/foo/bar')
    h.must_include('; HttpOnly')
    h.must_include('; path=/')
    h.must_include('; secure')
  end

  it "handles secret rotation using :old_secret option" do
    body('/s/foo/bar').must_equal 'bar'
    body('/g/foo').must_equal 'bar'

    old_cookie = @cookie
    @app.plugin(:sessions, :secret=>'2'*64, :old_secret=>'1'*64)
    body('/g/foo', 'QUERY_STRING'=>'sut=3700').must_equal 'bar'

    @app.plugin(:sessions, :secret=>'2'*64, :old_secret=>nil)
    body('/g/foo', 'QUERY_STRING'=>'sut=3700').must_equal 'bar'

    @cookie = old_cookie
    body('/g/foo').must_equal ''
    errors.must_equal ["Not decoding session: HMAC invalid"]

    proc{app(:bare){plugin :sessions, :old_secret=>'1'*63}}.must_raise Roda::RodaError
    proc{app(:bare){plugin :sessions, :old_secret=>Object.new}}.must_raise Roda::RodaError
  end

  it "pads data by default to make it more difficult to guess session contents based on size" do
    long = "bar"*35

    _, h1, b = req('/s/foo/bar')
    b.must_equal ['bar']
    _, h2, b = req('/s/foo/bar', 'QUERY_STRING'=>'sut=3700')
    b.must_equal ['bar']
    _, h3, b = req('/s/foo/bar2')
    b.must_equal ['bar2']
    _, h4, b = req("/s/foo/#{long}")
    b.must_equal [long]
    h1['Set-Cookie'].length.must_equal h2['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h2['Set-Cookie']
    h1['Set-Cookie'].length.must_equal h3['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h3['Set-Cookie']
    h1['Set-Cookie'].length.wont_equal h4['Set-Cookie'].length

    @app.plugin(:sessions, :pad_size=>256)

    _, h1, b = req('/s/foo/bar')
    b.must_equal ['bar']
    _, h2, b = req('/s/foo/bar', 'QUERY_STRING'=>'sut=3700')
    b.must_equal ['bar']
    _, h3, b = req('/s/foo/bar2')
    b.must_equal ['bar2']
    _, h4, b = req("/s/foo/#{long}")
    b.must_equal [long]
    h1['Set-Cookie'].length.must_equal h2['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h2['Set-Cookie']
    h1['Set-Cookie'].length.must_equal h3['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h3['Set-Cookie']
    h1['Set-Cookie'].length.must_equal h4['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h3['Set-Cookie']

    @app.plugin(:sessions, :pad_size=>nil)

    _, h1, b = req('/s/foo/bar')
    b.must_equal ['bar']
    _, h2, b = req('/s/foo/bar', 'QUERY_STRING'=>'sut=3700')
    b.must_equal ['bar']
    _, h3, b = req('/s/foo/bar2')
    b.must_equal ['bar2']
    h1['Set-Cookie'].length.must_equal h2['Set-Cookie'].length
    h1['Set-Cookie'].wont_equal h2['Set-Cookie']
    if !defined?(JRUBY_VERSION) || JRUBY_VERSION >= '9.2'
      h1['Set-Cookie'].length.wont_equal h3['Set-Cookie'].length
    end

    proc{@app.plugin(:sessions, :pad_size=>0)}.must_raise Roda::RodaError
    proc{@app.plugin(:sessions, :pad_size=>1)}.must_raise Roda::RodaError
    proc{@app.plugin(:sessions, :pad_size=>Object.new)}.must_raise Roda::RodaError

    errors.must_equal []
  end

  it "compresses data over a certain size by default" do
    long = 'b'*8192
    proc{body("/s/foo/#{long}")}.must_raise Roda::RodaPlugins::Sessions::CookieTooLarge

    @app.plugin(:sessions, :gzip_over=>8000)
    body("/s/foo/#{long}").must_equal long
    body("/g/foo", 'QUERY_STRING'=>'sut=3700').must_equal long

    @app.plugin(:sessions, :gzip_over=>15000)
    proc{body("/g/foo", 'QUERY_STRING'=>'sut=3700')}.must_raise Roda::RodaPlugins::Sessions::CookieTooLarge

    errors.must_equal []
  end

  it "raises CookieTooLarge if cookie is too large" do
    proc{req('/s/foo/'+Base64.urlsafe_encode64(SecureRandom.random_bytes(8192)))}.must_raise Roda::RodaPlugins::Sessions::CookieTooLarge
  end

  it "ignores session cookies if session exceeds max time since create" do
    body("/s/foo/bar").must_equal 'bar'
    body("/g/foo").must_equal 'bar'

    @app.plugin(:sessions, :max_seconds=>-1)
    body("/g/foo").must_equal ''
    errors.must_equal ["Not returning session: maximum session time expired"]

    @app.plugin(:sessions, :max_seconds=>10)
    body("/s/foo/bar").must_equal 'bar'
    body("/g/foo").must_equal 'bar'

    errors.must_equal []
  end

  it "ignores session cookies if session exceeds max idle time since update" do
    body("/s/foo/bar").must_equal 'bar'
    body("/g/foo").must_equal 'bar'

    @app.plugin(:sessions, :max_idle_seconds=>-1)
    body("/g/foo").must_equal ''
    errors.must_equal ["Not returning session: maximum session idle time expired"]

    @app.plugin(:sessions, :max_idle_seconds=>10)
    body("/s/foo/bar").must_equal 'bar'
    body("/g/foo").must_equal 'bar'

    errors.must_equal []
  end

  it "supports :serializer and :parser options to override serializer/deserializer" do
    body('/s/foo/bar').must_equal 'bar'

    @app.plugin(:sessions, :parser=>proc{|s| JSON.parse("{#{s[1...-1].reverse}}")})
    body('/g/rab').must_equal 'oof'

    @app.plugin(:sessions, :serializer=>proc{|s| s.to_json.upcase})

    body('/s/foo/baz').must_equal 'baz'
    body('/g/ZAB').must_equal 'OOF'

    errors.must_equal []
  end

  it "logs session decoding errors to rack.errors" do
    body('/s/foo/bar').must_equal 'bar'
    c = @cookie.dup
    k = c.split('=', 2)[0] + '='

    @cookie[20] = '!'
    body('/g/foo').must_equal ''
    errors.must_equal ["Unable to decode session: invalid base64"]

    @cookie = k+Base64.urlsafe_encode64('1'*60)
    body('/g/foo').must_equal ''
    errors.must_equal ["Unable to decode session: data too short"]

    @cookie = k+Base64.urlsafe_encode64('1'*75)
    body('/g/foo').must_equal ''
    errors.must_equal ["Unable to decode session: version marker unsupported"]

    @cookie = k+Base64.urlsafe_encode64("\0"*75)
    body('/g/foo').must_equal ''
    errors.must_equal ["Not decoding session: HMAC invalid"]
  end
end

describe "sessions plugin" do 
  include CookieJar

  def req(path, opts={})
    @errors ||= (errors = []; def errors.puts(s) self << s; end; errors)
    super(path, opts.merge('rack.errors'=>@errors))
  end

  def errors
    e = @errors.dup
    @errors.clear
    e
  end

  it "supports transparent upgrade from Rack::Session::Cookie with default HMAC and coder" do
    app(:bare) do
      use Rack::Session::Cookie, :secret=>'1'
      plugin :middleware_stack
      route do |r|
        r.get('s', String, String){|k, v| session[k] = {:a=>v}; v}
        r.get('g',  String){|k| session[k].inspect}
        ''
      end
    end

    _, h, b = req('/s/foo/bar')
    (h['Set-Cookie'] =~ /\A(rack\.session=.*); path=\/; HttpOnly\z/).must_equal 0
    c = $1
    b.must_equal ['bar']
    _, h, b = req('/g/foo')
    h['Set-Cookie'].must_be_nil
    b.must_equal ['{:a=>"bar"}']

    @app.plugin :sessions, :secret=>'1'*64,
                :upgrade_from_rack_session_cookie_secret=>'1'
    @app.middleware_stack.remove{|m, *| m == Rack::Session::Cookie}

    @cookie = c.dup
    @cookie.slice!(15)
    body('/g/foo').must_equal 'nil'
    errors.must_equal ["Not decoding Rack::Session::Cookie session: HMAC invalid"]

    @cookie = c.split('--', 2)[0]
    body('/g/foo').must_equal 'nil'
    errors.must_equal ["Not decoding Rack::Session::Cookie session: invalid format"]

    @cookie = c.split('--', 2)[0][13..-1]
    @cookie = Rack::Utils.unescape(@cookie).unpack('m')[0]
    @cookie[2] = "^"
    @cookie = [@cookie].pack('m')
    cookie = String.new
    cookie << 'rack.session=' << @cookie << '--' << OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, '1', @cookie)
    @cookie = cookie
    body('/g/foo').must_equal 'nil'
    errors.must_equal ["Error decoding Rack::Session::Cookie session: not base64 encoded marshal dump"]

    @cookie = c
    _, h, b = req('/g/foo')
    h['Set-Cookie'].must_match(/\Aroda\.session=(.*); path=\/; HttpOnly(; SameSite=Lax)?\nrack\.session=; path=\/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00/m)
    b.must_equal ['{"a"=>"bar"}']

    @app.plugin :sessions, :cookie_options=>{:path=>'/foo'}, :upgrade_from_rack_session_cookie_options=>{}
    @cookie = c
    _, h, b = req('/g/foo')
    h['Set-Cookie'].must_match(/\Aroda\.session=(.*); path=\/foo; HttpOnly(; SameSite=Lax)?\nrack\.session=; path=\/foo; max-age=0; expires=Thu, 01 Jan 1970 00:00:00/m)
    b.must_equal ['{"a"=>"bar"}']

    @app.plugin :sessions, :upgrade_from_rack_session_cookie_options=>{:path=>'/baz'}
    @cookie = c
    _, h, b = req('/g/foo')
    h['Set-Cookie'].must_match(/\Aroda\.session=(.*); path=\/foo; HttpOnly(; SameSite=Lax)?\nrack\.session=; path=\/baz; max-age=0; expires=Thu, 01 Jan 1970 00:00:00/m)
    b.must_equal ['{"a"=>"bar"}']

    @app.plugin :sessions, :upgrade_from_rack_session_cookie_key=>'quux.session'
    @cookie = c.sub(/\Arack/, 'quux')
    _, h, b = req('/g/foo')
    h['Set-Cookie'].must_match(/\Aroda\.session=(.*); path=\/foo; HttpOnly(; SameSite=Lax)?\nquux\.session=; path=\/baz; max-age=0; expires=Thu, 01 Jan 1970 00:00:00/m)
    b.must_equal ['{"a"=>"bar"}']
  end
end
end
