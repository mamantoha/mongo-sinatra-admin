require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')

require 'support/authorization'

Mongo::Logger.logger = Logger.new($stdout)
Mongo::Logger.logger.level = Logger::INFO

RSpec.configure do |config|
  include Rack::Test::Methods

  config.include(Authorization)

  config.before(:each) do
    # Create test database
    client.database[TEST_DB].create

    # Force the collection to be created in the database
    collection = client[TEST_COLLECTION]
    collection.create
  end

  config.after(:each) do
    client.database.drop
  end

  def app
    MongoAdmin::App
  end
end
