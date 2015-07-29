require 'json'
require 'logger'

require 'sinatra/base'
require 'sinatra/flash'
require 'slim'
require 'mongo'
require 'hashie/mash'
require 'byebug'

require 'action_view'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'lib/mongo_admin/db'

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper

module MongoAdmin
  class App < Sinatra::Base
    Mongo::Logger.logger.level = Logger::WARN

    configure do
      set :logging, true
      set :views, 'app/views'
      set :public_dir, 'public'
      set :root, (settings.root || File.dirname(__FILE__))
      set :config_file, JSON.load(File.open("config_#{ENV['RACK_ENV']}.json"))
      set :method_override, true
    end

    before /^(?!\/(error))/ do
      protected!

      begin
        @db = DB.new(settings.config_file)
      rescue => err
        redirect '/error'
      end
    end

    enable :sessions

    register Sinatra::Flash
  end
end

require_relative 'lib/sinatra-flash'

require_relative 'app/helpers'

# Routes
require_relative 'app/routes/collection'
require_relative 'app/routes/database'
require_relative 'app/routes/document'
require_relative 'app/routes/index'
