class Timestamper
  def initialize(app)
    @app = app
  end

  def call(env)
    env['auc_starttime'] = Time.now
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
