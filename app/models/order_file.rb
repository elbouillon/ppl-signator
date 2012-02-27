# encoding: utf-8

class OrderFile
  include ActiveAttr::Model

  SIGNATORS = {
  "ak" => "André Kurmann",
  "mk" => "Mickael Kurmann"
  }

  attribute :file
  attribute :signator

  attr_accessible :file, :signator

  validates_presence_of :file, :signator

  def save?
    true
  end
end
