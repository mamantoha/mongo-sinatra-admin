# frozen_string_literal: true

require 'json'
require 'logger'

require 'sinatra/base'
require 'sinatra/flash'
require 'slim'
require 'mongo'
require 'hashie/mash'
require 'i18n'
require 'i18n/backend/fallbacks'
require 'pry'

require 'action_view'

ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'lib/mongo_admin/db'

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper

module MongoAdmin
  class App < Sinatra::Base # :nodoc:
    Mongo::Logger.logger.level = Logger::WARN

    configure do
      set :logging, true
      set :views, 'app/views'
      set :public_dir, 'public'
      set :root, (settings.root || File.dirname(__FILE__))
      set :method_override, true
      set :locale, I18n.default_locale

      set :config_file, JSON.parse(File.read("config_#{ENV.fetch('RACK_ENV', 'develop')}.json"))
      set :db, MongoAdmin::DB.new(config_file)

      I18n::Backend::Simple.include I18n::Backend::Fallbacks
      I18n.default_locale = :en
      I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
      I18n.backend.load_translations
      I18n.enforce_available_locales = false
    end

    before do
      protected!
      set_locale
      @locales = available_locales
    end

    enable :sessions

    # use Rack::Locale

    register Sinatra::Flash
  end
end

require_relative 'lib/sinatra_flash'

require_relative 'app/helpers'

# Routes
require_relative 'app/routes/collection'
require_relative 'app/routes/database'
require_relative 'app/routes/document'
require_relative 'app/routes/index'
