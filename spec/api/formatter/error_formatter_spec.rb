require 'spec_helper'
require_rel '../notification_spec_helper'

module API
  module Formatter
    describe ErrorFormatter do
      include Spec::NotificationSpecHelper

      describe 'populates error' do
        let(:expected_error) do
          { message: 'Foo error message' }
        end
        it 'adds has_more and :next_page to response payload metadata if response is paginated' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          start_time = Time.now - 0.1

          expected_request_path = '/api/notifications/1'
          grape_endpoint = double
          grape_endpoint_request = double
          allow(grape_endpoint).to receive(:request) { grape_endpoint_request }
          allow(grape_endpoint_request).to receive(:path) { expected_request_path }
          allow(grape_endpoint).to receive(:namespace) { '/notifications' }
          allow(grape_endpoint).to receive(:options) { { path: [':id'], for: APIv1::Notifications } }
          env = { Grape::Env::API_ENDPOINT => grape_endpoint, 'auc_starttime' => start_time }

          response = ErrorFormatter.call(expected_error[:message], nil, nil, env)
          entity = fetch_first_error_as_hash(response)

          assert_metadata(response, 'error', 1)
          expect(entity.to_json).to eq expected_error.to_json
        end

        it 'can handle nil error message' do
          grape_endpoint = double
          allow(grape_endpoint).to receive(:namespace) { 'notification' }
          start_time = Time.now - 0.1

          expected_request_path = '/api/notifications/1'
          grape_endpoint = double
          grape_endpoint_request = double
          allow(grape_endpoint).to receive(:request) { grape_endpoint_request }
          allow(grape_endpoint_request).to receive(:path) { expected_request_path }
          allow(grape_endpoint).to receive(:namespace) { '/notifications' }
          allow(grape_endpoint).to receive(:options) { { path: [':id'], for: APIv1::Notifications } }
          env = { Grape::Env::API_ENDPOINT => grape_endpoint, 'auc_starttime' => start_time }

          response = ErrorFormatter.call(nil, nil, nil, env)
          entity = fetch_first_error_as_hash(response)
          assert_metadata(response, 'error', 1)
          expected_null_message = { message: nil }.reverse_merge(expected_error)
          expect(entity.to_json).to eq expected_null_message.to_json
        end
      end
    end
  end
end
