require "minitest_helper"

class OrderFile
  def initialize(txt = "Swissbau-12-0381.pdf")
    @txt = txt
  end

  def name
    @txt[0..-5]
  end
end

describe OrderFile do
  it "should return a filename ended by confirmation for fenstherm number" do
    of = OrderFile.new
    of.delivery_date = Date.new(2012,11,9)
    of.filename.must_equal "12-0381-lw1245-confirmation.pdf"
    of = OrderFile.new("Swissbau-12-0381 (2).pdf")
    of.delivery_date = Date.new(2012,11,9)
    of.filename.must_equal "12-0381-lw1245-confirmation.pdf"
  end

  it "should return a filename ended by confirmation for premier number" do
    of = OrderFile.new("Swissbau-7250755-D12-0855 Ravallec.pdf")
    of.delivery_date = Date.new(2012,11,9)
    of.filename.must_equal "7250755-lw1245-confirmation.pdf"
  end
end
