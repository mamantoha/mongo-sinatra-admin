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

    end
  end
end

