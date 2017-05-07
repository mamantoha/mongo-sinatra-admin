module MongoAdmin
  class App < Sinatra::Base
    get '/' do
      info = @db.client.command(serverStatus: 1)

      @info = info.documents.first
      slim :index
    end

    get '/error' do
      slim :error, layout: false
    end

    post '/locale' do
      settings.locale = params[:locale] || I18n.default_locale
      redirect back
    end

    get '/about' do
      slim :about
    end
  end
end
