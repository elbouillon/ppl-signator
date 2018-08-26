require_relative "../spec_helper"

describe "early_hints plugin" do 
  it "allows sending early hints to rack.early_hints" do
    queue = []
    app(:early_hints) do |r|
      send_early_hints('Link'=>'</foo.js>; rel=preload; as=script')
      queue << 'OK'
      'OK'
    end

    body.must_equal 'OK'
    queue.must_equal ['OK']

    queue = []
    body('rack.early_hints'=>proc{|h| queue << h}).must_equal 'OK'
    queue.must_equal [{'Link'=>'</foo.js>; rel=preload; as=script'}, 'OK']
  end
end
