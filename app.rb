# frozen_string_literal: true

require 'dotenv/load' if ENV['RACK_ENV'] == 'developpment'

require_relative 'db'
require_relative 'models/work'

require_relative 'signator'
require_relative 'attestator'

require_relative 'views/helpers'

require 'roda'

class PplSignator < Roda
  plugin :default_headers,
         'Content-Type' => 'text/html',
         # 'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block',
         'Accept-Charset' => 'utf-8'

  plugin :public
  plugin :render, engine: 'haml'
  plugin :sinatra_helpers

  route do |r|
    r.public

    r.root do
      render :show
    end

    r.post 'pdf/sign' do
      r.redirect '/' if r.params['pdf_to_sign'].nil?

      # response['Content-Type'] = 'application/pdf'
      # response['Content-Disposition'] =
      #   "attachment; filename=#{Signator.confirmation_name(r.params['pdf_to_sign'][:filename],
      #                                                      r.params['delivery_date'])}"

      fname = r.params['pdf_to_sign'][:filename]
      delivery_date = r.params['delivery_date']

      # Signator.new.call(r.params)
      send_file Signator.new.call(r.params),
                disposition: 'attachment',
                filename: Signator.confirmation_name(fname, delivery_date),
                type: 'application/pdf'
    end

    r.is 'attestations/sigab', Integer do |work_id|
      work = Work.where(id: work_id).association_join(:customer).qualify.first
      # need to find the work
      send_file Attestator.new.call(work),
                disposition: 'attachment',
                filename: 'attestation_sigab_securit.pdf',
                type: 'application/pdf'
    end

    r.on do
      r.redirect '/'
    end
  end
end
