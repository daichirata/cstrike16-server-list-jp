require 'sinatra'

module CStrike
  APP_ROUTE      = File.expand_path('..', File.dirname(__FILE__))

  class App
    get '/' do
      'Hello world!'
    end
  end
end

require 'cstrike/jp_server'

