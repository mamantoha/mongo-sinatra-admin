# frozen_string_literal: true

module MongoAdmin
  class App < Sinatra::Base # :nodoc:
    get '/db/:database/:collection/new' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(settings.db, @db_name)
      check_collection_exists(settings.db, @db_name, @collection_name)

      slim :'document/new'
    end

    # Show Document
    get '/db/:database/:collection/:id' do
      @db_name = params['database']
      @collection_name = params['collection']

      check_database_exists(settings.db, @db_name)
      check_collection_exists(settings.db, @db_name, @collection_name)

      # convert id string to mongodb object id
      begin
        @document_id = BSON::ObjectId.from_string(params[:id])
      rescue StandardError => e
        flash['danger'] = e.message

        redirect "/db/#{@db_name}/#{@collection_name}"
      end

      @title = I18n.t('viewing_document', document: @document_id)

      client = settings.db.client.use(@db_name)
      collection = client[@collection_name]

      @document = collection.find(_id: @document_id).first

      if @document
        slim :'document/edit'
      else
        flash[:danger] = I18n.t('document_not_found')

        redirect "/db/#{@db_name}/#{@collection_name}"
      end
    end

    # Create new Document
    post '/db/:database/:collection' do
      db_name = params['database']
      collection_name = params['collection']
      document_text = params['document']

      check_database_exists(settings.db, db_name)
      check_collection_exists(settings.db, db_name, collection_name)

      begin
        document_json = JSON.parse(document_text)
      rescue JSON::ParserError
        document_json = nil
      end

      unless document_json
        flash[:danger] = I18n.t('document_invalid_json')

        redirect "/db/#{db_name}/#{collection_name}"
      end

      client = settings.db.client.use(db_name)
      collection = client[collection_name]

      result = collection.insert_one(document_json)
      result.n # => returns 1, because 1 document was inserted
      document_id = result.inserted_id

      flash[:info] = I18n.t('document_created')

      redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
    end

    # Update Document
    put '/db/:database/:collection/:id' do
      db_name = params['database']
      collection_name = params['collection']
      document_text = params['document'] # from a form

      check_database_exists(settings.db, db_name)
      check_collection_exists(settings.db, db_name, collection_name)

      # convert id string to mongodb object id
      begin
        document_id = BSON::ObjectId.from_string(params[:id])
      rescue StandardError => e
        flash['danger'] = e.message

        redirect "/db/#{db_name}/#{collection_name}"
      end

      begin
        document_json = JSON.parse(document_text)
      rescue JSON::ParserError
        document_json = nil
      end

      unless document_json
        flash[:danger] = I18n.t('document_invalid_json')

        redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
      end

      # IMPORTANT! You can not change Object ID
      document_json.delete('_id')

      client = settings.db.client.use(db_name)
      collection = client[collection_name]

      document = collection.find(_id: document_id)

      if document.first
        document.replace_one(document_json)
        flash[:info] = I18n.t('document_updated')

        redirect "/db/#{db_name}/#{collection_name}/#{document_id}"
      else
        flash[:danger] = I18n.t('document_not_found')

        redirect "/db/#{db_name}/#{collection_name}"
      end
    end

    # Destroy Document
    delete '/db/:database/:collection/:id' do
      db_name         = params['database']
      collection_name = params['collection']

      check_database_exists(settings.db, db_name)
      check_collection_exists(settings.db, db_name, collection_name)

      # convert id string to mongodb object id
      begin
        document_id = BSON::ObjectId.from_string(params[:id])
      rescue StandardError => e
        flash['danger'] = e.message

        redirect "/db/#{db_name}/#{collection_name}"
      end

      client = settings.db.client.use(db_name)
      collection = client[collection_name]

      document = collection.find(_id: document_id)

      if document.first
        document.delete_one
        flash[:info] = I18n.t('document_deleted')
      else
        flash[:danger] = I18n.t('document_not_found')
      end

      redirect "/db/#{db_name}/#{collection_name}"
    end
  end
end
