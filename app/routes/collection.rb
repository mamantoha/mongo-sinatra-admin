# frozen_string_literal: true

module MongoAdmin
  class App < Sinatra::Base # :nodoc:
    # Export Collection
    get '/db/:database/export/:collection' do
      db_name = params['database']
      collection_name = params['collection']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, collection_name)

      client = @db.client.use(db_name)
      collection = client[collection_name]

      documents = collection.find
      documents_json = documents.to_a

      content_type 'application/json'
      attachment "#{collection_name}.json"
      JSON.pretty_generate(documents_json)
    end

    get '/db/:database/:collection' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(@db, @db_name)
      check_collection_exists(@db, @db_name, @collection_name)

      @title = I18n.t('viewing_collection', collection: @collection_name)

      client = @db.client.use(@db_name)
      collection = client[@collection_name]

      stats = client.command(collStats: @collection_name)
      @stats = stats.documents.first

      per_page = settings.config_file['options']['documentsPerPage'] || 5
      @pages = (@stats['count'].to_f / per_page).ceil

      # Get all documents in a collection
      @documents = collection.find.skip(per_page * (current_page - 1)).limit(per_page)

      slim :'collection/show'
    end

    # Create Collection
    post '/db/:database' do
      db_name = params['database']
      collection_name = params['collection'].to_sym

      check_database_exists(@db, db_name)

      unless /^[a-zA-Z_][a-zA-Z0-9._]*$/ =~ collection_name
        flash[:danger] = I18n.t('collection_validates_name_error')
        redirect "/db/#{db_name}"
      end

      client = @db.client.use(db_name)
      collection = client[collection_name]

      begin
        # Force the collection to be created in the database.
        collection.create
      rescue Mongo::Error::OperationFailure => e
        flash[:danger] = I18n.t('mongodb_error', message: e.message)
        redirect "/db/#{db_name}"
      end

      flash[:info] = I18n.t('collection_created')
      redirect "/db/#{db_name}/#{collection_name}"
    end

    # Rename Collection
    put '/db/:database/:collection' do
      db_name = params['database']
      source_collection_name = params['collection']
      target_collection_name = params['target_name']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, source_collection_name)

      unless /^[a-zA-Z_][a-zA-Z0-9._]*$/ =~ target_collection_name
        flash[:danger] = I18n.t('collection_validates_name_error')
        redirect "/db/#{db_name}/#{source_collection_name}"
      end

      begin
        @db.client.command(renameCollection: "#{db_name}.#{source_collection_name}",
                           to: "#{db_name}.#{target_collection_name}")
      rescue Mongo::Error::OperationFailure => e
        flash[:danger] = I18n.t('mongodb_error', message: e.message)
        redirect "/db/#{db_name}/#{source_collection_name}"
      end

      flash[:info] = I18n.t('collection_renamed')
      redirect "/db/#{db_name}/#{target_collection_name}"
    end

    # Drop Collection
    delete '/db/:database/:collection' do
      db_name = params['database']
      collection_name = params['collection']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, collection_name)

      client = @db.client.use(db_name)
      collection = client[collection_name]

      begin
        collection.drop
      rescue Mongo::Error::OperationFailure => e
        flash[:danger] = I18n.t('mongodb_error', message: e.message)
        redirect "/db/#{db_name}"
      end

      flash[:info] = I18n.t('collection_deleted')
      redirect "/db/#{db_name}"
    end
  end
end
