module API
  class Base < Grape::API
    error_formatter :json, API::ErrorFormatter
    mount APIv1::Base
  end
end
