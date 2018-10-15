require 'spec_helper'
require_rel '../notification_spec_helper'
describe APIv1::Notifications do
  include Rack::Test::Methods
  include Spec::NotificationSpecHelper

  def app
    APIv1::Notifications
  end

  describe 'POST /api/v1/notifications' do
    let(:body) do
      {
        summary: 'This is a sample POST summary',
        description: 'This is a sample POST description'
      }
    end

    context 'when payload is invalid' do
      let(:expected_response_summary_is_missing) do
        { message: 'Summary is missing' }.to_json
      end
      let(:expected_response_description_is_missing) do
        { message: 'Description is missing' }.to_json
      end
      let(:expected_response_summary_is_too_long) do
        { message: 'Validation failed: summary is too long (maximum is 160 characters)' }.to_json
      end
      let(:expected_response_description_is_too_long) do
        { message: 'Validation failed: description is too long (maximum is 2048 characters)' }.to_json
      end
      let(:expected_response_summary_is_blank) do
        { message: 'Validation failed: summary is too short (minimum is 1 character)' }.to_json
      end
      let(:expected_response_description_is_blank) do
        { message: 'Validation failed: description is too short (minimum is 1 character)' }.to_json
      end

      it 'returns 400 when Summary is missing' do
        post '/api/v1/notifications', body.except(:summary), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(400)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_summary_is_missing)
        assert_metadata(last_response.body, 'error', 1)
      end

      it 'returns 400 when Description is missing' do
        post '/api/v1/notifications', body.except(:description), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(400)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_description_is_missing)
        assert_metadata(last_response.body, 'error', 1)
      end

      it 'returns 409 when Summary is too long' do
        post '/api/v1/notifications', { summary: 'a' * 161 }.reverse_merge(body), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(409)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_summary_is_too_long)
        assert_metadata(last_response.body, 'error', 1)
      end

      it 'returns 409 when description is too long' do
        post '/api/v1/notifications', { description: 'a' * 2049 }.reverse_merge(body), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(409)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_description_is_too_long)
        assert_metadata(last_response.body, 'error', 1)
      end

      it 'returns 409 when description is blank' do
        post '/api/v1/notifications', { description: '' }.reverse_merge(body), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(409)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_description_is_blank)
        assert_metadata(last_response.body, 'error', 1)
      end

      it 'returns 409 when summary is blank' do
        post '/api/v1/notifications', { summary: '' }.reverse_merge(body), 'Content-Type' => 'application/json'
        expect(last_response.status).to eq(409)
        entity = fetch_first_error_as_hash(last_response.body)
        expect(entity.to_json).to eq(expected_response_summary_is_blank)
        assert_metadata(last_response.body, 'error', 1)
      end
    end
    context 'when there is no validation errors' do
      it 'save notification' do
        post '/api/v1/notifications', body, 'Content-Type' => 'application/json'

        expect(last_response.status).to eq(201)
      end
    end
  end
end
# let!(:previous_requests) { (1..10).each { |number| RateLimit.create(ip_address: request_ip, requested_at: number.minutes.ago)} }
