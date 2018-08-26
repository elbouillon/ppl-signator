require_relative "../spec_helper"

describe "response_request plugin" do
  it "gives the response access to the request" do
    app(:response_request) do
      response.request.post? ? "b" : "a"
    end

    body.must_equal "a"
    body('REQUEST_METHOD'=>'POST').must_equal "b"
  end

  it "should work with error_handler plugin" do
    app(:bare) do
      plugin :response_request

      plugin :error_handler do |_|
        response.request.post? ? "b" : "a"
      end
      
      route{raise}
    end

    body.must_equal "a"
    body('REQUEST_METHOD'=>'POST').must_equal "b"
  end

  it "should work with class_level_routing plugin" do
    app(:bare) do
      plugin :response_request
      plugin :class_level_routing
      
      is '' do |_|
        response.request.post? ? "b" : "a"
      end
      
      route{}
    end

    body.must_equal "a"
    body('REQUEST_METHOD'=>'POST').must_equal "b"
  end
end
