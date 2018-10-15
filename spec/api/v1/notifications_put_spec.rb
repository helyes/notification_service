require 'spec_helper'
require_rel '../notification_spec_helper'
describe APIv1::Notifications do
  include Rack::Test::Methods
  include Spec::NotificationSpecHelper

  def app
    APIv1::Notifications
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
      expect(notification_after.tags[0].ip).to eq(local_ip)
      expect(notification_after.tags[0].created_at).not_to be_nil
      expect(notification_after.tags[0].created_at).to be_within(10.second).of Time.now

      # check other
      notification_after = Notification.find(notification2.id)
      expect(notification_after.tags).to be_empty
    end
  end
end
# let!(:previous_requests) { (1..10).each { |number| RateLimit.create(ip_address: request_ip, requested_at: number.minutes.ago)} }
