require 'spec_helper'
require 'notification_spec_helper'
# rubocop:disable Metrics/AbcSize
describe APIv1::Notifications do
  include Rack::Test::Methods

  def app
    APIv1::Notifications
  end

  # Asserts metadata fields
  # @param [String] response_body
  # @param [String] response_type
  # @param [Integer] item_count
  def assert_metadata(response_body, response_type, item_count)
    response_hash = JSON.parse response_body
    expect(response_hash['start_timestamp']).to match(/#{NotificationSpecHelper::TIMESTAMP_REGEX}/)
    expect(response_hash['end_timestamp']).to match(/#{NotificationSpecHelper::TIMESTAMP_REGEX}/)
    expect(response_hash['time_taken_ms']).to be_a_kind_of(Numeric)
    expect(response_hash['time_taken_ms']).to be > 0
    expect(response_hash['response_type']).to eq(response_type)
    expect(response_hash['item_count']).to eq(item_count)
  end

  describe 'GET /api/v1/notifications paginate' do
    # let(:notifications) { FactoryGirl.create(:notification) }
    # let(:notification2) { FactoryGirl.create(:notification) }
    let(:notifications) { FactoryGirl.create_list :notification, 11 }

    it 'returns one page of notifications' do
      limit = 10
      offset = 0
      notifications
      expected_response = Notification.all[0, 10].to_json
      get "/api/v1/notifications?offset=#{offset}&limit=#{limit}"

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq limit
      expect(entities.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', limit)
    end

    it 'considers offset' do
      limit = 10
      offset = 6
      notifications
      expected_response = Notification.all[6..-1].to_json
      get "/api/v1/notifications?offset=#{offset}&limit=#{limit}"

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq notifications.count - offset
      expect(entities.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', notifications.count - offset)
    end
  end

  describe 'GET /api/v1/notifications' do
    let(:notification1) { FactoryGirl.create(:notification, summary: 'Foo 1 summary') }
    let(:notification2) { FactoryGirl.create(:notification, summary: 'Foo 2 summary') }

    it 'returns all notifications' do
      notification1
      notification2
      expected_response = Notification.all.to_json
      get '/api/v1/notifications'

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 2)
    end

    it 'returns all notifications without viewed tag' do
      notification1
      notification2
      FactoryGirl.create(:tag,
                         notification_id: notification1.id,
                         ip: NotificationSpecHelper.local_ip,
                         label: 'viewed')

      expected_response = notification2.to_json
      get '/api/v1/notifications/tag/viewed?exclude=true'

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq 1
      expect(entities[0].to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns all notifications without viewed tag if multiple viewed tags recorded' do
      notification1
      notification2

      FactoryGirl.create_list(:tag, 2,
                              notification_id: notification1.id,
                              ip: NotificationSpecHelper.local_ip,
                              label: 'viewed')

      expected_response = notification2.to_json
      get '/api/v1/notifications/tag/viewed?exclude=true'

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq 1
      expect(entities[0].to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns all viewed notifications if multiple views recorded' do
      notification1
      notification2

      FactoryGirl.create_list(:tag, 2,
                              notification_id: notification1.id,
                              ip: NotificationSpecHelper.local_ip,
                              label: 'viewed')

      expected_response = notification1.to_json
      get '/api/v1/notifications/tag/viewed'

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq 1
      expect(entities[0].to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end
  end

  describe 'GET /api/v1/notifications/:id' do
    let(:notification) { FactoryGirl.create(:notification, summary: 'Foo summary') }
    let(:expected_response) { notification.to_json }
    let(:expected_response_for_not_found) do
      { message: 'Notification not found' }.to_json
    end
    let(:expected_response_invalid_id) do
      { message: 'Id is invalid' }.to_json
    end

    it 'returns requested notification' do
      get "/api/v1/notifications/#{notification.id}"
      puts "XXXXResponse: #{last_response.body}"
      expect(last_response.status).to eq(200)
      entity = NotificationSpecHelper.fetch_first_entity_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns error when notification is not found' do
      get '/api/v1/notifications/1000'
      puts "XXXXResponse: #{last_response.body}"
      expect(last_response.status).to eq(404)
      entity = NotificationSpecHelper.fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_for_not_found)
      assert_metadata(last_response.body, 'error', 1)
    end

    it 'returns error when id is NaN' do
      get '/api/v1/notifications/foo'

      expect(last_response.status).to eq(400)
      entity = NotificationSpecHelper.fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_invalid_id)
      assert_metadata(last_response.body, 'error', 1)
    end
  end

  describe 'GET /api/v1/notifications/summary/:summary' do
    let(:notification1) { FactoryGirl.create(:notification, summary: 'First') }
    let(:notification2) { FactoryGirl.create(:notification, summary: 'Second') }
    let(:expected_response_for_not_found) do
      { message: 'Notification not found' }.to_json
    end
    let(:expected_response_no_matching_record_found) do
      { message: 'No matching records found' }.to_json
    end

    it 'returns notification on exact match' do
      get "/api/v1/notifications/summary/#{notification1.summary}"

      expect(last_response.status).to eq(200)
      entity = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entity.to_json).to eq([notification1].to_json)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns notification on partial match' do
      expect(notification2.summary.size).to be > 5, 'DEV: Notification2 summary must be at least 5 chars long'
      get "/api/v1/notifications/summary/#{notification2.summary[2..4]}"

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq([notification2].to_json)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns multiple notifications on partial match' do
      search_string = 's'
      expect(notification1.summary.downcase).to include(search_string), "DEV: Notification1 summary must contain #{search_string}"
      expect(notification2.summary.downcase).to include(search_string), "DEV: Notification2 summary must contain #{search_string}"

      get '/api/v1/notifications/summary/s'

      expect(last_response.status).to eq(200)
      entities = NotificationSpecHelper.fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq([notification1, notification2].to_json)
      assert_metadata(last_response.body, 'success', 2)
    end

    it 'returns error when notification is not found' do
      get '/api/v1/notifications/summary/doesnotexist'

      expect(last_response.status).to eq(404)
      entity = NotificationSpecHelper.fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_no_matching_record_found)
      assert_metadata(last_response.body, 'error', 1)
    end
  end

  describe 'POST /api/v1/notifications' do
    let(:body) do
      {
        summary: 'This is a sample POST summary',
        description: 'This is a sample POST description'
      }
    end

    context 'when there is no validation errors' do
      it 'save notification' do
        post '/api/v1/notifications', body, 'Content-Type' => 'application/json'

        expect(last_response.status).to eq(201)
      end
    end

    # context 'when has validation errors' do
    #   let(:expected_response) do
    #     { error: 'Validation failed: Name has already been taken' }.to_json
    #   end
    #
    #   before do
    #     FactoryGirl.create(:notification, name: 'boom')
    #   end
    #
    #   it 'returns error' do
    #     post '/api/v1/notifications', body, { 'Content-Type' => 'application/json' }
    #
    #     expect(last_response.status).to eq(409)
    #     expect(last_response.body).to eq(expected_response)
    #   end
    # end
  end

  describe 'PUT /api/v1/notifications/:id' do
    let(:notification) { FactoryGirl.create(:notification) }
    let(:body) do
      {
        summary: 'This is a sample PUT summary',
        description: 'This is a sample PUT description'
      }
    end

    it 'save notification' do
      notification_before = Notification.find(notification.id)
      expect(notification_before.summary).not_to eq(body[:summary])
      expect(notification_before.description).not_to eq(body[:description])

      put "/api/v1/notifications/#{notification.id}", body, 'Content-Type' => 'application/json'

      expect(last_response.status).to eq(200)
      expect(Notification.first.summary).to eq(body[:summary])
      expect(Notification.first.description).to eq(body[:description])
    end
  end

  describe 'PUT /api/v1/notifications/:id/tag' do
    let(:notification1) { FactoryGirl.create(:notification) }
    let(:notification2) { FactoryGirl.create(:notification) }

    it 'adds new tag to notification, linked to caller ip ' do
      notification_before = Notification.find(notification1.id)
      expect(notification_before.tags).to be_empty
      TAG = 'viewed'.freeze
      put "/api/v1/notifications/#{notification1.id}/tag/#{TAG}"
      expect(last_response.status).to eq(200)

      # check updated
      notification_after = Notification.find(notification1.id)
      expect(notification_after.tags).not_to be_empty
      expect(notification_after.tags.size).to eq(1)
      expect(notification_after.tags[0].label).to eq(TAG)
      expect(notification_after.tags[0].ip).to eq(NotificationSpecHelper.local_ip)
      expect(notification_after.tags[0].created_at).not_to be_nil
      expect(notification_after.tags[0].created_at).to be_within(10.second).of Time.now

      # check other
      notification_after = Notification.find(notification2.id)
      expect(notification_after.tags).to be_empty
    end
  end

  describe 'DELETE /api/v1/notifications/:id' do
    it 'delete notification' do
      notification1 = FactoryGirl.create(:notification)
      notification2 = FactoryGirl.create(:notification)
      expect(Notification.count).to eq(2)

      delete "/api/v1/notifications/#{notification1.id}"

      expect(last_response.status).to eq(200)
      expect(Notification.count).to eq(1)
      expect(Notification.first.id).to eq(notification2.id)
      entity = NotificationSpecHelper.fetch_first_entity_as_hash(last_response.body)
      # response is the deleted one
      expect(entity.to_json).to eq(notification1.to_json)
      assert_metadata(last_response.body, 'success', 1)
    end
  end
end
# rubocop:enable Metrics/AbcSize
# let!(:previous_requests) { (1..10).each { |number| RateLimit.create(ip_address: request_ip, requested_at: number.minutes.ago)} }
