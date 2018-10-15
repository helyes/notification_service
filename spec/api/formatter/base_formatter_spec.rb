require 'spec_helper'

module API
  module Formatter
    describe BaseFormatter do
      describe 'init_body' do
        it 'creates meta fields in body hash' do
          start_time = Time.now - 0.1

          expected_request_path = '/api/notifications/1'
          grape_endpoint = double
          grape_endpoint_request = double
          allow(grape_endpoint).to receive(:request) { grape_endpoint_request }
          allow(grape_endpoint_request).to receive(:path) { expected_request_path }
          allow(grape_endpoint).to receive(:namespace) { '/notifications' }
          allow(grape_endpoint).to receive(:options) { { path: [':id'], for: APIv1::Notifications } }

          env = { Grape::Env::API_ENDPOINT => grape_endpoint, 'auc_starttime' => start_time }
          body = BaseFormatter.init_body(env)

          expect(body[:start_timestamp]).to eq start_time
          expect(body[:end_timestamp]).to be_an_instance_of Time
          expect(body[:end_timestamp]).to be > start_time
          expect(body[:time_taken_ms]).to be_a_kind_of(Numeric)
          expect(body[:time_taken_ms]).to be > 100
          expect(body[:response_type]).to eq 'success'
          expect(body[:executor]).to eq 'APIv1::Notifications/notifications/:id'
          expect(body[:path]).to eq expected_request_path
        end
      end

      describe 'time_taken' do
        it 'calculates elapsed time' do
          start_time = Time.now
          end_time = start_time + 0.03456
          expect(BaseFormatter.time_taken(start_time, end_time)).to eq 34.56
        end

        it 'calculates elapsed time as 0 if start time is greater than end time' do
          start_time = Time.now
          end_time = start_time - 1000
          expect(BaseFormatter.time_taken(start_time, end_time)).to eq 0
        end

        it 'calculates elapsed time as 0 if if start_time or end time is nil' do
          expect(BaseFormatter.time_taken(nil, Time.now)).to eq 0
          expect(BaseFormatter.time_taken(Time.now, nil)).to eq 0
          expect(BaseFormatter.time_taken(nil, nil)).to eq 0
        end
      end

      describe 'add_item_count' do
        it 'returns length of body if payload is an Array' do
          body = {}
          payload = [{}, {}]
          BaseFormatter.add_item_count(body, payload)
          expect(body[:item_count]).to eq 2
        end

        it 'returns 1 if payload is an object' do
          body = {}
          payload = {}
          BaseFormatter.add_item_count(body, payload)
          expect(body[:item_count]).to eq 1
        end

        it 'returns 0 if payload is nil' do
          body = {}
          payload = nil
          BaseFormatter.add_item_count(body, payload)
          expect(body[:item_count]).to eq 0
        end
      end

      describe 'path' do
        it 'returns grape request path' do
          expected_request_path = '/api/example/path'
          grape_endpoint = double
          grape_endpoint_request = double
          allow(grape_endpoint).to receive(:request) { grape_endpoint_request }
          allow(grape_endpoint_request).to receive(:path) { expected_request_path }
          env = { Grape::Env::API_ENDPOINT => grape_endpoint }

          expect(BaseFormatter.path(env)).to eq expected_request_path
        end

        it 'returns / if env is nil' do
          expected_request_path = '/'
          expect(BaseFormatter.path(nil)).to eq expected_request_path
        end

        it 'returns / if env[api.endpoint] nil' do
          expected_request_path = '/'
          expect(BaseFormatter.path({})).to eq expected_request_path
        end
      end

      describe 'executor' do
        it 'returns correct executor' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { '/notifications' }
          allow(grape_endpoint).to receive(:options) { { path: [':id'], for: APIv1::Notifications } }
          env = { Grape::Env::API_ENDPOINT => grape_endpoint }
          expect(BaseFormatter.executor(env)).to eq 'APIv1::Notifications/notifications/:id'
        end

        it 'returns unknown if env is nil' do
          expected_executor = 'unknown'
          expect(BaseFormatter.executor(nil)).to eq expected_executor
        end

        it 'returns unknown if env[api.endpoint] is nil' do
          expected_executor = 'unknown'
          expect(BaseFormatter.executor({})).to eq expected_executor
        end
      end
    end
  end
end
