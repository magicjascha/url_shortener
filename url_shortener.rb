require "sinatra"

class UrlShortener < Sinatra::Application

  get '/' do
    redirect '/shortcuts/new'
  end

  get "/shortcuts/new" do
    erb :new
  end
end