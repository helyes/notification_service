module API
  module Formatter
    class ErrorFormatter < BaseFormatter
    def self.call(message, _backtrace, _options, env)
      msg = message&.capitalize
      payload = { message: msg }
      body = init_body(env)
      add_item_count(body, payload)
      body['response_type'] = 'error'
      body['errors'] = [payload]
      body.to_json
    end
    end
  end
end
