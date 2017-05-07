# The default test database for all specs.
TEST_DB = 'mongo_sinatra_test'.freeze

# The default test collection for all specs.
TEST_COLLECTION = 'collection_test'.freeze

# The seed addresses to be used when creating a client.
ADDRESSES = ENV['MONGODB_ADDRESSES'] ? ENV['MONGODB_ADDRESSES'].split(',').freeze :
  ['127.0.0.1:27017'].freeze

USERNAME = 'admin'.freeze
PASSWORD = 'pass'.freeze

CLIENT = Mongo::Client.new(ADDRESSES, database: TEST_DB)

module Authorization
  def self.included(context)
    context.let(:client) { CLIENT }

    context.let(:config_file) do
      { 'mongodb' => { 'server' => 'localhost', 'port' => '27017' }, 'useBasicAuth' => true, 'basicAuth' => { 'username' => USERNAME, 'password' => PASSWORD }, 'options' => { 'documentsPerPage' => 2 } }
    end
  end
end
