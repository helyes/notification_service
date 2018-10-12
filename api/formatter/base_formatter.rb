module API
  module Formatter
    class BaseFormatter
      PATH_SEPARATOR = '/'.freeze
      def self.init_body(env)
        now = Time.now
        start_time = env['auc_starttime']
        { start_timestamp: start_time,
          end_timestamp: now,
          time_taken_ms: time_taken(start_time, now),
          response_type: 'success',
          executor: executor(env),
          path: path(env) }
      end

      def self.time_taken(start_time, end_time)
        ((end_time - start_time) * 1000).round(2)
      end

      def self.add_item_count(body, object)
        body[:item_count] = (object.class == Array && object.count) || 1
      end

      def self.executor(env)
        # rubocop:disable Lint/AmbiguousBlockAssociation:
        endpoint = env[Grape::Env::API_ENDPOINT]
        result = []
        result << endpoint.namespace == PATH_SEPARATOR ? '' : endpoint.namespace
        result.concat endpoint.options[:path].map { |path| path.to_s.sub(PATH_SEPARATOR, '') }
        endpoint.options[:for].to_s << result.join(PATH_SEPARATOR)
        # rubocop:enable Lint/AmbiguousBlockAssociation:
      end

      def self.path(env)
        env[Grape::Env::API_ENDPOINT].request.path
      end

    end
  end
end
