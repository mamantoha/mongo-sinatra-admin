module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection' do
      slim :collection
    end

  end
end

