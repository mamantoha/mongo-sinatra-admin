module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection' do
      @db_name = params['database']
      @collection_name = params['collection']

      database = @db.connect(@db_name)
      collection = database[@collection_name]
      # Get all documents in a collection
      @documents = collection.find

      slim :collection
    end

  end
end

