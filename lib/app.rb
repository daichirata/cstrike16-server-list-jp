require 'sinatra'
require 'erb'
require 'sass'
require 'coffee-script'
require 'dalli'
require 'active_support/all'

module CStrike
  class App < Sinatra::Base
    set :views, APP_ROOT + '/views'
    set :public_folder, APP_ROOT + '/public'

    get '/' do
      @server_list = CStrike::JPServer::list
      erb :index
    end

    get '/stylesheet.css' do
      scss :stylesheet
    end

    get '/application.js' do
      coffee :application
    end
  end
end

require 'cstrike/jp_server'
