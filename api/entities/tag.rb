module API
  module Entities
    class Tag < Grape::Entity
      expose :id
      expose :ip, documentation: { type: 'string', desc: 'Tagger remote ip address' }
      expose :label, documentation: { type: 'string', desc: 'Tag label type' }
      expose :created_at, documentation: { type: 'timestamp', desc: 'Tag creation timestamp' }
    end
  end
end
