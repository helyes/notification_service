require 'spec_helper'
require_rel '../notification_spec_helper'
describe APIv1::Notifications do
  include Rack::Test::Methods
  include Spec::NotificationSpecHelper

  def app
    APIv1::Notifications
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
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq limit
      expect(entities.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', limit)
      response_hash = JSON.parse last_response.body
      expect(response_hash['has_more']).to eq true
      expect(response_hash['next_page'].blank?).to be_falsey
      next_page_query = Rack::Utils.parse_query URI(response_hash['next_page']).query
      expect(next_page_query['limit']).to eq '10'
      expect(next_page_query['offset']).to eq '10'
    end

    it 'considers offset' do
      limit = 10
      offset = 6
      notifications
      expected_response = Notification.all[6..-1].to_json
      get "/api/v1/notifications?offset=#{offset}&limit=#{limit}"

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
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
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 2)
    end

    it 'returns all notifications without viewed tag' do
      notification1
      notification2
      FactoryGirl.create(:tag,
                         notification_id: notification1.id,
                         ip: local_ip,
                         label: 'viewed')

      expected_response = notification2.to_json
      get '/api/v1/notifications/tag/viewed?exclude=true'

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq 1
      expect(entities[0].to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns all notifications without viewed tag if multiple viewed tags recorded' do
      notification1
      notification2

      FactoryGirl.create_list(:tag, 2,
                              notification_id: notification1.id,
                              ip: local_ip,
                              label: 'viewed')

      expected_response = notification2.to_json
      get '/api/v1/notifications/tag/viewed?exclude=true'

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.count).to eq 1
      expect(entities[0].to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns all viewed notifications if multiple views recorded' do
      notification1
      notification2

      FactoryGirl.create_list(:tag, 2,
                              notification_id: notification1.id,
                              ip: local_ip,
                              label: 'viewed')

      expected_response = notification1.to_json
      get '/api/v1/notifications/tag/viewed'

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
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
      # puts "XXXXResponse: #{last_response.body}"
      expect(last_response.status).to eq(200)
      entity = fetch_first_entity_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns error when notification is not found' do
      get '/api/v1/notifications/1000'
      expect(last_response.status).to eq(404)
      entity = fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_for_not_found)
      assert_metadata(last_response.body, 'error', 1)
    end

    it 'returns error when id is NaN' do
      get '/api/v1/notifications/foo'

      expect(last_response.status).to eq(400)
      entity = fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_invalid_id)
      assert_metadata(last_response.body, 'error', 1)
    end
  end

  describe 'GET /api/v1/notifications/summary/:summary' do
    let(:notification1) { FactoryGirl.create(:notification, summary: 'First') }
    let(:notification2) { FactoryGirl.create(:notification, summary: 'Second') }
    let(:expected_response_no_matching_record_found) do
      { message: 'No matching records found' }.to_json
    end

    it 'returns notification on exact match' do
      get "/api/v1/notifications/summary/#{notification1.summary}"

      expect(last_response.status).to eq(200)
      entity = fetch_entities_as_hash(last_response.body)
      expect(entity.to_json).to eq([notification1].to_json)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns notification on partial match' do
      expect(notification2.summary.size).to be > 5, 'DEV: Notification2 summary must be at least 5 chars long'
      get "/api/v1/notifications/summary/#{notification2.summary[2..4]}"

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq([notification2].to_json)
      assert_metadata(last_response.body, 'success', 1)
    end

    it 'returns multiple notifications on partial match' do
      search_string = 's'
      expect(notification1.summary.downcase).to include(search_string), "DEV: Notification1 summary must contain #{search_string}"
      expect(notification2.summary.downcase).to include(search_string), "DEV: Notification2 summary must contain #{search_string}"

      get '/api/v1/notifications/summary/s'

      expect(last_response.status).to eq(200)
      entities = fetch_entities_as_hash(last_response.body)
      expect(entities.to_json).to eq([notification1, notification2].to_json)
      assert_metadata(last_response.body, 'success', 2)
    end

    it 'returns error when notification is not found' do
      get '/api/v1/notifications/summary/doesnotexist'

      expect(last_response.status).to eq(404)
      entity = fetch_first_error_as_hash(last_response.body)
      expect(entity.to_json).to eq(expected_response_no_matching_record_found)
      assert_metadata(last_response.body, 'error', 1)
    end
  end
end
