module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection' do
      @db_name = params['database']
      @collection_name = params['collection']

      @title = "Viewing Collection: #{@collection_name}"

      client = @db.connect(@db_name)

      stats = client.command(collStats: @collection_name)
      @stats = stats.documents.first

      per_page = settings.config_file['options']['documentsPerPage'] || 5
      @pages = (@stats['count'].to_f / per_page).round

      collection = client[@collection_name]
      # Get all documents in a collection
      @documents = collection.find.skip(per_page * (current_page - 1)).limit(per_page)

      slim :'collection/show'
    end

    # Drop Collection
    delete '/db/:database/:collection' do
      db_name = params['database']
      collection_name = params['collection']

      client = @db.connect(db_name)
      collection = client[collection_name]

      collection.drop

      flash[:info] = 'Collection successfully removed.'
      redirect "/db/#{db_name}"
    end

  end
end

