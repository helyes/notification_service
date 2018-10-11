require 'socket'

class NotificationSpecHelper
  # To validate timestamp fields in response bodies
  # Accepted format: 2018-10-08T21:12:45.881+10:00
  # Let's just not go crazy here. It allows 14th months and 99 minutes etc but for testing purposes it is safe enough
  TIMESTAMP_REGEX = '^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{1,3}\+\d\d:\d\d$'.freeze

  def self.fetch_entities_as_hash(json_response)
    response_hash = JSON.parse json_response
    response_hash['notifications']
  end

  def self.fetch_first_entity_as_hash(json_response)
    response_hash = JSON.parse json_response
    response_hash['notifications'][0]
  end

  def self.fetch_first_error_as_hash(json_response)
    response_hash = JSON.parse json_response
    response_hash['errors'][0]
  end

  def self.local_ip
    Socket.ip_address_list[0].ip_address
  end
end
