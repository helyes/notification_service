class Notification < ActiveRecord::Base
  validates :summary, length: { minimum: 1, maximum: 160 }
  validates :description, length: { minimum: 1, maximum: 2048 }
  has_many :tags
  def as_json(options = nil)
    super({ only: %i[id summary description] }.merge(options || {}))
  end
end
