require_relative "../spec_helper"

describe "json_parser plugin" do 
  before do
    app(:json_parser) do |r|
      r.params['a']['b'].to_s
    end
  end

  it "parses incoming json if content type specifies json" do
    body('rack.input'=>StringIO.new('{"a":{"b":1}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '1'
  end

  it "doesn't affect parsing of non-json content type" do
    body('rack.input'=>StringIO.new('a[b]=1'), 'REQUEST_METHOD'=>'POST').must_equal '1'
  end

  it "returns 400 for invalid json" do
    req('rack.input'=>StringIO.new('{"a":{"b":1}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal [400, {}, []]
  end

  it "raises by default if r.params is called and a non-hash is submitted" do
    proc do
      req('rack.input'=>StringIO.new('[1]'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST')
    end.must_raise
  end
end

describe "json_parser plugin" do 
  it "handles empty request bodies" do
    app(:json_parser) do |r|
      r.params.length.to_s
    end
    body('rack.input'=>StringIO.new(''), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '0'
  end

  it "handles arrays and other non-hash values using r.POST" do
    app(:json_parser) do |r|
      r.POST.inspect
    end
    body('rack.input'=>StringIO.new('[ 1 ]'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '[1]'
  end

  it "supports :wrap=>:always option" do
    app(:bare) do
      plugin(:json_parser, :wrap=>:always)
      route do |r|
        r.post 'a' do r.params['_json']['a']['b'].to_s end
        r.params['_json'][1].to_s
      end
    end
    body('/a', 'rack.input'=>StringIO.new('{"a":{"b":1}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '1'
    body('rack.input'=>StringIO.new('[true, 2]'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '2'
  end

  it "supports :wrap=>:unless_hash option" do
    app(:bare) do
      plugin(:json_parser, :wrap=>:unless_hash)
      route do |r|
        r.post 'a' do r.params['a']['b'].to_s end
        r.params['_json'][1].to_s
      end
    end
    body('/a', 'rack.input'=>StringIO.new('{"a":{"b":1}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '1'
    body('rack.input'=>StringIO.new('[true, 2]'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '2'
  end

  it "raises for unsupported :wrap option" do
    proc do 
      app(:bare) do
        plugin(:json_parser, :wrap=>:foo)
      end
    end.must_raise Roda::RodaError
  end

  it "supports :error_handler option" do
    app(:bare) do
      plugin(:json_parser, :error_handler=>proc{|r| r.halt [401, {}, ['bad']]})
      route do |r|
        r.params['a']['b'].to_s
      end
    end
    req('rack.input'=>StringIO.new('{"a":{"b":1}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal [401, {}, ['bad']]
  end

  it "works with bare POST" do
    app(:bare) do
      plugin(:json_parser, :error_handler=>proc{|r| r.halt [401, {}, ['bad']]})
      route do |r|
        (r.POST['a']['b'] + r.POST['a']['c']).to_s
      end
    end
    body('rack.input'=>StringIO.new('{"a":{"b":1,"c":2}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '3'
  end

  it "supports :parser option" do
    app(:bare) do
      plugin(:json_parser, :parser=>method(:eval))
      route do |r|
        r.params['a']['b'].to_s
      end
    end
    body('rack.input'=>StringIO.new("{'a'=>{'b'=>1}}"), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '1'
  end

  it "supports :include_request option" do
    app(:bare) do
      plugin(:json_parser,
        :include_request => true,
        :parser => lambda{|s,r| {'a'=>s, 'b'=>r.path_info}})
      route do |r|
        "#{r.params['a']}:#{r.params['b']}"
      end
    end
    body('rack.input'=>StringIO.new('{}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '{}:/'
  end

  it "supports resetting :include_request option to false" do
    app(:bare) do
      plugin :json_parser, :include_request => true
      plugin :json_parser, :include_request => false
      route do |r|
        r.params['a']['b'].to_s
      end
    end
    body('rack.input'=>StringIO.new('{"a":{"b":1}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').must_equal '1'
  end
end
