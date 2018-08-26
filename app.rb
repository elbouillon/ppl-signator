require(File.expand_path('trailblazer-config', File.dirname(__FILE__)))
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

  plugin :csrf
  plugin :public

  route do |r|
    r.public

    r.root do
      Homepage::Cell::Show.(nil).()
    end

    r.post 'pdf/sign' do |year|
      # @order_file = OrderFile.new(params[:order_file])
      # send_data @order_file.render_file, 
      #   filename: @order_file.filename,
      #   type: "application/pdf"
      'super pdf signe'
    end
  end
end
