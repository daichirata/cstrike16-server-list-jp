require 'sinatra'
require 'erb'
require 'sass'
# require 'coffee-script'
require 'dalli'
require 'active_support/all'

module CStrike
  class App < Sinatra::Base
    set :views, APP_ROOT + '/views'
    set :public_folder, APP_ROOT + '/public'
    use Rack::CommonLogger, Logger.new(APP_ROOT + '/tmp/myapp.log')

    get '/' do
      @server_list = CStrike::JPServer::get_list
      erb :index
    end

    get '/reload' do
      begin
        CStrike::JPServer::cache
      ensure
        redirect '/'
      end
    end

    get '/info/:host/:port' do
      @server_info = CStrike::JPServer::get_info(params[:host], params[:port])
      erb :info
    end

    get '/stylesheet.css' do
      scss :stylesheet
    end

    # get '/application.js' do
    #   coffee :application
    # end
  end
end

require 'cstrike/jp_server'
