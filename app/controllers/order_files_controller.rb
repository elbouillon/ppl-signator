class OrderFilesController < ApplicationController
  def new
    @order_file = OrderFile.new
  end

  def create
    @order_file = OrderFile.new(params[:order_file])
    if @order_file.save?
      render :text => "return file"
    else
      render :new
    end
  end
end
