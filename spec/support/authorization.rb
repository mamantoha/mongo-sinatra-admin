# frozen_string_literal: true

# The default test database for all specs.
TEST_DB = 'mongo_sinatra_test'

# The default test collection for all specs.
TEST_COLLECTION = 'collection_test'

# The seed addresses to be used when creating a client.
ADDRESSES =
  if ENV['MONGODB_ADDRESSES']
    ENV['MONGODB_ADDRESSES'].split(',').freeze
  else
    ['127.0.0.1:27017'].freeze
  end

USERNAME = 'admin'
PASSWORD = 'pass'

CLIENT = Mongo::Client.new(ADDRESSES, database: TEST_DB)

module Authorization
  def self.included(context)
    context.let(:client) { CLIENT }
  end
end
