module API
  class Base < Grape::API
    error_formatter :json, API::Formatter::ErrorFormatter
    formatter :json, API::Formatter::SuccessFormatter
    mount APIv1::Base
  end
end
