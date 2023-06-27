# frozen_string_literal: true

class Attestator
  def call(work)
    file = File.join(File.dirname(__FILE__), 'templates', 'sigab_securite_template.pdf')
    filename = File.join(File.dirname(__FILE__), 'attestation.pdf')

    doc = HexaPDF::Document.open(file)

    canvas = doc.pages.first.canvas(type: :overlay)

    canvas.font('Times', variant: :bold, size: 13)
    canvas.text work.customer.name, at: [99, 685]

    canvas.font('Times', size: 13)
    canvas.text "La Sarraz, le #{Date.today.strftime('%d.%m.%Y')}", at: [435, 685]

    customer_address = "#{work.customer.address.street}\n#{work.customer.address.zip} #{work.customer.address.city}"
    canvas.text customer_address, at: [99, 670]

    canvas.font('Helvetica', variant: :bold, size: 15).fill_color(23, 159, 219)
    workidname = "W##{work.id} #{work.name}"
    canvas.text workidname.upcase, at: [99, 520]

    work_address = "#{work.place.address.street} - #{work.place.address.zip} #{work.place.address.city}"
    canvas.font('Helvetica', size: 10).fill_color(102, 102, 102)
    canvas.text work_address.upcase, at: [99, 505]

    doc.write(filename, optimize: true)

    filename
  end
end
