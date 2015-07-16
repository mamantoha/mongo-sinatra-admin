require 'mongo'

module MongoAdmin
  class DB
    attr_reader :config
    attr_reader :client
    attr_reader :admin_db
    attr_reader :databases, :collections

    def initialize(config)
      @config = Hashie::Mash.new(config)

      @databases = []
      @collections = {}

      @admin_db = @client = connect

      update_databases!

      @databases.each do |db_name|
        update_collections!(db_name)
      end
    end

    def connect(database = 'admin')
      host = @config.mongodb.host || 'localhost'
      port = @config.mongodb.port || 27017

      client = Mongo::Client.new("mongodb://#{host}:#{port}", database: database)

      return client
    end

    private

    # update database list
    def update_databases!
      databases = []

      @client.list_databases.each do |database|
        db_name = database[:name]
        # 'local' is a special database, ignore it
        next if db_name == 'local'
        databases << db_name
      end

      @databases = databases.sort

      return @databases
    end

    # update the collection list
    def update_collections!(db_name)
      host = @config.mongodb.host || 'localhost'
      port = @config.mongodb.port || 27017

      client = Mongo::Client.new("mongodb://#{host}:#{port}", database: db_name)
      database = client.database

      db_name = database.name
      @collections[db_name] = database.collection_names.sort
    end

  end
end
