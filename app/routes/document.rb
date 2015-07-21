module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection/new' do
      @db_name = params['database']
      @collection_name = params['collection']

      slim :'document/new'
    end

    # Show Document
    get '/db/:database/:collection/:id' do
      @db_name = params['database']
      @collection_name = params['collection']

      # convert id string to mongodb object id
      @document_id = BSON::ObjectId.from_string(params[:id])

      database = @db.connect(@db_name)
      collection = database[@collection_name]

      @document = collection.find({_id: @document_id}).first # BSON::Document

      if @document
        slim :'document/edit'
      else
        flash[:danger] = 'Document not found.'
        redirect back
      end
    end

    # Create new Document
    post '/db/:database/:collection' do
      db_name         = params['database']
      collection_name = params['collection']
      document        = params['document']

      # TODO: document is not valid
      document = JSON.load(document)

      database = @db.connect(db_name)
      collection = database[collection_name]

      result = collection.insert_one(document)
      result.n # => returns 1, because 1 document was inserted
      document_id = result.inserted_id

      flash[:info] = 'New document successfully created.'
      redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
    end

    # Update Document
    put '/db/:database/:collection/:id' do
      db_name         = params['database']
      collection_name = params['collection']
      document        = params['document']

      # convert id string to mongodb object id
      document_id = BSON::ObjectId.from_string(params[:id])

      # TODO: document is not valid
      document = JSON.load(document)

      # IMPORTANT! You can not change Object ID
      document.delete('_id')

      database = @db.connect(db_name)
      collection = database[collection_name]

      document = collection.find({_id: document_id}).replace_one(document)

      flash[:info] = 'Document successfully updated.'

      redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
    end

    # Destroy Document
    delete '/db/:database/:collection/:id' do
      db_name         = params['database']
      collection_name = params['collection']
      document        = params['document']

      database = @db.connect(db_name)
      collection = database[collection_name]

      # convert id string to mongodb object id
      document_id = BSON::ObjectId.from_string(params[:id])

      document = collection.find({_id: document_id})

      if document.first
        document.delete_one
        flash[:info] = 'Document successfully removed.'

        redirect "/db/#{db_name}/#{collection_name}"
      else
        flash[:danger] = 'Document not found.'

        redirect "/db/#{db_name}/#{collection_name}"
      end

    end

  end
end

