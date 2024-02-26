# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Basic Auth' do
  context 'when useBasicAuth is disabled in config' do
    before do
      allow(ENV).to receive(:[]).with('USER_BASIC_AUTH').and_return("false")
    end

    context 'get /' do
      before do
        get '/'
      end

      it 'is successful' do
        expect(last_response.status).to eq 200
      end
    end
  end

  context 'when useBasicAuth is enabled in config' do
    context 'get / with proper credentials' do
      before do
        authorize USERNAME, PASSWORD
        get '/'
      end

      it 'is successful' do
        expect(last_response.status).to eq 200
      end
    end

    context 'get / without proper credentials' do
      before do
        authorize 'invalid', 'invalid'
        get '/'
      end

      it 'is not successful' do
        expect(last_response.status).to eq 401
      end
    end
  end
end
