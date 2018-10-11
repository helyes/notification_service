module ApiHelper
  PATH_SEPARATOR = '/'.freeze

  def self.executor(env)
    # rubocop:disable Lint/AmbiguousBlockAssociation:
    endpoint = env[Grape::Env::API_ENDPOINT]
    result = []
    result << endpoint.namespace == PATH_SEPARATOR ? '' : endpoint.namespace
    result.concat endpoint.options[:path].map { |path| path.to_s.sub(PATH_SEPARATOR, '') }
    endpoint.options[:for].to_s << result.join(PATH_SEPARATOR)
    # rubocop:enable Lint/AmbiguousBlockAssociation:
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

  def self.path(env)
    env[Grape::Env::API_ENDPOINT].request.path
  end

  def self.time_taken(start_time, end_time)
    ((end_time - start_time) * 1000).round(2)
  end
end
