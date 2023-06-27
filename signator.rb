# frozen_string_literal: true

require 'hexapdf'

class Signator
  def call(params)
    file = params['pdf_to_sign'][:tempfile]

    filename = File.join(File.dirname(__FILE__), 'accord_fabrication.pdf')

    doc = HexaPDF::Document.open(file.path)

    canvas = doc.pages[-1].canvas(type: :overlay)

    box = HexaPDF::Layout::Box.create(
      width: 400, height: 80, content_box: true,
      border: { width: 4, style: :solid },
      background_color: [189, 231, 0]
    )

    box.draw(canvas, 20, 20)

    canvas.font('Helvetica', variant: :bold, size: 16)
    canvas.text 'Bon pour accord de fabrication', at: [40, 80]
    canvas.font('Helvetica', size: 13)
    canvas.text 'Panorama Profil line SA', at: [40, 60]
    canvas.text "La Sarraz, le #{Date.today.strftime('%d.%m.%Y')} - #{params.fetch('signator')}", at: [40, 40]
    #   pdf.font_size(20) do
    #     # pdf.text "Date de livraison : #{return_display_name_from_date(delivery_date.to_date)}"
    #     pdf.text "Semaine de livraison : #{Signator.confirmation_date(params.fetch('delivery_date'))}"
    #   end

    doc.write(filename, optimize: true)

    filename
  end

  def self.confirmation_date(delivery_date)
    "LW#{Date.parse(delivery_date).strftime('%g.%V')}"
  end

  def self.confirmation_name(filename, delivery_date)
    n = /(\d{2}-\w*)|(\d{7})/.match(filename)
    "#{n}-#{confirmation_date(delivery_date)}-confirmation.pdf"
  end
end
