require 'grape'
class PayloadEnricher < Grape::Middleware::Globals
  def initialize(app)
    @app = app
    puts "Initialized #{Time.now}"
  end

  def response_data_paginated?
    env['auc_pagination_meta']
  end

  def build_next_page_uri
    next_page_query_hash = {}.merge(env['rack.request.query_hash'])
    next_page_query_hash['offset'] = next_page_query_hash['offset'].to_i + next_page_query_hash['limit'].to_i
    "#{env['PATH_INFO']}?#{URI.encode_www_form(next_page_query_hash)}"
  end

  def add_pagination_info(body)
    return unless response_data_paginated?

    headers['x-has-more'] = env['auc_pagination_meta'][:has_more].to_s
    body[:has_more] = env['auc_pagination_meta'][:has_more] ? true : false
    body[:next_page] = build_next_page_uri if env['auc_pagination_meta'][:has_more]
  end

  def add_item_count(body, response_hash)
    body[:item_count] = (response_hash.class == Array && response_hash.count) || 1
  end

  def add_entity(body, response_hash)
    entity = ApiHelper.entity_name(env)
    body[entity] = (response_hash.class == Array && response_hash) || [response_hash]
  end

  def init_body
    now = Time.now
    start_time = env['auc_starttime']
    { start_timestamp: start_time,
      end_timestamp: now,
      time_taken_ms: ApiHelper.time_taken(start_time, now),
      response_type: 'success',
      executor: ApiHelper.executor(env),
      path: ApiHelper.path(env),
      item_count: 0 }
  end

  def successful(app_response)
    status, headers, response = app_response

    if response.respond_to?(:body)
      body = init_body
      response_hash = JSON.parse(response.body.first)
      add_pagination_info(body)
      add_item_count(body, response_hash)
      add_entity(body, response_hash)
      response_string = body.to_json
    else
      response_string = ''
    end

    #Log.instance.log_request(:debug, env, "XXXResponse: #{response_string}")
    headers['Content-Length'] = response_string.length.to_s

    [status, headers, [response_string]]
  end

  def unsuccessful(exception)
    raise exception
  end

  def call(env)
    start_time ||= Time.now
    @env = env
    @env['auc_starttime'] = start_time
    begin
      response = @app.call(@env)
      successful response
    rescue => e
      unsuccessful(e)
    end
  end
end
