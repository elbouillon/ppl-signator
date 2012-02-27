class SignerController < ApplicationController
  def new
    @order_file = OrderFile.new
  end

  def create
  end
end
