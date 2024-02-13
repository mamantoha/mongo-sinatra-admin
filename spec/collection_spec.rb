# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Collection' do
  describe 'view' do
    before do
      app.config_file = config_file

      authorize USERNAME, PASSWORD
    end

    context 'when exists' do
      it 'is successful' do
        get "/db/#{TEST_DB}/#{TEST_COLLECTION}"

        expect(last_response.status).to eq 200
        expect(last_response.body).to include("Viewing Collection: #{TEST_COLLECTION}")
      end
    end

    context 'when not exists' do
      it 'is not successful' do
        get "/db/#{TEST_DB}/invalid_collection"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Collection <strong>invalid_collection</strong> does not exist.')
      end
    end
  end

  describe 'create' do
    before do
      app.config_file = config_file

      authorize USERNAME, PASSWORD
    end

    context 'when Collection already exists' do
      it 'should fail' do
        post "/db/#{TEST_DB}", collection: TEST_COLLECTION

        expect(last_response.status).to eq 302
        # FIXME
        # expect(last_request.session['flash'][:danger]).to match(/MongoDB Error: `(.*) already exists \((\d*)\)/)
      end
    end

    context 'when Collection name is not valid' do
      it 'should fail' do
        post "/db/#{TEST_DB}", collection: 'хуйня'

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Collection names must begin with a letter or underscore, and can contain only letters, underscores, numbers or dots.')
      end
    end

    context 'when Collection not exists' do
      it 'should create new' do
        post "/db/#{TEST_DB}", collection: 'new_test_collection'

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'Collection successfully created.')

        follow_redirect!
        expect(last_response.body).to include('Viewing Collection: new_test_collection')
      end
    end
  end

  describe 'rename' do
    before do
      app.config_file = config_file

      collection = client['new_test_collection']
      collection.create

      authorize USERNAME, PASSWORD
    end

    context 'when Collection name already taken' do
      it 'should fail' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}", target_name: 'new_test_collection'

        expect(last_response.status).to eq 302
        # FIXME
        # expect(last_request.session['flash'][:danger]).to match(/MongoDB Error: `(.*)target namespace exists \(\d+\)/)
      end
    end

    context 'when Collection name is not valid' do
      it 'should fail' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}", target_name: 'хуйня'

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Collection names must begin with a letter or underscore, and can contain only letters, underscores, numbers or dots.')
      end
    end

    context 'when Collection not exists' do
      it 'should rename' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}", target_name: 'super_new_test_collection'

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'Collection successfully renamed.')

        follow_redirect!
        expect(last_response.body).to include('Viewing Collection: super_new_test_collection')
      end
    end
  end

  describe 'delete' do
    before do
      app.config_file = config_file

      authorize USERNAME, PASSWORD
    end

    context 'when exists' do
      it 'should delete it' do
        expect(client.database.collection_names).to include(TEST_COLLECTION)

        delete "/db/#{TEST_DB}/#{TEST_COLLECTION}"

        expect(client.database.collection_names).not_to include(TEST_COLLECTION)

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'Collection successfully removed.')
      end
    end

    context 'when not exists' do
      it 'is not successful' do
        delete "/db/#{TEST_DB}/invalid_collection"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Collection <strong>invalid_collection</strong> does not exist.')
      end
    end
  end
end
