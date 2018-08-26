require_relative "../spec_helper"

describe "params_capturing plugin" do 
  it "should add captures to r.params for symbol matchers" do
    app(:params_capturing) do |r|
      r.on('foo', :y, :z, :w) do |y, z, w|
        (r.params.values_at('y', 'z', 'w') + [y, z, w, r.params['captures'].length]).join('-')
      end

      r.on(/(quux)/, /(foo)(bar)/) do |q, foo, bar|
        "y-#{r.params['captures'].join}-#{q}-#{foo}-#{bar}"
      end

      r.on(/(quux)/, :y) do |q, y|
        r.on(:x) do |x|
          "y-#{r.params['y']}-#{r.params['x']}-#{q}-#{y}-#{x}-#{r.params['captures'].length}"
        end

        "y-#{r.params['y']}-#{q}-#{y}-#{r.params['captures'].length}"
      end

      r.on(:x) do |x|
        "x-#{x}-#{r.params['x']}-#{r.params['captures'].length}"
      end
    end

    body('/blarg', 'rack.input'=>StringIO.new).must_equal 'x-blarg-blarg-1'
    body('/foo/1/2/3', 'rack.input'=>StringIO.new).must_equal '1-2-3-1-2-3-3'
    body('/quux/foobar', 'rack.input'=>StringIO.new).must_equal 'y-quuxfoobar-quux-foo-bar'
    body('/quux/asdf', 'rack.input'=>StringIO.new).must_equal 'y--quux-asdf-2'
    body('/quux/asdf/890', 'rack.input'=>StringIO.new).must_equal 'y--890-quux-asdf-890-3'
  end
end
