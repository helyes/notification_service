module API
  module ErrorFormatter
    # this should be handled by rack midleware. Having it here only to show that it can be done this way too
    def self.call(message, _backtrace, _options, env)
      now = Time.now
      msg = message&.capitalize
      { start_timestamp: env['auc_starttime'],
        end_timestamp: now,
        time_taken_ms: ((now - env['auc_starttime']) * 1000).round(2),
        response_type: 'error',
        executor: ApiHelper.executor(env),
        path: ApiHelper.path(env),
        item_count: 1,
        errors: [{ message: msg }] }.to_json
    end
  end
end
