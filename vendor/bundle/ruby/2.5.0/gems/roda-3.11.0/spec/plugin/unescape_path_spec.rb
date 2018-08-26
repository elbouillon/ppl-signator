require_relative "../spec_helper"

describe "unescape_path_path plugin" do 
  it "decodes URL-encoded routing path" do
    app(:unescape_path) do |r|
      r.on 'b' do
        r.get(/(.)/) do |a|
          "#{a}-b"
        end
      end

      r.get :name do |name|
        name
      end
    end

    body('/a').must_equal 'a'
    body('/%61').must_equal 'a'
    body('%2f%61').must_equal 'a'
    body('%2f%62%2f%61').must_equal 'a-b'
  end
end
