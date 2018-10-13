require 'spec_helper'

module API
  module Formatter
    describe SuccessFormatter do

      describe 'build_next_page_uri' do
        it 'returns correct url pointing to next page' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) {'notification'}
          env = { 'rack.request.query_hash' => { 'offset' => '2', 'limit' => '15' },
                  'PATH_INFO' => '/api/v1/notifications' }
          next_page_path = SuccessFormatter.build_next_page_uri(env)
          expect(next_page_path.blank?).to be_falsey
          expect(next_page_path).to start_with('/api/v1/notifications?')
          # not ideal, dependency omn rack
          next_page_query = Rack::Utils.parse_query URI(next_page_path).query
          # don't care about order
          expect(next_page_query['limit']).to eq '15'
          expect(next_page_query['offset']).to eq '17'
        end

        it 'returns correct url pointing to next page if offset is nil' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) {'notification'}
          env = { 'rack.request.query_hash' => { 'limit' => '13' },
                  'PATH_INFO' => '/api/v1/notifications' }
          next_page_path = SuccessFormatter.build_next_page_uri(env)
          expect(next_page_path.blank?).to be_falsey
          expect(next_page_path).to start_with('/api/v1/notifications?')

          next_page_query = Rack::Utils.parse_query URI(next_page_path).query
          expect(next_page_query['limit']).to eq '13'
          expect(next_page_query['offset']).to eq '13'
        end

      end
      describe 'entity_name' do
        it 'returns entity name' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) {'notification'}
          env = {}
          env[Grape::Env::API_ENDPOINT] = grape_endpoint
          entity_name = SuccessFormatter.entity_name(env)
          expect(entity_name).to eq 'notification'
        end

        it 'returns entity name if namespace starts with /' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) {'/notification'}
          env = {}
          env[Grape::Env::API_ENDPOINT] = grape_endpoint
          entity_name = SuccessFormatter.entity_name(env)
          expect(entity_name).to eq 'notification'
        end

        it 'returns unknowns if exception raised' do
          entity_name = SuccessFormatter.entity_name(nil)
          expect(entity_name).to eq 'unknowns'
        end
      end
    end
  end
end