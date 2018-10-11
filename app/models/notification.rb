class Notification < ActiveRecord::Base
  # validates :subject, uniqueness: true
  has_many :tags
  def as_json(options = nil)
    super({ only: %i[id summary description] }.merge(options || {}))
  end
end
