require_relative "../spec_helper"
require 'tempfile'

describe "typecast_params plugin" do 
  def tp(arg='a=1&b[]=2&b[]=3&c[d]=4&c[e]=5&f=&g[]=&h[i]=')
    @tp.call(arg)
  end

  def error
    yield
  rescue @tp_error => e
    e
  end

  before do
    res = nil
    app(:typecast_params) do |r|
      res = typecast_params
      nil
    end

    @tp = lambda do |params|
      req('QUERY_STRING'=>params, 'rack.input'=>StringIO.new)
      res
    end

    @tp_error = Roda::RodaPlugins::TypecastParams::Error
  end

  it ".new should raise error if params is not a hash" do
    lambda{Roda::RodaPlugins::TypecastParams::Params.new('a')}.must_raise @tp_error
  end

  it ".new should raise for non String/Array args passed to conversion method" do
    lambda{tp.any({})}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
    lambda{tp.any(Object.new)}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
    lambda{tp.any(:a)}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "#present should return whether the key is in the obj if given String" do
    tp.present?('a').must_equal true
    tp.present?('b').must_equal true
    tp.present?('c').must_equal true
    tp.present?('d').must_equal false
  end

  it "#present should return whether all keys are in the obj if given an Array" do
    tp.present?(%w'a b c').must_equal true
    tp.present?(%w'a b c d').must_equal false
  end

  it "#present should raise if given an unexpected object" do
    lambda{tp.present?(:a)}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
    lambda{tp.present?([:a])}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
    lambda{tp.present?([['a']])}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "conversion methods should only support one level deep array of keys" do
    lambda{tp.any([['a']])}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "#any should not do any conversion" do
    tp.any('a').must_equal '1'
    tp.any('b').must_equal ["2", "3"]
    tp.any('c').must_equal('d'=>'4', 'e'=>'5')
    tp.any('d').must_be_nil
    tp.any(%w'g h').must_equal([[''], {'i'=>''}])

    tp.any!('a').must_equal '1'
    tp.any!(%w'a').must_equal %w'1'
    lambda{tp.any!('d')}.must_raise @tp_error
    lambda{tp.any!(%w'd j')}.must_raise @tp_error

    lambda{tp.array(:any, 'a')}.must_raise @tp_error
    tp.array(:any, 'b').must_equal ["2", "3"]
    lambda{tp.array(:any, 'c')}.must_raise @tp_error
    tp.array(:any, 'd').must_be_nil
    tp.array(:any, %w'g').must_equal([['']])
    lambda{tp.array(:any, 'h')}.must_raise @tp_error

    tp.array!(:any, 'b').must_equal ["2", "3"]
    lambda{tp.array!(:any, 'd')}.must_raise @tp_error
    tp.array!(:any, %w'g').must_equal([['']])
  end

  it "#str should require strings" do
    tp.str('a').must_equal '1'
    lambda{tp.str('b')}.must_raise @tp_error
    lambda{tp.str('c')}.must_raise @tp_error
    lambda{tp.str(%w'b c')}.must_raise @tp_error
    tp.str('d').must_be_nil
    tp.str('f').must_equal ''
    lambda{tp.str('g')}.must_raise @tp_error
    lambda{tp.str('h')}.must_raise @tp_error

    tp.str!('a').must_equal '1'
    lambda{tp.str!('d')}.must_raise @tp_error
    tp.str!('f').must_equal ''

    lambda{tp.array(:str, 'a')}.must_raise @tp_error
    tp.array(:str, 'b').must_equal ["2", "3"]
    lambda{tp.array(:str, 'c')}.must_raise @tp_error
    tp.array(:str, 'd').must_be_nil
    tp.array(:str, 'g').must_equal [""]
    lambda{tp.array(:str, 'h')}.must_raise @tp_error

    tp.array!(:str, 'b').must_equal ["2", "3"]
    lambda{tp.array!(:str, 'd')}.must_raise @tp_error
    tp.array!(:str, 'g').must_equal [""]
  end

  it "#nonempty_str should require nonempty strings" do
    tp.nonempty_str('a').must_equal '1'
    tp('a=%201').nonempty_str('a').must_equal ' 1'
    tp('a=1%20').nonempty_str('a').must_equal '1 '
    tp('a=%201%20').nonempty_str('a').must_equal ' 1 '
    tp('a=%20').nonempty_str('a').must_be_nil
    lambda{tp.nonempty_str('b')}.must_raise @tp_error
    lambda{tp.nonempty_str('c')}.must_raise @tp_error
    tp.nonempty_str('d').must_be_nil
    tp.nonempty_str('f').must_be_nil
    lambda{tp.nonempty_str('g')}.must_raise @tp_error
    lambda{tp.nonempty_str('h')}.must_raise @tp_error

    tp.nonempty_str!('a').must_equal '1'
    lambda{tp.nonempty_str!('d')}.must_raise @tp_error
    lambda{tp.nonempty_str!('f')}.must_raise @tp_error

    lambda{tp.array(:nonempty_str, 'a')}.must_raise @tp_error
    tp.array(:nonempty_str, 'b').must_equal ["2", "3"]
    lambda{tp.array(:nonempty_str, 'c')}.must_raise @tp_error
    tp.array(:nonempty_str, 'd').must_be_nil
    tp.array(:nonempty_str, 'g').must_equal [nil]
    lambda{tp.array(:nonempty_str, 'h')}.must_raise @tp_error

    tp.array!(:nonempty_str, 'b').must_equal ["2", "3"]
    lambda{tp.array!(:nonempty_str, 'd')}.must_raise @tp_error
    lambda{tp.array!(:nonempty_str, 'g')}.must_raise @tp_error
  end

  it "#bool should convert to boolean" do
    tp('a=0').bool('a').must_equal false
    tp('a=f').bool('a').must_equal false
    tp('a=false').bool('a').must_equal false
    tp('a=FALSE').bool('a').must_equal false
    tp('a=F').bool('a').must_equal false
    tp('a=n').bool('a').must_equal false
    tp('a=no').bool('a').must_equal false
    tp('a=N').bool('a').must_equal false
    tp('a=NO').bool('a').must_equal false
    tp('a=off').bool('a').must_equal false
    tp('a=OFF').bool('a').must_equal false

    tp('a=1').bool('a').must_equal true
    tp('a=t').bool('a').must_equal true
    tp('a=true').bool('a').must_equal true
    tp('a=TRUE').bool('a').must_equal true
    tp('a=T').bool('a').must_equal true
    tp('a=y').bool('a').must_equal true
    tp('a=yes').bool('a').must_equal true
    tp('a=Y').bool('a').must_equal true
    tp('a=YES').bool('a').must_equal true
    tp('a=on').bool('a').must_equal true
    tp('a=ON').bool('a').must_equal true

    tp.bool('a').must_equal true
    lambda{tp.bool('b')}.must_raise @tp_error
    lambda{tp.bool('c')}.must_raise @tp_error
    tp.bool('d').must_be_nil
    tp.bool('f').must_be_nil

    tp.bool!('a').must_equal true
    lambda{tp.bool!('d')}.must_raise @tp_error
    lambda{tp.bool!('f')}.must_raise @tp_error

    lambda{tp.array(:bool, 'a')}.must_raise @tp_error
    tp('b[]=1&b[]=0').array(:bool, 'b').must_equal [true, false]
    lambda{tp('b[]=1&b[]=a').array(:bool, 'b')}.must_raise @tp_error
    lambda{tp.array(:bool, 'c')}.must_raise @tp_error
    tp.array(:bool, 'd').must_be_nil
    tp.array(:bool, 'g').must_equal [nil]
    lambda{tp.array(:bool, 'h')}.must_raise @tp_error

    tp('b[]=1&b[]=0').array!(:bool, 'b').must_equal [true, false]
    lambda{tp.array!(:bool, 'd')}.must_raise @tp_error
    lambda{tp.array!(:bool, 'g')}.must_raise @tp_error
  end

  it "#int should convert to integer" do
    tp('a=-1').int('a').must_equal(-1)
    tp('a=0').int('a').must_equal 0
    tp('a=a').int('a').must_equal 0
    tp.int('a').must_equal 1
    tp.int('a').must_be_kind_of Integer
    lambda{tp.int('b')}.must_raise @tp_error
    lambda{tp.int('c')}.must_raise @tp_error
    tp.int('d').must_be_nil
    tp.int('f').must_be_nil
    lambda{tp.int('g')}.must_raise @tp_error
    lambda{tp.int('h')}.must_raise @tp_error

    tp.int!('a').must_equal 1
    lambda{tp.int!('d')}.must_raise @tp_error
    lambda{tp.int!('f')}.must_raise @tp_error

    lambda{tp.array(:int, 'a')}.must_raise @tp_error
    tp.array(:int, 'b').must_equal [2, 3]
    lambda{tp.array(:int, 'c')}.must_raise @tp_error
    tp.array(:int, 'd').must_be_nil
    tp.array(:int, 'g').must_equal [nil]
    lambda{tp.array(:int, 'h')}.must_raise @tp_error

    tp.array!(:int, 'b').must_equal [2, 3]
    lambda{tp.array!(:int, 'd')}.must_raise @tp_error
    lambda{tp.array!(:int, 'g')}.must_raise @tp_error
  end

  it "#pos_int should convert to positive integer" do
    tp('a=-1').pos_int('a').must_be_nil
    tp('a=0').pos_int('a').must_be_nil
    tp('a=a').pos_int('a').must_be_nil
    tp.pos_int('a').must_equal 1
    tp.pos_int('a').must_be_kind_of Integer
    lambda{tp.pos_int('b')}.must_raise @tp_error
    lambda{tp.pos_int('c')}.must_raise @tp_error
    tp.pos_int('d').must_be_nil
    tp.pos_int('f').must_be_nil
    lambda{tp.pos_int('g')}.must_raise @tp_error
    lambda{tp.pos_int('h')}.must_raise @tp_error

    lambda{tp('a=-1').pos_int!('a')}.must_raise @tp_error
    lambda{tp('a=0').pos_int!('a')}.must_raise @tp_error
    lambda{tp('a=a').pos_int!('a')}.must_raise @tp_error
    tp.pos_int!('a').must_equal 1
    lambda{tp.pos_int!('d')}.must_raise @tp_error
    lambda{tp.pos_int!('f')}.must_raise @tp_error

    lambda{tp.array(:pos_int, 'a')}.must_raise @tp_error
    tp.array(:pos_int, 'b').must_equal [2, 3]
    lambda{tp.array(:pos_int, 'c')}.must_raise @tp_error
    tp.array(:pos_int, 'd').must_be_nil
    tp.array(:pos_int, 'g').must_equal [nil]
    lambda{tp.array(:pos_int, 'h')}.must_raise @tp_error

    tp.array!(:pos_int, 'b').must_equal [2, 3]
    lambda{tp.array!(:pos_int, 'd')}.must_raise @tp_error
    lambda{tp.array!(:pos_int, 'g')}.must_raise @tp_error
  end

  it "#Integer should convert to integer strictly" do
    tp('a=-1').Integer('a').must_equal(-1)
    tp('a=0').Integer('a').must_equal 0
    lambda{tp('a=a').Integer('a')}.must_raise @tp_error
    tp.Integer('a').must_equal 1
    tp.Integer('a').must_be_kind_of Integer
    lambda{tp.Integer('b')}.must_raise @tp_error
    lambda{tp.Integer('c')}.must_raise @tp_error
    tp.Integer('d').must_be_nil
    tp.Integer('f').must_be_nil
    lambda{tp.Integer('g')}.must_raise @tp_error
    lambda{tp.Integer('h')}.must_raise @tp_error

    tp.Integer!('a').must_equal 1
    lambda{tp.Integer!('d')}.must_raise @tp_error
    lambda{tp.Integer!('f')}.must_raise @tp_error

    lambda{tp.array(:Integer, 'a')}.must_raise @tp_error
    tp.array(:Integer, 'b').must_equal [2, 3]
    lambda{tp.array(:Integer, 'c')}.must_raise @tp_error
    tp.array(:Integer, 'd').must_be_nil
    tp.array(:Integer, 'g').must_equal [nil]
    lambda{tp.array(:Integer, 'h')}.must_raise @tp_error

    tp.array!(:Integer, 'b').must_equal [2, 3]
    lambda{tp.array!(:Integer, 'd')}.must_raise @tp_error
    lambda{tp.array!(:Integer, 'g')}.must_raise @tp_error

    a = 1
    @app.plugin :hooks
    @app.before do
      request.define_singleton_method(:params){{'a'=>a}}
    end
    tp.Integer('a').must_equal 1
    a = 1.0
    tp.Integer('a').must_equal 1
    a = 1.1
    lambda{tp.Integer('a')}.must_raise @tp_error
  end

  it "#float should convert to float" do
    tp('a=-1').float('a').must_equal(-1)
    tp('a=0').float('a').must_equal 0
    tp('a=a').float('a').must_equal 0
    tp.float('a').must_equal 1
    tp.float('a').must_be_kind_of Float
    lambda{tp.float('b')}.must_raise @tp_error
    lambda{tp.float('c')}.must_raise @tp_error
    tp.float('d').must_be_nil
    tp.float('f').must_be_nil
    lambda{tp.float('g')}.must_raise @tp_error
    lambda{tp.float('h')}.must_raise @tp_error

    tp.float!('a').must_equal 1
    lambda{tp.float!('d')}.must_raise @tp_error
    lambda{tp.float!('f')}.must_raise @tp_error

    lambda{tp.array(:float, 'a')}.must_raise @tp_error
    tp.array(:float, 'b').must_equal [2, 3]
    lambda{tp.array(:float, 'c')}.must_raise @tp_error
    tp.array(:float, 'd').must_be_nil
    tp.array(:float, 'g').must_equal [nil]
    lambda{tp.array(:float, 'h')}.must_raise @tp_error

    tp.array!(:float, 'b').must_equal [2, 3]
    lambda{tp.array!(:float, 'd')}.must_raise @tp_error
    lambda{tp.array!(:float, 'g')}.must_raise @tp_error
  end

  it "#Float should convert to float strictly" do
    tp('a=-1').Float('a').must_equal(-1)
    tp('a=0').Float('a').must_equal 0
    lambda{tp('a=a').Float('a')}.must_raise @tp_error
    tp.Float('a').must_equal 1
    tp.Float('a').must_be_kind_of Float
    lambda{tp.Float('b')}.must_raise @tp_error
    lambda{tp.Float('c')}.must_raise @tp_error
    tp.Float('d').must_be_nil
    tp.Float('f').must_be_nil
    lambda{tp.Float('g')}.must_raise @tp_error
    lambda{tp.Float('h')}.must_raise @tp_error

    tp.Float!('a').must_equal 1
    lambda{tp.Float!('d')}.must_raise @tp_error
    lambda{tp.Float!('f')}.must_raise @tp_error

    lambda{tp.array(:Float, 'a')}.must_raise @tp_error
    tp.array(:Float, 'b').must_equal [2, 3]
    lambda{tp.array(:Float, 'c')}.must_raise @tp_error
    tp.array(:Float, 'd').must_be_nil
    tp.array(:Float, 'g').must_equal [nil]
    lambda{tp.array(:Float, 'h')}.must_raise @tp_error

    tp.array!(:Float, 'b').must_equal [2, 3]
    lambda{tp.array!(:Float, 'd')}.must_raise @tp_error
    lambda{tp.array!(:Float, 'g')}.must_raise @tp_error
  end

  it "#Hash should require hashes" do
    lambda{tp.Hash('a')}.must_raise @tp_error
    lambda{tp.Hash('b')}.must_raise @tp_error
    tp.Hash('c').must_equal('d'=>'4', 'e'=>'5')
    tp.Hash('d').must_be_nil
    lambda{tp.Hash('f')}.must_raise @tp_error
    lambda{tp.Hash('g')}.must_raise @tp_error
    tp.Hash('h').must_equal('i'=>'')

    tp.Hash!('c').must_equal('d'=>'4', 'e'=>'5')
    lambda{tp.Hash!('d')}.must_raise @tp_error
    tp.Hash!('h').must_equal('i'=>'')

    lambda{tp.array(:Hash, 'c')}.must_raise @tp_error
    lambda{tp('a[][b]=2&a[]=3').array(:Hash, 'a')}.must_raise @tp_error
    tp('a[][b]=2&a[][b]=3').array(:Hash, 'a').must_equal [{'b'=>'2'}, {'b'=>'3'}]
    tp.array(:Hash, 'd').must_be_nil

    tp('a[][b]=2&a[][b]=3').array!(:Hash, 'a').must_equal [{'b'=>'2'}, {'b'=>'3'}]
    lambda{tp.array!(:Hash, 'd')}.must_raise @tp_error
  end

  it "#Date should parse strings into Date instances" do
    tp('a=').date('a').must_be_nil
    tp('a=2017-10-11').date('a').must_equal Date.new(2017, 10, 11)
    tp('a=17/10/11').date('a').must_equal Date.new(2017, 10, 11)
    lambda{tp.date('b')}.must_raise @tp_error
    lambda{tp('a=a').date('a')}.must_raise @tp_error

    lambda{tp('a=').date!('a')}.must_raise @tp_error
    tp('a=2017-10-11').date!('a').must_equal Date.new(2017, 10, 11)

    tp('a[]=2017-10-11&a[]=2017-10-12').array(:date, 'a').must_equal [Date.new(2017, 10, 11), Date.new(2017, 10, 12)]
    tp('a[]=2017-10-11&a[]=2017-10-12').array(:date, 'b').must_be_nil

    tp('a[]=2017-10-11&a[]=2017-10-12').array!(:date, 'a').must_equal [Date.new(2017, 10, 11), Date.new(2017, 10, 12)]
    lambda{tp('a[]=2017-10-11&a[]=a').array!(:date, 'a')}.must_raise @tp_error
    lambda{tp('a[]=2017-10-11&a[]=2017-10-12').array!(:date, 'b')}.must_raise @tp_error
  end

  it "#Time should parse strings into Time instances" do
    tp('a=').time('a').must_be_nil
    tp('a=2017-10-11%2012:13:14').time('a').must_equal Time.local(2017, 10, 11, 12, 13, 14)
    tp('a=17/10/11%2012:13:14').time('a').must_equal Time.local(2017, 10, 11, 12, 13, 14)
    lambda{tp.time('b')}.must_raise @tp_error
    lambda{tp('a=a').time('a')}.must_raise @tp_error

    lambda{tp('a=').time!('a')}.must_raise @tp_error
    tp('a=2017-10-11%2012:13:14').time!('a').must_equal Time.new(2017, 10, 11, 12, 13, 14)

    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array(:time, 'a').must_equal [Time.local(2017, 10, 11, 12, 13, 14), Time.local(2017, 10, 12, 12, 13, 14)]
    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array(:time, 'b').must_be_nil

    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array!(:time, 'a').must_equal [Time.local(2017, 10, 11, 12, 13, 14), Time.local(2017, 10, 12, 12, 13, 14)]
    lambda{tp('a[]=2017-10-11%2012:13:14&a[]=a').array!(:time, 'a')}.must_raise @tp_error
    lambda{tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array!(:time, 'b')}.must_raise @tp_error
  end

  it "#DateTime should parse strings into DateTime instances" do
    tp('a=').datetime('a').must_be_nil
    tp('a=2017-10-11%2012:13:14').datetime('a').must_equal DateTime.new(2017, 10, 11, 12, 13, 14)
    tp('a=17/10/11%2012:13:14').datetime('a').must_equal DateTime.new(2017, 10, 11, 12, 13, 14)
    lambda{tp.datetime('b')}.must_raise @tp_error
    lambda{tp('a=a').datetime('a')}.must_raise @tp_error

    lambda{tp('a=').datetime!('a')}.must_raise @tp_error
    tp('a=2017-10-11%2012:13:14').datetime!('a').must_equal DateTime.new(2017, 10, 11, 12, 13, 14)

    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array(:datetime, 'a').must_equal [DateTime.new(2017, 10, 11, 12, 13, 14), DateTime.new(2017, 10, 12, 12, 13, 14)]
    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array(:datetime, 'b').must_be_nil

    tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array!(:datetime, 'a').must_equal [DateTime.new(2017, 10, 11, 12, 13, 14), DateTime.new(2017, 10, 12, 12, 13, 14)]
    lambda{tp('a[]=2017-10-11%2012:13:14&a[]=a').array!(:datetime, 'a')}.must_raise @tp_error
    lambda{tp('a[]=2017-10-11%2012:13:14&a[]=2017-10-12%2012:13:14').array!(:datetime, 'b')}.must_raise @tp_error
  end

  it "#array should handle defaults" do
    tp = tp('b[]=1&c[]=')
    tp.array(:int, 'b', [2]).must_equal [1]
    tp.array(:int, 'c', [2]).must_equal [nil]
    tp.array(:int, 'd', []).must_equal []
    tp.array(:int, 'e', [1]).must_equal [1]

    tp('b[]=1&c[]=').array(:int, %w'b c', [2]).must_equal [[1], [nil]]
    tp('b[]=1&c[]=').array(:int, %w'b d', [2]).must_equal [[1], [2]]
  end

  it "#array! should handle defaults" do
    tp = tp('b[]=1&c[]=')
    tp.array!(:int, 'b', [2]).must_equal [1]
    lambda{tp.array!(:int, 'c', [2])}.must_raise @tp_error
    tp.array!(:int, 'd', []).must_equal []
    tp.array!(:int, 'e', [1]).must_equal [1]

    lambda{tp('b[]=1&c[]=').array!(:int, %w'b c', [2])}.must_raise @tp_error
    tp('b[]=1&c[]=').array!(:int, %w'b d', [2]).must_equal [[1], [2]]
  end

  it "#array should handle key arrays" do
    tp('b[]=1&c[]=2').array(:int, %w'b c').must_equal [[1], [2]]
    tp('b[]=1&c[]=').array(:int, %w'b c').must_equal [[1], [nil]]
  end

  it "#array! should handle key arrays" do
    tp('b[]=1&c[]=2').array!(:int, %w'b c').must_equal [[1], [2]]
    lambda{tp('b[]=1&c[]=').array!(:int, %w'b c')}.must_raise @tp_error
  end

  it "#[] should access nested values" do
    tp['c'].must_be_kind_of tp.class
    tp['c'].int('d').must_equal 4
    tp['c'].int('e').must_equal 5
    tp['c'].int(%w'd e').must_equal [4, 5]
  end

  it "#[] should handle deeply nested structures" do
    tp('a[b][c][d][e]=1')['a']['b']['c']['d'].int('e').must_equal 1
    tp('a[][b][][e]=1')['a'][0]['b'][0].int('e').must_equal 1
  end

  it "#[] should raise error for non-Array/Hash parameters" do
    lambda{tp['a']}.must_raise @tp_error
  end

  it "#[] should raise error for accessing hash with integer value (thinking it is an array)" do
    lambda{tp[1]}.must_raise @tp_error
  end

  it "#[] should raise error for accessing array with non-integer value non-Array/Hash parameters" do
    lambda{tp['b']['a']}.must_raise @tp_error
  end

  it "#convert! should return a hash of converted parameters" do
    tp = tp()
    tp.convert! do |ptp|
      ptp.int!('a')
      ptp.array!(:int, 'b')
      ptp['c'].convert! do |stp|
        stp.int!(%w'd e')
      end
    end.must_equal("a"=>1, "b"=>[2, 3], "c"=>{"d"=>4, "e"=>5})
  end

  it "#convert! hash should only include changes made inside block" do
    tp = tp()
    tp.convert! do |ptp|
      ptp.int!('a')
      ptp.array!(:int, 'b')
    end.must_equal("a"=>1, "b"=>[2, 3])

    tp.convert! do |ptp|
      ptp['c'].convert! do |stp|
        stp.int!(%w'd e')
      end
    end.must_equal("c"=>{"d"=>4, "e"=>5})
  end

  it "#convert! should handle deeply nested structures" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert! do |tp0|
      tp0['a'].convert! do |tp1|
        tp1['b'].convert! do |tp2|
          tp2['c'].convert! do |tp3|
            tp3['d'].convert! do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal('a'=>{'b'=>{'c'=>{'d'=>{'e'=>1}}}})

    tp = tp('a[][b][][e]=1')
    tp.convert! do |tp0|
      tp0['a'].convert! do |tp1|
        tp1[0].convert! do |tp2|
          tp2['b'].convert! do |tp3|
            tp3[0].convert! do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal('a'=>[{'b'=>[{'e'=>1}]}])
  end

  it "#convert! should handle #[] without #convert! at each level" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert! do |tp0|
      tp0['a'].convert! do |tp1|
        tp1['b']['c']['d'].convert! do |tp4|
          tp4.int('e')
        end
      end
    end.must_equal('a'=>{'b'=>{'c'=>{'d'=>{'e'=>1}}}})
  end

  it "#convert! should handle #[] without #convert! below" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert! do |tp0|
      tp0['a']['b']['c']['d'].int('e')
    end.must_equal('a'=>{'b'=>{'c'=>{'d'=>{'e'=>1}}}})
  end

  it "#convert! should handle multiple calls to #[] and #convert! below" do
    tp = tp('a[b]=2&a[c]=3&a[d]=4&a[e]=5&a[f]=6')
    tp.convert! do |tp0|
      tp0['a'].int('b')
      tp0['a'].convert! do |tp1|
        tp1.int('c')
      end
      tp0['a'].int('d')
      tp0['a'].convert! do |tp1|
        tp1.int('e')
      end
      tp0['a'].int('f')
    end.must_equal('a'=>{'b'=>2, 'c'=>3, 'd'=>4, 'e'=>5, 'f'=>6})
  end

  it "#convert! should handle defaults" do
    tp.convert! do |tp0|
      tp0.int('d', 12)
    end.must_equal('d'=>12)

    tp.convert! do |tp0|
      tp0.int(%w'a d', 12)
    end.must_equal('a'=>1, 'd'=>12)

    tp.convert! do |tp0|
      tp0.array(:int, 'g', [])
    end.must_equal('g'=>[nil])

    tp.convert! do |tp0|
      tp0.array(:int, 'j', [])
    end.must_equal('j'=>[])

    tp('a[]=1&g[]=').convert! do |tp0|
      tp0.array(:int, %w'a d g', [2])
    end.must_equal('a'=>[1], 'd'=>[2], 'g'=>[nil])
  end

  it "#convert_each! should convert each entry in an array" do
    tp = tp('a[][b]=1&a[][c]=2&a[][b]=3&a[][c]=4')
    tp['a'].convert_each! do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{'b'=>1, 'c'=>2}, {'b'=>3, 'c'=>4}]
  end

  it "#convert_each! without :keys option should convert each named entry in a hash when keys are '0'..'N'" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4')
    tp['a'].convert_each! do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{'b'=>1, 'c'=>2}, {'b'=>3, 'c'=>4}]
  end

  it "#convert_each! with :keys option should convert each named entry in a hash when keys are '0'..'N'" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4')
    tp['a'].convert_each!(:keys=>%w'0 1') do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{'b'=>1, 'c'=>2}, {'b'=>3, 'c'=>4}]
  end

  it "#convert_each! with :keys option should convert each named entry in a hash" do
    tp = tp('a[d][b]=1&a[d][c]=2&a[e][b]=3&a[e][c]=4')
    tp['a'].convert_each!(:keys=>%w'd e') do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{'b'=>1, 'c'=>2}, {'b'=>3, 'c'=>4}]
  end

  it "#convert_each! with :keys option should store entries when called inside convert" do
    tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4').convert! do |tp|
      tp['a'].convert_each!(:keys=>%w'0 1') do |tp0|
        tp0.int(%w'b c')
      end
    end.must_equal("a"=>{"0"=>{'b'=>1, 'c'=>2}, "1"=>{'b'=>3, 'c'=>4}})
  end

  it "#convert_each! :keys option should accept a Proc" do
    tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4').convert! do |tp|
      tp['a'].convert_each!(:keys=>proc{|obj| obj.keys}) do |tp0|
        tp0.int(%w'b c')
      end
    end.must_equal("a"=>{"0"=>{'b'=>1, 'c'=>2}, "1"=>{'b'=>3, 'c'=>4}})
  end

  it "#convert_each! should raise if :keys option is given and not an Array/Proc/Method" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[2][b]=3&a[2][c]=4')
    lambda{tp['a'].convert_each!(:keys=>Object.new){}}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "#convert_each! should raise if obj is a hash without '0' keys" do
    lambda{tp.convert_each!{}}.must_raise @tp_error
  end

  it "#convert_each! should raise if obj is not a hash with '0' but not '0'..'N' keys" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[2][b]=3&a[2][c]=4')
    lambda{tp['b'].convert_each!{}}.must_raise @tp_error
  end

  it "#convert_each! should raise if obj is a scalar" do
    tp = tp('a[d][b]=1&a[d][c]=2&a[e][b]=3&a[e][c]=4')
    lambda{tp['d']['b'].convert_each!{}}.must_raise @tp_error
  end

  it "#convert_each! should raise if obj is a array of non-hashes" do
    lambda{tp['b'].convert_each!{}}.must_raise @tp_error
  end

  it "#convert! with :symbolize option should return a hash of converted parameters" do
    tp = tp()
    tp.convert!(:symbolize=>true) do |ptp|
      ptp.int!('a')
      ptp.array!(:int, 'b')
      ptp['c'].convert! do |stp|
        stp.int!(%w'd e')
      end
    end.must_equal(:a=>1, :b=>[2, 3], :c=>{:d=>4, :e=>5})
  end

  it "#convert! with :symbolize option hash should only include changes made inside block" do
    tp = tp()
    tp.convert!(:symbolize=>true) do |ptp|
      ptp.int!('a')
      ptp.array!(:int, 'b')
    end.must_equal(:a=>1, :b=>[2, 3])

    tp.convert!(:symbolize=>true) do |ptp|
      ptp['c'].convert! do |stp|
        stp.int!(%w'd e')
      end
    end.must_equal(:c=>{:d=>4, :e=>5})
  end

  it "#convert! with :symbolize option should handle deeply nested structures" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].convert! do |tp1|
        tp1['b'].convert! do |tp2|
          tp2['c'].convert! do |tp3|
            tp3['d'].convert! do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal(:a=>{:b=>{:c=>{:d=>{:e=>1}}}})

    tp = tp('a[][b][][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].convert! do |tp1|
        tp1[0].convert! do |tp2|
          tp2['b'].convert! do |tp3|
            tp3[0].convert! do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal(:a=>[{:b=>[{:e=>1}]}])
  end

  it "#convert! with :symbolize option should handle #[] without #convert! at each level" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].convert! do |tp1|
        tp1['b']['c']['d'].convert! do |tp4|
          tp4.int('e')
        end
      end
    end.must_equal(:a=>{:b=>{:c=>{:d=>{:e=>1}}}})
  end

  it "#convert! with :symbolize option should handle #[] without #convert! below" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a']['b']['c']['d'].int('e')
    end.must_equal(:a=>{:b=>{:c=>{:d=>{:e=>1}}}})
  end

  it "#convert! with :symbolize option should handle multiple calls to #[] and #convert! below" do
    tp = tp('a[b]=2&a[c]=3&a[d]=4&a[e]=5&a[f]=6')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].int('b')
      tp0['a'].convert! do |tp1|
        tp1.int('c')
      end
      tp0['a'].int('d')
      tp0['a'].convert! do |tp1|
        tp1.int('e')
      end
      tp0['a'].int('f')
    end.must_equal(:a=>{:b=>2, :c=>3, :d=>4, :e=>5, :f=>6})
  end

  it "#convert! with :symbolize option should handle defaults" do
    tp.convert!(:symbolize=>true) do |tp0|
      tp0.int('d', 12)
    end.must_equal(:d=>12)

    tp.convert!(:symbolize=>true) do |tp0|
      tp0.int(%w'a d', 12)
    end.must_equal(:a=>1, :d=>12)

    tp.convert!(:symbolize=>true) do |tp0|
      tp0.array(:int, 'g', [])
    end.must_equal(:g=>[nil])

    tp.convert!(:symbolize=>true) do |tp0|
      tp0.array(:int, 'j', [])
    end.must_equal(:j=>[])

    tp('a[]=1&g[]=').convert!(:symbolize=>true) do |tp0|
      tp0.array(:int, %w'a d g', [2])
    end.must_equal(:a=>[1], :d=>[2], :g=>[nil])
  end

  it "#convert_each! with :symbolize option should convert each entry in an array" do
    tp = tp('a[][b]=1&a[][c]=2&a[][b]=3&a[][c]=4')
    tp['a'].convert_each!(:symbolize=>true) do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{:b=>1, :c=>2}, {:b=>3, :c=>4}]
  end

  it "#convert_each! with :symbolize and :keys options should convert each named entry in a hash" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4')
    tp['a'].convert_each!(:keys=>%w'0 1', :symbolize=>true) do |tp0|
      tp0.int(%w'b c')
    end.must_equal [{:b=>1, :c=>2}, {:b=>3, :c=>4}]
  end

  it "#convert_each! with :symbolize and :keys options should store entries when called inside convert" do
    tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4').convert!(:symbolize=>true) do |tp|
      tp['a'].convert_each!(:keys=>%w'0 1') do |tp0|
        tp0.int(%w'b c')
      end
    end.must_equal(:a=>{:'0'=>{:b=>1, :c=>2}, :'1'=>{:b=>3, :c=>4}})
  end

  it "#convert! with :symbolize options specified at different levels should work" do
    tp = tp('a[b][c][d][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].convert!(:symbolize=>false) do |tp1|
        tp1['b'].convert!(:symbolize=>true) do |tp2|
          tp2['c'].convert!(:symbolize=>false) do |tp3|
            tp3['d'].convert!(:symbolize=>true) do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal(:a=>{'b'=>{:c=>{'d'=>{:e=>1}}}})

    tp = tp('a[][b][][e]=1')
    tp.convert!(:symbolize=>true) do |tp0|
      tp0['a'].convert! do |tp1|
        tp1[0].convert!(:symbolize=>false) do |tp2|
          tp2['b'].convert! do |tp3|
            tp3[0].convert!(:symbolize=>true) do |tp4|
              tp4.int('e')
            end
          end
        end
      end
    end.must_equal(:a=>[{'b'=>[{:e=>1}]}])
  end

  it "#dig should return nested values or nil if there is no value" do
    tp = tp('a[b][c][d][e]=1&b=2')
    tp.dig(:int, 'a', 'b', 'c', 'd', 'e').must_equal 1
    tp.dig(:int, 'b').must_equal 2
    tp.dig(:int, 'a', 0, 'c', 'd', 'e').must_be_nil
    tp.dig(:int, 'a', 'd', 'c', 'd', 'e').must_be_nil
    tp.dig(:int, 'a', 'b', 'c', 'd', 'f').must_be_nil
    tp.dig(:int, 'c').must_be_nil
    tp.dig(:int, 'c', 'd').must_be_nil

    tp = tp('a[][c][][e]=1')
    tp.dig(:int, 'a', 0, 'c', 0, 'e').must_equal 1
    tp.dig(:int, 'a', 1, 'c', 0, 'e').must_be_nil
    tp.dig(:int, 'a', 'b', 'c', 0, 'e').must_be_nil
    tp.dig(:int, 'a', 0, 'c', 0, 'f').must_be_nil
  end

  it "#dig should raise when accessing past the end of the expected structure" do
    tp = tp('a[b][c][d][e]=1&b=2')
    lambda{tp.dig(:int, 'a', 'b', 'c', 'd', 'e', 'f')}.must_raise @tp_error
    lambda{tp.dig(:int, 'b', 'c')}.must_raise @tp_error

    tp = tp('a[][c][][e]=1')
    lambda{tp.dig(:int, 'a', 0, 'c', 0, 'e', 'f')}.must_raise @tp_error
  end

  it "#dig and #dig! should handle array keys" do
    tp('a[b][c][d][e]=1&a[b][c][d][f]=2').dig(:int, 'a', 'b', 'c', 'd', %w'e f').must_equal [1, 2]
    tp('a[b][c][d][e]=1&a[b][c][d][f]=').dig(:int, 'a', 'b', 'c', 'd', %w'e f').must_equal [1, nil]

    tp('a[b][c][d][e]=1&a[b][c][d][f]=2').dig!(:int, 'a', 'b', 'c', 'd', %w'e f').must_equal [1, 2]
    lambda{tp('a[b][c][d][e]=1&a[b][c][d][f]=').dig!(:int, 'a', 'b', 'c', 'd', %w'e f')}.must_raise @tp_error
  end

  it "#dig and #dig! should be able to handle arrays using an array for the type" do
    tp('a[b][c][d][]=1&a[b][c][d][]=2').dig(:array, :int, 'a', 'b', 'c', 'd').must_equal [1, 2]
    tp('a[b][c][d][]=1&a[b][c][d][]=').dig(:array, :int, 'a', 'b', 'c', 'd').must_equal [1, nil]

    tp('a[b][c][d][]=1&a[b][c][d][]=2').dig!(:array!, :int, 'a', 'b', 'c', 'd').must_equal [1, 2]
    lambda{tp('a[b][c][d][]=1&a[b][c][d][]=').dig!(:array!, :int, 'a', 'b', 'c', 'd')}.must_raise @tp_error
  end

  it "#dig should raise for unsupported types" do
    lambda{tp.dig(:foo, 'a')}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "#dig should raise for array without subtype" do
    lambda{tp.dig(:array, 'foo', 'a')}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end


  it "#dig should raise for unsupported nest values" do
    lambda{tp.dig(:int, :foo, 'a')}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
    lambda{tp.dig(:array, :int, :foo, 'a')}.must_raise Roda::RodaPlugins::TypecastParams::ProgrammerError
  end

  it "#dig! should return nested values or raise Error if thers is no value" do
    tp = tp('a[b][c][d][e]=1&b=2')
    tp.dig!(:int, 'a', 'b', 'c', 'd', 'e').must_equal 1
    tp.dig!(:int, 'b').must_equal 2
    lambda{tp.dig!(:int, 'a', 'd', 'c', 'd', 'e')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'a', 'b', 'c', 'd', 'f')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'a', 0, 'c', 'd', 'f')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'c')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'b', 'c')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'c', 'd')}.must_raise @tp_error
    error{tp.dig!(:int, 'a', 'd', 'c', 'd', 'e')}.keys.must_equal %w'a d'
    error{tp.dig!(:int, 'a', 'b', 'c', 'e', 'e')}.keys.must_equal %w'a b c e'

    tp = tp('a[][c][][e]=1')
    tp.dig!(:int, 'a', 0, 'c', 0, 'e').must_equal 1
    lambda{tp.dig!(:int, 'a', 1, 'c', 0, 'e')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'a', 'b', 'c', 0, 'e')}.must_raise @tp_error
    lambda{tp.dig!(:int, 'a', 0, 'c', 0, 'f')}.must_raise @tp_error
  end

  it "#convert! should work with dig" do
    tp('a[b][c][d][e]=1').convert! do |tp|
      tp.dig(:int, 'a', 'b', 'c', 'd', 'e')
    end.must_equal('a'=>{'b'=>{'c'=>{'d'=>{'e'=>1}}}})
  end

  it "#convert! with :symbolize option should work with dig" do
    tp('a[b][c][d][e]=1').convert!(:symbolize=>true) do |tp|
      tp.dig(:int, 'a', 'b', 'c', 'd', 'e')
    end.must_equal(:a=>{:b=>{:c=>{:d=>{:e=>1}}}})
  end

  it "#fetch should be the same as #[] if the key is present" do
    tp.fetch('c').int('d').must_equal 4
  end

  it "#fetch should return nil if the key is not present and no block is given" do
    tp.fetch('d').must_be_nil
  end

  it "#fetch should call the block if the key is not present and a block is given" do
    tp.fetch('d'){1}.must_equal 1
  end

  it "Error#keys should be a path to the error" do
    error{tp.int!('b')}.keys.must_equal ['b']
    error{tp.int!(%w'b f')}.keys.must_equal ['b']
    error{tp['c'].int!('f')}.keys.must_equal ['c', 'f']
    error{tp('a[b][c][d][e]=1')['a']['b']['c']['d'].date('e')}.keys.must_equal %w'a b c d e'
  end

  it "Error#param_name should be the name of the parameter" do
    error{tp.int!('b')}.param_name.must_equal 'b'
    error{tp.int!(%w'b f')}.param_name.must_equal 'b'
    error{tp['c'].int!('f')}.param_name.must_equal 'c[f]'
    error{tp('a[b][c][d][e]=1')['a']['b']['c']['d'].date('e')}.param_name.must_equal 'a[b][c][d][e]'
    error{tp('a[][c][][e]=1')['a'][0]['c'][0].date('e')}.param_name.must_equal 'a[][c][][e]'
    error{tp('a[][c][][e]=1').dig(:date, 'a', 0, 'c', 0, 'e')}.param_name.must_equal 'a[][c][][e]'
  end

  it "Error#param_names and #reason should be correct for errors" do
    e = error{tp.int!('b')}
    e.param_names.must_equal ['b']
    e.reason.must_equal :int

    e = error{tp.int!(%w'b f')}
    e.param_names.must_equal ['b']
    e.reason.must_equal :int

    e = error{tp['c'].int!('f')}
    e.param_names.must_equal ['c[f]']
    e.reason.must_equal :missing

    e = error{tp('a[b][c][d][e]=1')['a']['b']['c']['d'].date('e')}
    e.param_names.must_equal ['a[b][c][d][e]']
    e.reason.must_equal :date

    e = error{tp('a[][c][][e]=1')['a'][0]['c'][0].date('e')}
    e.param_names.must_equal ['a[][c][][e]']
    e.reason.must_equal :date

    e = error{tp('a[][c][][e]=1').dig(:date, 'a', 0, 'c', 0, 'e')}
    e.param_names.must_equal ['a[][c][][e]']
    e.reason.must_equal :date

    e = error{tp('a[][c][][e]=1').dig!(:date, 'a', 1, 'c', 0, 'e')}
    e.param_names.must_equal ['a[]']
    e.reason.must_equal :missing

    e = error{tp('a[][c][][e]=1').dig!(:date, 'a', 'b', 'c', 0, 'e')}
    e.param_names.must_equal ['a[b]']
    e.reason.must_equal :invalid_type
  end

  it "Error#param_names and #all_errors should handle array submission" do
    tp = tp('a[][b]=0')
    e = error do 
      tp.convert!('a') do |tp0|
        tp0.int(%w'a b c')
        tp0.array(:int, %w'a b c')
      end
    end
    e.param_names.must_equal %w'a'
    e.all_errors.map(&:reason).must_equal [:invalid_type]
  end

  it "Error#param_names and #all_errors should include all errors raised in convert! blocks" do
    tp = tp('a[][b][][e]=0')
    e = error do 
      tp.convert! do |tp0|
        tp0['a'].convert! do |tp1|
          tp1[0].convert! do |tp2|
            tp2['b'].convert! do |tp3|
              tp3[0].convert! do |tp4|
                tp4.pos_int!('e')
              end
            end
          end
        end
        tp0.dig!(:pos_int, 'a', 0, 'b', 0, %w'f g')
        tp0.dig!(:pos_int, 'a', 0, 'b')
        tp0.int!('c')
        tp0.array!(:int, %w'd e')
        tp0['b']
      end
    end
    e.param_names.must_equal %w'a[][b][][e] a[][b][][f] a[][b][][g] a[][b] c d e b'
    e.all_errors.map(&:reason).must_equal [:missing, :missing, :missing, :pos_int, :missing, :missing, :missing, :missing]
  end

  it "Error#param_names and #all_errors should handle #[] failures by skipping the rest of the block" do
    tp = tp('a[][b][][e]=0')
    e = error do 
      tp.convert! do |tp0|
        tp0['b']
        tp0.int!('c')
      end
    end
    e.param_names.must_equal %w'b'
    e.all_errors.map(&:reason).must_equal [:missing]

    e = error do 
      tp.convert! do |tp0|
        tp0['a'][0].convert! do |tp1|
          tp1['c']
          tp1.int!('d')
        end
        tp0.int!('c')
      end
    end
    e.param_names.must_equal %w'a[][c] c'
    e.all_errors.map(&:reason).must_equal [:missing, :missing]
  end

  it "Error#param_names and #all_errorsshould handle array! with array of keys where one of the keys is not present" do
    e = error do
      tp('e[]=0').convert! do |tp0|
        tp0.array!(:pos_int, %w'd e')
      end
    end
    e.param_names.must_equal %w'd e'
    e.all_errors.map(&:reason).must_equal [:missing, :invalid_type]
  end

  it "Error#param_names and #all_errors should handle keys given to convert" do
    tp = tp('e[][b][][e]=0')
    e = error do 
      tp.convert! do |tp0|
        tp0.convert!(['a', 0, 'b', 0]) do |tp1|
          tp1.pos_int!('e')
        end
        tp0.convert!('f') do |tp1|
          tp1.dig!(:pos_int, 0, 'b', 0, %w'f g')
        end
        tp0.dig!(:pos_int, 'e', 0, 'b')
        tp0.int!('c')
        tp0.array!(:int, 'd')
      end
    end
    e.param_names.must_equal %w'a f e[][b] c d'
    e.all_errors.map(&:reason).must_equal [:missing, :missing, :pos_int, :missing, :missing]
  end

  it "Error#param_names and #all_errors should include all errors raised in convert_each! blocks" do
    e = error do 
      tp('a[][b]=0&a[][b]=1')['a'].convert_each! do |tp0|
        tp0.dig!(:pos_int, 'b', 0, 'e')
        tp0.dig!(:int, 'b', 0, %w'f g')
        tp0.int!(%w'd e')
        tp0.pos_int!('b')
        tp0['c']
      end
    end
    e.param_names.must_equal %w'a[][b] a[][b] a[][d] a[][e] a[][b] a[][c] a[][b] a[][b] a[][d] a[][e] a[][c]'
    e.all_errors.map(&:reason).must_equal [:invalid_type, :invalid_type, :missing, :missing, :missing, :missing, :invalid_type, :invalid_type, :missing, :missing, :missing]
  end

  it "Error#param_names and #all_errors should include all errors for invalid keys used in convert_each!" do
    tp = tp('a[0][b]=1&a[0][c]=2&a[1][b]=3&a[1][c]=4')
    e = error do
      tp['a'].convert_each!(:keys=>%w'0 2 3') do |tp0|
        tp0.int(%w'b c')
      end
    end
    e.param_names.must_equal %w'a[2] a[3]'
    e.all_errors.map(&:reason).must_equal [:missing, :missing]
  end
