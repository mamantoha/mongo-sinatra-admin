require 'json'
require 'logger'

require 'sinatra/base'
require 'slim'
require 'mongo'
require 'hashie/mash'
require 'byebug'

module MongoAdmin
  class App < Sinatra::Base
    # Mongo::Logger.logger.level = Logger::WARN

    configure do
      set :logging, true
      set :views, 'app/views'
      set :public_dir, 'public'
      set :root, (settings.root || File.dirname(__FILE__))
      set :config_file, JSON.load(File.open('config.json'))
    end
  end
end

require_relative 'app/helpers'
require_relative 'lib/mongo_admin/db'
require_relative 'app/routes'
