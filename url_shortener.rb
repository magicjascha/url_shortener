require "sinatra"

class UrlShortener < Sinatra::Application
  enable :sessions

  get '/' do
    redirect '/shortcuts/new'
  end

  get "/shortcuts/new" do
    @shortcuts = session[:shortcuts]
    erb :new
  end

  post "/shortcuts" do
    long_url = params["long_url"]
    session[:shortcuts] = {} unless session[:shortcuts]
    session[:shortcuts][long_url[-4..-1]] = long_url
    redirect '/shortcuts/new'
  end
end