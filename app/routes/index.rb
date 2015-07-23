module MongoAdmin
  class App < Sinatra::Base

    get '/' do
      info = @db.admin_db.command(serverStatus: 1)

      @info = info.documents.first
      slim :index
    end

    get '/error' do
      slim :error, layout: false
    end

  end
end

