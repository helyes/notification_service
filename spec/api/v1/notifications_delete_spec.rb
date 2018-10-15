require 'spec_helper'
require_rel '../notification_spec_helper'
describe APIv1::Notifications do
  include Rack::Test::Methods
  include Spec::NotificationSpecHelper

  def app
    APIv1::Notifications
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
      entity = fetch_first_entity_as_hash(last_response.body)
      # response is the deleted one
      expect(entity.to_json).to eq(notification1.to_json)
      assert_metadata(last_response.body, 'success', 1)
    end
  end
end
# let!(:previous_requests) { (1..10).each { |number| RateLimit.create(ip_address: request_ip, requested_at: number.minutes.ago)} }
