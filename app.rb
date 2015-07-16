require 'json'
require 'logger'

require 'sinatra/base'
require 'slim'
require 'mongo'
require 'hashie/mash'
require 'byebug'

require_relative 'lib/mongo_admin/db'

module MongoAdmin
  class App < Sinatra::Base
    Mongo::Logger.logger.level = Logger::WARN

    configure do
      set :logging, true
      set :views, 'app/views'
      set :public_dir, 'public'
      set :root, (settings.root || File.dirname(__FILE__))
      set :config_file, JSON.load(File.open('config.json'))
    end

    before do
      protected!

      @db = DB.new(settings.config_file)
    end
  end
end

require_relative 'app/helpers'

# Routes
require_relative 'app/routes/collection'
require_relative 'app/routes/database'
require_relative 'app/routes/document'
require_relative 'app/routes/index'
