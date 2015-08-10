module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database' do
      @db_name = params['database']

      check_database_exists(@db, @db_name)

      @collections = @db.collections[@db_name]

      @title = I18n.t('viewing_database', database: @db_name)

      client = @db.client.use(@db_name)
      stats = client.command(dbStats: 1)
      @stats = stats.documents.first

      slim :'database/show'
    end

    delete '/db/:database' do
      db_name = params['database']

      if db_name == 'admin'
        flash[:danger] = I18n.t('could_not_drop_admin_database')
        redirect '/'
      end

      check_database_exists(@db, db_name)

      client = @db.client.use(db_name)

      begin
        client.database.drop
      rescue Mongo::Error::OperationFailure => err
        flash[:danger] = I18n.t('mongodb_error', message: err.message)
        redirect '/'
      end

      flash[:info] = I18n.t('database_removed')
      redirect '/'
    end

  end
end