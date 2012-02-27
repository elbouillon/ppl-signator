class OrderFilesController < ApplicationController
  def new
    @order_file = OrderFile.new
  end

  def create
    @order_file = OrderFile.new(params[:order_file])

    if @order_file.valid?
      send_data @order_file.render_file, filename: @order_file.filename, type: "application/pdf"
    else
      render :new
    end
  end
end
