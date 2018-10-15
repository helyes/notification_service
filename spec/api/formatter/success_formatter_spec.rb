require 'spec_helper'

module API
  module Formatter
    describe SuccessFormatter do
      describe 'response_data_paginated' do
        it 'returns true if env contains pagination metadata' do
          env = nil
          body = { :foo => 'bar' }
          body_expected = { :foo => 'bar' }
          SuccessFormatter.add_pagination_info(body, env)
          expect(body).to eq body_expected
        end

        it 'returns false if env is nil' do
          expect(SuccessFormatter.response_data_paginated?(nil)).to be false
        end

        it 'returns false if env does not have pagination info' do
          env = {}
          expect(SuccessFormatter.response_data_paginated?(env)).to be false
        end
      end

      describe 'add_pagination_info' do
        it 'adds has_more and :next_page to response payload metadata if response is paginated' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          env = { 'rack.request.query_hash' => { 'offset' => '2', 'limit' => '15' },
                  'PATH_INFO' => '/api/v1/notifications',
                  'auc_pagination_meta' => { has_more: true } }
          body = {}
          SuccessFormatter.add_pagination_info(body, env)

          expect(body[:has_more]).to be true
          expect(body[:next_page].blank?).to be_falsey

          next_page_query = Rack::Utils.parse_query URI(body[:next_page]).query
          # # don't care about order
          expect(next_page_query['limit']).to eq '15'
          expect(next_page_query['offset']).to eq '17'
        end

        it 'does not add has_more and :next_page to response payload metadata if response is NOT paginated' do
          env = {}
          body = { :foo => 'bar' }
          body_expected = { :foo => 'bar' }
          SuccessFormatter.add_pagination_info(body, env)
          expect(body).to eq body_expected
        end

        it 'does not alter payload if env is nil' do
          env = nil
          body = { :foo => 'bar' }
          body_expected = { :foo => 'bar' }
          SuccessFormatter.add_pagination_info(body, env)
          expect(body).to eq body_expected
        end
      end

      describe 'build_next_page_uri' do
        it 'returns correct url pointing to next page' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
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
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          env = { 'rack.request.query_hash' => { 'limit' => '13' },
                  'PATH_INFO' => '/api/v1/notifications' }
          next_page_path = SuccessFormatter.build_next_page_uri(env)
          expect(next_page_path.blank?).to be_falsey
          expect(next_page_path).to start_with('/api/v1/notifications?')

          next_page_query = Rack::Utils.parse_query URI(next_page_path).query
          expect(next_page_query['limit']).to eq '13'
          expect(next_page_query['offset']).to eq '13'
        end

        it 'returns correct url pointing to next page if offset and limit are 0' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          env = { 'rack.request.query_hash' => { 'offset' => '0', 'limit' => '0' },
                  'PATH_INFO' => '/api/v1/notifications' }
          next_page_path = SuccessFormatter.build_next_page_uri(env)
          puts "next_page_path: #{next_page_path}"
          expect(next_page_path.blank?).to be_falsey
          expect(next_page_path).to start_with('/api/v1/notifications?')

          next_page_query = Rack::Utils.parse_query URI(next_page_path).query
          expect(next_page_query['limit']).to eq '0'
          expect(next_page_query['offset']).to eq '0'
        end
      end
      describe 'entity_name' do
        it 'returns entity name' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          env = {}
          env[Grape::Env::API_ENDPOINT] = grape_endpoint
          entity_name = SuccessFormatter.entity_name(env)
          expect(entity_name).to eq 'notification'
        end

        it 'returns entity name if namespace starts with /' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { '/notification' }
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
