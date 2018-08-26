require_relative "../spec_helper"

describe "status_303 plugin" do
  it 'uses a 302 for get requests' do
    app(:status_303) do
      request.redirect '/foo'
      fail 'redirect should halt'
    end
    status.must_equal 302
    body.must_equal ''
    header('Location').must_equal '/foo'
  end

  it 'uses the code given when specified' do
    app(:status_303) do
      request.redirect '/foo', 301
    end
    status.must_equal 301
  end

  it 'uses 303 for post requests if request is HTTP 1.1, 302 for 1.0' do
    app(:status_303) do
      request.redirect '/foo'
    end
    status('HTTP_VERSION' => 'HTTP/1.1', 'REQUEST_METHOD'=>'POST').must_equal 303
    status('HTTP_VERSION' => 'HTTP/1.0', 'REQUEST_METHOD'=>'POST').must_equal 302
  end
end
