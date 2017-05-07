require_relative 'spec_helper'

describe 'Document' do
  describe 'create' do
    before do
      app.config_file = config_file

      authorize USERNAME, PASSWORD
    end

    context 'when document is ok' do
      it 'is successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", params = { document: { name: 'test' }.to_json }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'New document successfully created.')

        follow_redirect!
        expect(last_response.body).to include('Viewing Document:')
      end
    end

    context 'when document is now valid json' do
      it 'is not successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", params = { document: 'invalid json' }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end

    context 'when document is empty' do
      it 'is not successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", params = { document: '' }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end
  end

  describe 'show' do
    before do
      app.config_file = config_file
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')

      authorize USERNAME, PASSWORD
    end

    context 'when exists' do
      let(:collection) { client[TEST_COLLECTION] }
      let(:document) { collection.find.first }

      it 'is successful' do
        get "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}"

        expect(last_response.status).to eq 200
        expect(last_response.body).to include('Viewing Document:')
      end
    end

    context 'when ObjectId is invalid' do
      it 'is not successful' do
        get "/db/#{TEST_DB}/#{TEST_COLLECTION}/invalid_id"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq('danger' => "'invalid_id' is an invalid ObjectId.")
      end
    end

    context 'when not found' do
      let(:collection) { client[TEST_COLLECTION] }
      let(:document) { collection.find.first }

      before do
        collection.find(_id: document['_id']).delete_one
      end

      it 'is not successful' do
        get "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document not found.')
      end
    end
  end

  describe 'update' do
    before do
      app.config_file = config_file
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')

      authorize USERNAME, PASSWORD
    end

    let(:collection) { client[TEST_COLLECTION] }
    let(:document) { collection.find.first }

    context 'when exists' do
      it 'is successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", params = { document: { name: 'test' }.to_json }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'Document successfully updated.')
      end
    end

    context 'when ObjectId is invalid' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/invalid_id", params = { document: { name: 'test' }.to_json }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq('danger' => "'invalid_id' is an invalid ObjectId.")
      end
    end

    context 'when document is now valid json' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", params = { document: 'invalid json' }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end

    context 'when document is empty' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", params = { document: '' }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end

    context 'when not found' do
      before do
        collection.find(_id: document['_id']).delete_one
      end

      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", params = { document: { name: 'test' }.to_json }

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document not found.')
      end
    end
  end

  describe 'destroy' do
    before do
      app.config_file = config_file
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')

      authorize USERNAME, PASSWORD
    end

    let(:collection) { client[TEST_COLLECTION] }
    let(:document) { collection.find.first }

    context 'when exists' do
      it 'is successful' do
        delete "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'Document successfully removed.')
      end
    end

    context 'when ObjectId is invalid' do
      it 'is not successful' do
        delete "/db/#{TEST_DB}/#{TEST_COLLECTION}/invalid_id"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq('danger' => "'invalid_id' is an invalid ObjectId.")
      end
    end

    context 'when not found' do
      before do
        collection.find(_id: document['_id']).delete_one
      end

      it 'is not successful' do
        delete "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}"

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document not found.')
      end
    end
  end
end
