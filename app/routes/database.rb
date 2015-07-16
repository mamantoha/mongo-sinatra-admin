module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database' do
      @db_name = params['database']
      @collections = @db.collections[@db_name]

      database = @db.connect(@db_name)
      stats = database.command(dbStats: 1)
      @stats = stats.documents.first

      slim :database
    end

  end
end

