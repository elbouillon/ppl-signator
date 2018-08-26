require_relative "spec_helper"

describe "Roda#env" do
  it "should return the environment" do
    app do |r|
      env['PATH_INFO']
    end

    body("/foo").must_equal  "/foo"
  end
end
