module API
  module Formatter
    class SuccessFormatter < BaseFormatter
      # this should be handled by rack midleware. Having it here only to show that it can be done this way too
      def self.call(object, env)
        #puts "XXXXXXObject: #{object}"
        #puts "XXXXXXObject: #{object.to_json}"
        body = init_body(env)
        add_item_count(body, object)
        add_pagination_info(body, env)
        add_entity(body, object, env)
        body.to_json
      end

      def self.response_data_paginated?(env)
        env['auc_pagination_meta']
      end

      def self.add_entity(body, response_hash, env)
        entity = entity_name(env)
        body[entity] = (response_hash.class == Array && response_hash) || [response_hash]
      end

      def self.add_pagination_info(body, env)
        return unless response_data_paginated?(env)

        body[:has_more] = env['auc_pagination_meta'][:has_more] ? true : false
        body[:next_page] = build_next_page_uri(env) if env['auc_pagination_meta'][:has_more]
      end

      def self.build_next_page_uri(env)
        next_page_query_hash = {}.merge(env['rack.request.query_hash'])
        next_page_query_hash['offset'] = next_page_query_hash['offset'].to_i + next_page_query_hash['limit'].to_i
        "#{env['PATH_INFO']}?#{URI.encode_www_form(next_page_query_hash)}"
      end

      def self.entity_name(env)
        endpoint = env[Grape::Env::API_ENDPOINT].namespace
        endpoint = endpoint[1..-1] if endpoint.start_with? PATH_SEPARATOR
        endpoint
      rescue => e
        Log.instance.log_exception("Could not determine entity name for #{endpoint}", e)
        # letting it go with unknowns
        'unknowns'
      end

    end
  end
end
