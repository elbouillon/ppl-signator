# encoding: utf-8

class OrderFile
  include ActiveAttr::Model
  include ApplicationHelper

  SIGNATORS = {
  "André Kurmann" => "André Kurmann",
  "Mickael Kurmann" => "Mickael Kurmann"
  }

  attribute :signator
  attribute :delivery_date

  validate :uploaded_file_is_a_pdf
  validates :delivery_date, presence: true

  def to_s
    "#{@original_filename} - #{@content_type}"
  end

  def render_file
    Prawn::Document.new(:template => @tempfile) do |pdf|
      require "prawn/measurement_extensions"

      pdf.go_to_page(pdf.page_count)
      pdf.font_size 16

      pdf.move_down 20.cm

      pdf.text "Bon pour accord de fabrication"
      pdf.text "Panorama Profil line SA"
      pdf.text "La Sarraz, le #{I18n.l(Date.today, format: :long)} - #{signator}"

      pdf.move_down 1.cm

      pdf.fill_color "D3482D"
      pdf.font_size(20){
        pdf.text "Date de livraison : #{return_display_name_from_date(delivery_date.to_date)}"
      }
    end.render
  end

  def upload=(upload_file)
    @original_filename = upload_file.original_filename
    @content_type= upload_file.content_type
    @tempfile= upload_file.tempfile
  end

  def name
    @original_filename.to_s[0..-5]
  end

  def filename
    n = /(\d{2}\-\w*)|(\d{7})/.match(name)
    "#{n}-confirmation".parameterize + ".pdf"
  end

  private

  def uploaded_file_is_a_pdf
    if @content_type != "application/pdf"
      errors.add :upload, "Eh moque! Je ne signe que les PDF, un peu de rigueur"
    end
  end
end
