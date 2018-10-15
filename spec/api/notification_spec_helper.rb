require 'socket'
# rubocop:disable Metrics/AbcSize

module Spec
  module NotificationSpecHelper
    # To validate timestamp fields in response bodies
    # Accepted format: 2018-10-08T21:12:45.881+10:00
    # Let's just not go crazy here. It allows 14th months and 99 minutes etc but for testing purposes it is safe enough
    TIMESTAMP_REGEX = '^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{1,3}\+\d\d:\d\d$'.freeze

    def fetch_entities_as_hash(json_response)
      response_hash = JSON.parse json_response
      response_hash['notifications']
    end

    def fetch_first_entity_as_hash(json_response)
      response_hash = JSON.parse json_response
      response_hash['notifications'][0]
    end

    def fetch_first_error_as_hash(json_response)
      response_hash = JSON.parse json_response
      response_hash['errors'][0]
    end

    def local_ip
      Socket.ip_address_list[0].ip_address
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
  end
end
# rubocop:enable Metrics/AbcSize
