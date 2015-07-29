require_relative 'spec_helper'

describe "Database" do

  describe "view" do
    before do
      app.config_file = config_file
      authorize USERNAME, PASSWORD
    end

    context 'when exists' do
      it 'is successful' do
        get "/db/#{TEST_DB}"

        expect(last_response.status).to eq 200
        expect(last_response.body).to include("Viewing Database: #{TEST_DB}")
      end
    end

    context 'when not exists' do
      it 'is not successful' do
        get "/db/invalid_database"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq({:danger => "Database <strong>invalid_database</strong> does not exist."})
      end
    end
  end

  describe "delete" do
    before do
      app.config_file = config_file
      authorize USERNAME, PASSWORD
    end

    context 'when exists' do
      it 'is successful' do
        expect(client.database_names).to include(TEST_DB)

        delete "/db/#{TEST_DB}"

        expect(client.database_names).not_to include(TEST_DB)

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq({:info=>"Database successfully removed."})
      end
    end

    context 'when not exists' do
      it 'is not successful' do
        delete "/db/invalid_database"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq({:danger=>"Database <strong>invalid_database</strong> does not exist."})
      end
    end

  end
end
