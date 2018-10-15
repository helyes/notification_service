module APIv1
  class Base < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    # helpers do
    #   def return_no_content
    #     status :no_content
    #     ''
    #   end
    # end

    mount APIv1::Notifications

    add_swagger_documentation api_version: 'v1',
                              info: {
                                title: 'Notifications CRUD',
                                description: 'Documentation for version 1',
                                contact_name: 'Andras'
                              },
                              # Redcarpet and rouge for formatting NOTE-s
                              markdown: GrapeSwagger::Markdown::RedcarpetAdapter.new(render_options: { highlighter: :rouge })
  end
end