end

describe "typecast_params plugin with customized params" do 
  def tp(arg='a=1&b[]=2&b[]=3&c[d]=4&c[e]=5&f=&g[]=&h[i]=')
    @tp.call(arg)
  end

  before do
    res = nil
    app(:bare) do
      plugin :typecast_params do
        handle_type(:opp_int) do |v|
          -v.to_i
        end
      end
      plugin :typecast_params do
        handle_type(:double) do |v|
          v*2
        end
      end

      route do |r|
        res = typecast_params
        nil
      end
    end

    @tp = lambda do |params|
      req('QUERY_STRING'=>params, 'rack.input'=>StringIO.new)
      res
    end

    @tp_error = Roda::RodaPlugins::TypecastParams::Error
  end

  it "should not allow typecast params changes after freezing the app" do
    app.freeze
    lambda{app::TypecastParams.handle_type(:foo){|v| v}}.must_raise RuntimeError
  end

  it "should pass through non-ArgumentError exceptions raised by conversion blocks" do
    app::TypecastParams.handle_type(:foo){|v| raise}
    lambda{tp.foo('a')}.must_raise RuntimeError
  end

  it "should respect custom typecasting methods" do
    tp.opp_int('a').must_equal(-1)
    tp.opp_int!('a').must_equal(-1)
    tp.opp_int('d').must_be_nil
    lambda{tp.opp_int!('d')}.must_raise @tp_error

    tp.array(:opp_int, 'b').must_equal [-2, -3]
    tp.array!(:opp_int, 'b').must_equal [-2, -3]

    tp.double('a').must_equal '11'
    tp.double!('a').must_equal '11'
    tp.double('d').must_be_nil
    lambda{tp.double!('d')}.must_raise @tp_error

    tp.array(:double, 'b').must_equal ['22', '33']
    tp.array!(:double, 'b').must_equal ['22', '33']
  end

  it "should respect custom typecasting methods when subclassing" do
    @app = Class.new(@app)
    @app.plugin :typecast_params do
      handle_type :triple do |v|
        v * 3
      end
    end

    tp.opp_int('a').must_equal(-1)
    tp.opp_int!('a').must_equal(-1)
    tp.opp_int('d').must_be_nil
    lambda{tp.opp_int!('d')}.must_raise @tp_error

    tp.array(:opp_int, 'b').must_equal [-2, -3]
    tp.array!(:opp_int, 'b').must_equal [-2, -3]

    tp.double('a').must_equal '11'
    tp.double!('a').must_equal '11'
    tp.double('d').must_be_nil
    lambda{tp.double!('d')}.must_raise @tp_error

    tp.array(:double, 'b').must_equal ['22', '33']
    tp.array!(:double, 'b').must_equal ['22', '33']

    tp.triple('a').must_equal '111'
    tp.triple!('a').must_equal '111'
    tp.triple('d').must_be_nil
    lambda{tp.triple!('d')}.must_raise @tp_error

    tp.array(:triple, 'b').must_equal ['222', '333']
    tp.array!(:triple, 'b').must_equal ['222', '333']
  end
