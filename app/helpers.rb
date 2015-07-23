module MongoAdmin
  class App < Sinatra::Base
    helpers do
      def protected!
        return unless settings.config_file['useBasicAuth']
        return if authorized?

        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, 'Notauthorized\n'
      end

      def authorized?
        username = settings.config_file['basicAuth']['username']
        password = settings.config_file['basicAuth']['password']

        @auth ||= Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
      end

      def current_page
        page = params[:page] || 1
        [page.to_i, 1].max
      end

      # Check if Database exists
      def check_database_exists(db, db_name)
        unless db.collections.include?(db_name)
          flash[:danger] = "Database <strong>#{db_name}</strong> does not exist."
          redirect "/"
        end
      end

      # Check if Collection exists
      def check_collection_exists(db, db_name, collection_name)
        unless db.collections[db_name].include?(collection_name)
          flash[:danger] = "Collection <strong>#{collection_name}</strong> does not exist."
          redirect "/db/#{db_name}"
        end
      end

    end
  end
end

