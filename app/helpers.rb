# frozen_string_literal: true

module MongoAdmin
  class App < Sinatra::Base # :nodoc:
    helpers do
      def protected!
        return unless ENV['USE_BASIC_AUTH']
        return if authorized?

        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, 'Notauthorized\n'
      end

      def authorized?
        username = ENV['BASIC_AUTH_USERNAME']
        password = ENV['BASIC_AUTH_PASSWORD']

        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
      end

      def current_page
        page = params[:page] || 1
        [page.to_i, 1].max
      end

      # Check if Database exists
      def check_database_exists(db, db_name)
        return if db.collections.include?(db_name)

        flash[:danger] = I18n.t('database_not_found', database: db_name)

        redirect '/'
      end

      # Check if Collection exists
      def check_collection_exists(db, db_name, collection_name)
        return if db.collections[db_name].include?(collection_name)

        flash[:danger] = I18n.t('collection_not_found', collection: collection_name)

        redirect "/db/#{db_name}"
      end

      def set_locale
        I18n.locale = settings.locale || I18n.default_locale
      end

      def available_locales
        [
          { name: I18n.t('locales.english'), locale: 'en' },
          { name: I18n.t('locales.pseudolocalization'), locale: 'en-ZZ' }
        ]
      end

      def format_time_in_seconds(seconds)
        Time.at(seconds).utc.strftime('%H:%M:%S')
      end
    end
  end
end
