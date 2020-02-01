require 'rails_helper'

RSpec.describe SocialNetworksController, type: :controller do
  describe 'GET #fetch' do
    let(:response_stub) { { 'twitter': ['hello world'] } }

    before { allow(::Requesters::Common).to receive(:call).and_return(response_stub) }

    it 'should be successfull' do
      get :fetch

      expect(response).to be_successful
    end

    context 'response includes errors' do
      let(:response_stub) { { 'errors': { 'instagram': 'some error message' }, 'twitter': ['hello world'] } }

      it 'returns status 206' do
        get :fetch

        expect(response.status).to eq(206)
      end

      it 'returns full data' do
        get :fetch

        expect(JSON.parse(response.body).deep_symbolize_keys).to eq(response_stub)
      end
    end

    context 'no errors present in response' do
      it 'returns status 200' do
        get :fetch

        expect(response.status).to eq(200)
      end

      it 'returns full data' do
        get :fetch

        expect(JSON.parse(response.body).deep_symbolize_keys).to eq(response_stub)
      end
    end
  end
end
