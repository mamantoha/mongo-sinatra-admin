module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(@db, @db_name)
      check_collection_exists(@db, @db_name, @collection_name)

      @title = "Viewing Collection: #{@collection_name}"

      client = @db.connect(@db_name)
      collection = client[@collection_name]

      stats = client.command(collStats: @collection_name)
      @stats = stats.documents.first

      per_page = settings.config_file['options']['documentsPerPage'] || 5
      @pages = (@stats['count'].to_f / per_page).round

      # Get all documents in a collection
      @documents = collection.find.skip(per_page * (current_page - 1)).limit(per_page)

      slim :'collection/show'
    end

    # Create Collection
    post '/db/:database' do
      db_name = params['database']
      collection_name = params['collection'].to_sym

      check_database_exists(@db, db_name)

      unless /^[a-zA-Z_][a-zA-Z0-9\._]*$/ =~ collection_name
        flash[:danger] = 'Collection names must begin with a letter or underscore, and can contain only letters, underscores, numbers or dots.'
        redirect "/db/#{db_name}"
      end

      client = @db.connect(db_name)
      collection = client[collection_name]

      # Force the collection to be created in the database.
      collection.create

      flash[:info] = 'Collection successfully created.'
      redirect "/db/#{db_name}/#{collection_name}"
    end

    # Rename Collection
    put '/db/:database/:collection' do
      db_name = params['database']
      source_collection_name = params['collection']
      target_collection_name = params['target_name']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, source_collection_name)

      unless /^[a-zA-Z_][a-zA-Z0-9\._]*$/ =~ target_collection_name
        flash[:danger] = 'Collection names must begin with a letter or underscore, and can contain only letters, underscores, numbers or dots.'
        redirect "/db/#{db_name}/#{source_collection_name}"
      end

      begin
        @db.admin_db.command({
          renameCollection: "#{db_name}.#{source_collection_name}",
          to:               "#{db_name}.#{target_collection_name}"
        })
      rescue Mongo::Error::OperationFailure => err
        flash[:danger] = "MongoDB Error: `#{err.message}'"
        redirect "/db/#{db_name}/#{source_collection_name}"
      end

      flash[:info] = 'Collection successfully renamed.'
      redirect "/db/#{db_name}/#{target_collection_name}"
    end

    # Drop Collection
    delete '/db/:database/:collection' do
      db_name = params['database']
      collection_name = params['collection']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, source_collection_name)

      client = @db.connect(db_name)
      collection = client[collection_name]

      collection.drop

      flash[:info] = 'Collection successfully removed.'
      redirect "/db/#{db_name}"
    end

  end
end

