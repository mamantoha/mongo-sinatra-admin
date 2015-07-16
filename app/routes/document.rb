module MongoAdmin
  class App < Sinatra::Base

    get '/db/:database/:collection/:document' do
      slim :document
    end

  end
end

