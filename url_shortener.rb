#!/usr/bin/env ruby
require 'sinatra'
require 'mongoid'
require 'byebug'
require './models/shortcut'
require './lib/application_error'
require 'sinatra/flash'
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
    if shortcut.valid?
      shortcut.add_to_session(session, uri('/'))
      redirect '/shortcuts/new'
    else
      @shortcuts = session[:shortcuts]
      @shortcut = shortcut
      flash.now[:error] = "Sorry, something is wrong with your input. Please try again"
      erb :new, layout: true
    end
  end

  get "/:token" do
    token = params[:token]
    begin
      shortcut = Shortcut.find_by(token: token)
    rescue
      logger.info('request for unknown token')
      flash.next[:error] = "Sorry, you requested a short url '#{token}' that is not a saved. Do you want to generate a short url?"
      redirect '/shortcuts/new'
    end
    redirect shortcut.long_url_with_protocol
  end

  error do
    erb(:error)
  end
end