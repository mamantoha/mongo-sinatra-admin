# frozen_string_literal: true

require 'mongo'

module MongoAdmin
  class DB # :nodoc:
    attr_reader :client, :databases, :collections

    def initialize
      @databases = []
      @collections = {}

      @client = nil

      connect!

      update_databases!

      @databases.each do |db_name|
        update_collections!(db_name)
      end
    end

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

      @databases
    end

    # update the collection list
    def update_collections!(db_name)
      db_client = @client.use(db_name)
      database = db_client.database

      db_name = database.name
      @collections[db_name] = database.collection_names.sort

      db_client.close

      @collections
    end

    private

    def connect!(database = 'admin')
      host = ENV['MONGODB_HOST'] || 'localhost'
      port = ENV['MONGODB_PORT'] || 27_017

      @client = Mongo::Client.new("mongodb://#{host}:#{port}", database:)

      true
    end
  end
end
