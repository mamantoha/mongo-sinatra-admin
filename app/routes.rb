module MongoAdmin
  class App < Sinatra::Base

    before do
      protected!

      @db = MongoAdmin::DB.new(settings.config_file)
    end

    get '/' do
      slim :index
    end

    get '/db/:database' do
      slim :database
    end

    get '/db/:database/:collection' do
      slim :collection
    end


  end
end

