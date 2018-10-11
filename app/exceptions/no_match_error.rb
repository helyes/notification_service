class NoMatchError < StandardError
  def initialize(msg = 'No matching records found')
    super
  end
end
