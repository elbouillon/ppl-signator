require_relative "../spec_helper"

describe "head plugin" do 
  it "considers HEAD requests as GET requests which return no body" do
    app(:head) do |r|
      r.root do
        'root'
      end

      r.get 'a' do
        'a'
      end

      r.is 'b', :method=>[:get, :post] do
        'b'
      end
    end

    s, h, b = req
    s.must_equal 200
    h['Content-Length'].must_equal '4'
    b.must_equal ['root']

    s, h, b = req('REQUEST_METHOD' => 'HEAD')
    s.must_equal 200
    h['Content-Length'].must_equal '4'
    b.must_equal []

    body('/a').must_equal 'a'
    status('/a', 'REQUEST_METHOD' => 'HEAD').must_equal 200

    body('/b').must_equal 'b'
    status('/b', 'REQUEST_METHOD' => 'HEAD').must_equal 200
  end

  it "releases resources via body.close" do
    body = StringIO.new('hi')
    app(:head) do |r|
      r.root do
        r.halt [ 200, {}, body ]
      end
    end
    s, _, b = req('REQUEST_METHOD' => 'HEAD')
    s.must_equal 200
    res = String.new
    body.closed?.must_equal false
    b.each { |buf| res << buf }
    b.close
    body.closed?.must_equal true
    res.must_equal ''
  end
end
