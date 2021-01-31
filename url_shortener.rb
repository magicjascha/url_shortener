require 'sinatra'
require 'mongoid'
require 'byebug'
require './models/shortcut.rb'
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

class UrlShortener < Sinatra::Application
  enable :sessions

  get '/' do
    redirect '/shortcuts/new'
  end

  get '/shortcuts/new' do
    @shortcuts = session[:shortcuts]
    erb :new
  end

  post '/shortcuts' do
    long_url = params["long_url"]
    token = long_url[-8..-1]
    Shortcut.create(token: token, long_url: long_url)
    session[:shortcuts] = {} unless session[:shortcuts]
    session[:shortcuts][token] = long_url
    redirect '/shortcuts/new'
  end
end