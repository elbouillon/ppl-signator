require_relative "../spec_helper"

describe "placeholder_string_matchers plugin" do
  it "should handle string with embedded param" do
    app(:placeholder_string_matchers) do |r|
      r.on "posts/:id" do |id|
        id
      end

      r.on "responses-:id" do |id|
        id
      end
    end

    body('/posts/123').must_equal '123'
    status('/post/123').must_equal 404
    body('/responses-123').must_equal '123'
  end

  it "should handle multiple params in single string" do
    app(:placeholder_string_matchers) do |r|
      r.on "u/:uid/posts/:id" do |uid, id|
        uid + id
      end
    end

    body("/u/jdoe/posts/123").must_equal 'jdoe123'
    status("/u/jdoe/pots/123").must_equal 404
  end

  it "should escape regexp metacharaters in string" do
    app(:placeholder_string_matchers) do |r|
      r.on "u/:uid/posts?/:id" do |uid, id|
        uid + id
      end
    end

    body("/u/jdoe/posts?/123").must_equal 'jdoe123'
    status("/u/jdoe/post/123").must_equal 404
  end

  it "should handle colons by themselves" do
    app(:placeholder_string_matchers) do |r|
      r.on "u/:/:uid/posts/::id" do |uid, id|
        uid + id
      end
    end

    body("/u/:/jdoe/posts/:123").must_equal 'jdoe123'
    status("/u/a/jdoe/post/b123").must_equal 404
  end

  it "should work with params_capturing plugin to add captures to r.params for string matchers" do
    app(:bare) do
      plugin :placeholder_string_matchers
      plugin :params_capturing

      route do |r|
        r.on("bar/:foo") do |foo|
          "b-#{foo}-#{r.params['foo']}-#{r.params['captures'].length}"
        end

        r.on("baz/:bar", :foo) do |bar, foo|
          "b-#{bar}-#{foo}-#{r.params['bar']}-#{r.params['foo']}-#{r.params['captures'].length}"
        end
      end
    end

    body('/bar/banana', 'rack.input'=>StringIO.new).must_equal 'b-banana-banana-1'
    body('/baz/ban/ana', 'rack.input'=>StringIO.new).must_equal 'b-ban-ana-ban-ana-2'
  end

  it "works with symbol_matchers plugin" do
    app(:bare) do
      plugin :placeholder_string_matchers
      plugin :symbol_matchers
      symbol_matcher(:f, /(f+)/)

      route do |r|
        r.is ":d" do |d|
          "d#{d}"
        end

        r.is "thing/:thing" do |d|
          "thing#{d}"
        end

        r.is "thing2", ":thing" do |d|
          "thing2#{d}"
        end

        r.is ":f" do |f|
          "f#{f}"
        end

        r.is 'q:rest' do |rest|
          "rest#{rest}"
        end

        r.is ":w" do |w|
          "w#{w}"
        end

        r.is ':d/:w/:f' do |d, w, f|
          "dwf#{d}#{w}#{f}"
        end
      end
    end

    status.must_equal 404
    body("/1").must_equal 'd1'
    body("/11232135").must_equal 'd11232135'
    body("/a").must_equal 'wa'
    body("/1az0").must_equal 'w1az0'
    body("/f").must_equal 'ff'
    body("/ffffffffffffffff").must_equal 'fffffffffffffffff'
    status("/-").must_equal 404
    body("/1/1a/f").must_equal 'dwf11af'
    body("/12/1azy/fffff").must_equal 'dwf121azyfffff'
    status("/1/f/a").must_equal 404
    body("/qa/b/c/d//f/g").must_equal 'resta/b/c/d//f/g'
    body('/q').must_equal 'rest'
    body('/thing/q').must_equal 'thingq'
    body('/thing2/q').must_equal 'thing2q'
  end
end
