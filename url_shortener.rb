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
    shortcut = Shortcut.create_unique_token(long_url)
    shortcut.add_to_session(session, uri('/'))
    redirect '/shortcuts/new'
  end
end