require_relative "../spec_helper"
require 'date'

describe "class_matchers plugin" do 
  it "allows class specific regexps with type conversion for class matchers" do
    app(:bare) do
      plugin :class_matchers
      class_matcher(Date, /(\d\d\d\d)-(\d\d)-(\d\d)/){|y,m,d| [Date.new(y.to_i, m.to_i, d.to_i)]}
      class_matcher(Array, /(\w+)\/(\w+)/){|a, b| [[a, 1], [b, 2]]}
      class_matcher(Hash, /(\d+)\/(\d+)/){|a, b| [{a.to_i=>b.to_i}]}

      route do |r|
        r.on Array do |(a,b), (c,d)|
          r.get Date do |date|
            [date.year, date.month, date.day, a, b, c, d].join('-')
          end
          r.get Hash do |h|
            [h.inspect, a, b, c, d].join('-')
          end
          r.get Array do |(a1,b1), (c1,d1)|
            [a1, b1, c1, d1, a, b, c, d].join('-')
          end
          r.is do
            [a, b, c, d].join('-')
          end
          "array"
        end
        ""
      end
    end

    body("/c").must_equal ''
    body("/c/d").must_equal 'c-1-d-2'
    body("/c/d/e").must_equal 'array'
    body("/c/d/2009-10-a").must_equal 'array'
    body("/c/d/2009-10-01").must_equal '2009-10-1-c-1-d-2'
    body("/c/d/1/2").must_equal '{1=>2}-c-1-d-2'
    body("/c/d/e/f").must_equal 'e-1-f-2-c-1-d-2'
  end
end
