Encoding.default_external = Encoding::UTF_8
# Encoding.default_internal = Encoding::UTF_8

require(File.expand_path('trailblazer-config', File.dirname(__FILE__)))
require_relative 'signator'
require 'roda'

class PplSignator < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    # 'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block',
    'Accept-Charset'=>'utf-8'

  secret = ENV['SESSION_SECRET'] || 'lkjasdfsaflkjdsajfldsajflkdsafj'
  use Rack::Session::Cookie,
    :key => '_PplSignator_session',
    #:secure=>!TEST_MODE, # Uncomment if only allowing https:// access
    :secret=> secret

  plugin :route_csrf
  plugin :public
  # plugin :status_handler

  # status_handler(404) do
  #   route.redirect :root
  # end

  route do |r|
    r.public

    r.root do
      Homepage::Cell::Show.(nil).()
    end

    r.post 'pdf/sign' do |year|
      r.redirect '/' if r.params['pdf_to_sign'] == nil

      response['Content-Type'] = 'application/pdf'
      response['Content-Disposition'] = "attachment; filename=#{Signator.confirmation_name(r.params['pdf_to_sign'][:filename], r.params['delivery_date'])}"
      Signator.new.(r.params)
    end

    r.on do
      r.redirect '/'
    end

  end
end
