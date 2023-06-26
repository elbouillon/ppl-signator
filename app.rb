# frozen_string_literal: true

require_relative 'signator'
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

  route do |r|
    r.public

    r.root do
      render :show
    end

    r.post 'pdf/sign' do |_year|
      r.redirect '/' if r.params['pdf_to_sign'].nil?

      response['Content-Type'] = 'application/pdf'
      response['Content-Disposition'] =
        "attachment; filename=#{Signator.confirmation_name(r.params['pdf_to_sign'][:filename],
                                                           r.params['delivery_date'])}"
      Signator.new.call(r.params)
    end

    r.on do
      r.redirect '/'
    end
  end
end
