require_relative "../spec_helper"

describe "symbol_matchers plugin" do 
  it "allows symbol specific regexps for symbol matchers" do
    app(:bare) do
      plugin :symbol_matchers
      symbol_matcher(:f, /(f+)/)

      route do |r|
        r.is :d do |d|
          "d#{d}"
        end

        r.is "thing2", :thing do |d|
          "thing2#{d}"
        end

        r.is :f do |f|
          "f#{f}"
        end

        r.is 'q', :rest do |rest|
          "rest#{rest}"
        end

        r.is :w do |w|
          "w#{w}"
        end

        r.is :d, :w, :f do |d, w, f|
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
    body("/q/a/b/c/d//f/g").must_equal 'resta/b/c/d//f/g'
    body('/q/').must_equal 'rest'
    body('/thing2/q').must_equal 'thing2q'
  end
end
