# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Document' do
  before do
    authorize USERNAME, PASSWORD
  end

  describe 'create' do
    context 'when document is ok' do
      it 'is successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", document: { name: 'test' }.to_json

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(info: 'New document successfully created.')

        follow_redirect!
        expect(last_response.body).to include('Viewing Document:')
      end
    end

    context 'when document is now valid json' do
      it 'is not successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", document: 'invalid json'

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end

    context 'when document is empty' do
      it 'is not successful' do
        post "/db/#{TEST_DB}/#{TEST_COLLECTION}", document: ''

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document is not valid JSON.')
      end
    end
  end

  describe 'show' do
    before do
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')
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
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')
    end

    let(:collection) { client[TEST_COLLECTION] }
    let(:document) { collection.find.first }

    context 'when exists' do
      it 'is successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", document: { name: 'test' }.to_json

        expect(last_response.status).to eq 200
        expect(last_response.body).to include(I18n.t('document_updated'))
      end
    end

    context 'when ObjectId is invalid' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/invalid_id", document: { name: 'test' }.to_json

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq('danger' => "'invalid_id' is an invalid ObjectId.")
      end
    end

    context 'when document is now valid json' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", document: 'invalid json'

        expect(last_response.status).to eq 200
        expect(last_response.body).to include(I18n.t('document_invalid_json'))
      end
    end

    context 'when document is empty' do
      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", document: ''

        expect(last_response.status).to eq 200
        expect(last_response.body).to include(I18n.t('document_invalid_json'))
      end
    end

    context 'when not found' do
      before do
        collection.find(_id: document['_id']).delete_one
      end

      it 'is not successful' do
        put "/db/#{TEST_DB}/#{TEST_COLLECTION}/#{document['_id']}", document: { name: 'test' }.to_json

        expect(last_response.status).to eq 302
        expect(last_request.session['flash']).to eq(danger: 'Document not found.')
      end
    end
  end

  describe 'destroy' do
    before do
      collection = client[TEST_COLLECTION]
      collection.insert_one(name: 'test name')
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
