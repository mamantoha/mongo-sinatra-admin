module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection/new' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(@db, @db_name)
      check_collection_exists(@db, @db_name, @collection_name)

      slim :'document/new'
    end

    # Show Document
    get '/db/:database/:collection/:id' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(@db, @db_name)
      check_collection_exists(@db, @db_name, @collection_name)

      # convert id string to mongodb object id
      begin
        @document_id = BSON::ObjectId.from_string(params[:id])
      rescue => err
        flash['danger'] = err.message
        redirect "/db/#{@db_name}/#{@collection_name}"
      end

      @title = "Viewing Document: #{@document_id}"

      client = @db.connect(@db_name)
      collection = client[@collection_name]

      @document = collection.find({_id: @document_id}).first

      if @document
        slim :'document/edit'
      else
        flash[:danger] = 'Document not found.'
        redirect "/db/#{@db_name}/#{@collection_name}"
      end
    end

    # Create new Document
    post '/db/:database/:collection' do
      db_name = params['database']
      collection_name = params['collection']
      document = params['document']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, collection_name)

      begin
        document = JSON.load(document)
      rescue JSON::ParserError => err
        flash[:danger] = "Document is not valid JSON."
        redirect "/db/#{db_name}/#{collection_name}"
      end

      client = @db.connect(db_name)
      collection = client[collection_name]

      result = collection.insert_one(document)
      result.n # => returns 1, because 1 document was inserted
      document_id = result.inserted_id

      flash[:info] = 'New document successfully created.'
      redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
    end

    # Update Document
    put '/db/:database/:collection/:id' do
      db_name = params['database']
      collection_name = params['collection']
      document_text = params['document'] # from a form

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, collection_name)

      # convert id string to mongodb object id
      begin
        document_id = BSON::ObjectId.from_string(params[:id])
      rescue => err
        flash['danger'] = err.message
        redirect "/db/#{db_name}/#{collection_name}"
      end

      begin
        document_json = JSON.load(document_text)
      rescue JSON::ParserError => err
        flash[:danger] = "Document is not valid JSON."
        redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
      end

      # IMPORTANT! You can not change Object ID
      document_json.delete('_id')

      client = @db.connect(db_name)
      collection = client[collection_name]

      document = collection.find({_id: document_id})

      if document.first
        document.replace_one(document_json)
        flash[:info] = 'Document successfully updated.'
        redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
      else
        flash[:danger] = 'Document not found.'
        redirect "/db/#{db_name}/#{collection_name}"
      end
    end

    # Destroy Document
    delete '/db/:database/:collection/:id' do
      db_name         = params['database']
      collection_name = params['collection']

      check_database_exists(@db, db_name)
      check_collection_exists(@db, db_name, collection_name)

      # convert id string to mongodb object id
      begin
        document_id = BSON::ObjectId.from_string(params[:id])
      rescue => err
        flash['danger'] = err.message
        redirect "/db/#{db_name}/#{collection_name}"
      end

      client = @db.connect(db_name)
      collection = client[collection_name]

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

