module ApiHelper
  PATH_SEPARATOR = '/'.freeze

  def self.time_taken(start_time, end_time)
    ((end_time - start_time) * 1000).round(2)
  end
end
