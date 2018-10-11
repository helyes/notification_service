require 'syslog/logger'
require 'socket'

class Log
  include Singleton

  def initialize
    @logger = logger
    @hostname = Socket.gethostname
    @pid = Process.pid
    @appname = 'AUC notifications'
    apply_formatter
  end

  %w{debug info warn error}.each do |level|
    define_method(level) { |msg| @logger.send(level, msg) }
  end

  def log(level, msg)
    log = self.method(level)
    log.call(msg)
  end

  def log_exception(msg, e)
    msg2 = "#{e.message.capitalize} : (#{e.class}) : #{e.backtrace.first(10).join("\n")}"
    log = self.method(:error)
    log.call("#{msg}. #{msg2}")
  end

  def log_request(level, env, status)
    msg = "#{env['REQUEST_METHOD']} #{env['REQUEST_URI']} @ #{env['REMOTE_ADDR']} #{status}"
    log = self.method(level)
    log.call(msg)
  end

  private

  def logger
    if production?
      Logger.new appname
    else
      Logger.new(STDOUT)
    end
  end

  def production?
    ENV['RACK_ENV'] == 'production'
  end

  def apply_formatter
    @logger.formatter = ->(severity, time, progname, msg) {
      "#{time.strftime '%FT%T%:z'} [#{severity}] [#{@hostname}] [#{progname || @appname}] [#{@pid}] #{msg}\n"
    }
  end
end
