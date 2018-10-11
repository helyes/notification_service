module API
  module Entities
    class Notification < Grape::Entity
      expose :id
      expose :summary, documentation: { type: 'string', desc: 'Message summary' }
      expose :description, documentation: { type: 'string', desc: 'Message content' }
    end
  end
end