end

describe "typecast_params plugin with files" do 
  def tp
    @tp.call
  end

  before do
    tempfile = @tempfile = Tempfile.new(['roda_typecast_params_spec', '.txt'])
    tempfile.write('tp_spec')
    tempfile.rewind
    res = nil
    app(:typecast_params) do |r|
      res = typecast_params
      nil
    end
    app::RodaRequest.send(:define_method, :params) do
      {'testfile'=>{:tempfile=>tempfile}, 'testfile2'=>{:tempfile=>tempfile},
       'testfile_array'=>[{:tempfile=>tempfile}, {:tempfile=>tempfile}],
       'a'=>{'b'=>'c', 'tempfile'=>'f'},
       'c'=>['']}
    end

    @tp = lambda do
      req
      res
    end

    @tp_error = Roda::RodaPlugins::TypecastParams::Error
  end

  it "#file should require an uploaded file" do
    tp.file('testfile').must_equal(:tempfile=>@tempfile)
    tp.file(%w'testfile testfile2').must_equal [{:tempfile=>@tempfile}, {:tempfile=>@tempfile}]

    lambda{tp.file('a')}.must_raise @tp_error
    tp.file('b').must_be_nil
    lambda{tp.file('c')}.must_raise @tp_error

    tp.file!('testfile').must_equal(:tempfile=>@tempfile)
    tp.file!(%w'testfile testfile2').must_equal [{:tempfile=>@tempfile}, {:tempfile=>@tempfile}]
    lambda{tp.file!('a')}.must_raise @tp_error
    lambda{tp.file!('b')}.must_raise @tp_error
    lambda{tp.file!('c')}.must_raise @tp_error

    tp.array(:file, 'testfile_array').must_equal [{:tempfile=>@tempfile}, {:tempfile=>@tempfile}]
    lambda{tp.array(:file, 'testfile')}.must_raise @tp_error
    lambda{tp.array(:file, 'a')}.must_raise @tp_error
    tp.array(:file, 'b').must_be_nil
    lambda{tp.array(:file, 'c')}.must_raise @tp_error

    tp.array!(:file, 'testfile_array').must_equal [{:tempfile=>@tempfile}, {:tempfile=>@tempfile}]
    lambda{tp.array!(:file, 'testfile')}.must_raise @tp_error
    lambda{tp.array!(:file, 'a')}.must_raise @tp_error
    lambda{tp.array!(:file, 'b')}.must_raise @tp_error
    lambda{tp.array!(:file, 'c')}.must_raise @tp_error
  end
end

describe "typecast_params plugin with strip: :all option" do 
  def tp(arg='a=+1+')
    @tp.call(arg)
  end


  before do
    res = nil
    app(:bare) do
      plugin :typecast_params, strip: :all
      route do |r|
        res = typecast_params
        nil
      end
    end

    @tp = lambda do |params|
      req('QUERY_STRING'=>params, 'rack.input'=>StringIO.new)
      res
    end

    @tp_error = Roda::RodaPlugins::TypecastParams::Error
  end

  it "#file should require an uploaded file" do
    tp.str('a').must_equal '1'
    tp.nonempty_str('a').must_equal '1'
    tp.int('a').must_equal 1
    tp.pos_int('a').must_equal 1
    tp.Integer('a').must_equal 1
    tp.float('a').must_equal 1.0
    tp.Float('a').must_equal 1.0
  end
end
