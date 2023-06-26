require 'prawn'
require 'combine_pdf'

class Signator
  def call(params)
    file = params['pdf_to_sign'][:tempfile]

    # CREER la SIGNATURE
    signature = Prawn::Document.new do |pdf|
      require 'prawn/measurement_extensions'
      pdf.font_size 13

      pdf.move_down 22.cm

      pdf.text 'Bon pour accord de fabrication'
      pdf.text 'Panorama Profil line SA'
      pdf.text "La Sarraz, le #{Date.today.strftime('%d.%m.%Y')} - #{params.fetch('signator')}"

      pdf.move_down 5.mm

      pdf.fill_color 'D3482D'
      pdf.font_size(20) do
        # pdf.text "Date de livraison : #{return_display_name_from_date(delivery_date.to_date)}"
        pdf.text "Semaine de livraison : #{Signator.confirmation_date(params.fetch('delivery_date'))}"
      end
    end.render

    company_logo = CombinePDF.parse(signature).pages[0]
    # lire le pdf uploade
    pdf = CombinePDF.load file.path
    # merger le tout et retour
    pdf.pages.last << company_logo
    pdf.to_pdf
  end

  def self.confirmation_date(delivery_date)
    "LW#{Date.parse(delivery_date).strftime('%g.%V')}"
  end

  def self.confirmation_name(filename, delivery_date)
    n = /(\d{2}-\w*)|(\d{7})/.match(filename)
    "#{n}-#{confirmation_date(delivery_date)}-confirmation.pdf"
  end
end
