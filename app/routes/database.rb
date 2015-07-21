module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database' do
      @db_name = params['database']
      @collections = @db.collections[@db_name]

      client = @db.connect(@db_name)
      stats = client.command(dbStats: 1)
      @stats = stats.documents.first

      slim :'database/show'
    end

    delete '/db/:database' do
      db_name = params['database']

      client = @db.connect(db_name)
      client.database.drop

      flash[:info] = 'Database successfully removed.'
      redirect '/'
    end


  end
end

