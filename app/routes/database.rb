module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database' do
      @db_name = params['database']

      check_database_exists(@db, @db_name)

      @collections = @db.collections[@db_name]

      @title = "Viewing Database: #{@db_name}"

      client = @db.connect(@db_name)
      stats = client.command(dbStats: 1)
      @stats = stats.documents.first

      slim :'database/show'
    end

    delete '/db/:database' do
      db_name = params['database']

      if db_name == 'admin'
        flash[:danger] = "Could not drop admin database"
        redirect "/"
      end

      check_database_exists(@db, db_name)

      client = @db.connect(db_name)

      begin
        client.database.drop
      rescue Mongo::Error::OperationFailure => err
        flash[:danger] = "MongoDB Error: `#{err.message}'"
        redirect "/"
      end


      flash[:info] = 'Database successfully removed.'
      redirect '/'
    end

  end
end

