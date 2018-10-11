class Tag < ActiveRecord::Base
  belongs_to :notification
  def as_json(options = nil)
    super(options)
  end
end
