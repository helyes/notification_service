module APIv1
  # API exposing notifications
  # rubocop:disable Metrics/ClassLength
  class Notifications < Grape::API
    use ::Timestamper

    # Adds pagination parameters. Max limit is a magic number, move it to props
    def self.paginate(options = {})
      options.reverse_merge!(
        offset:  0,
        limit: 20
      )
      params do
        optional :offset, type: Integer, default: options[:offset], desc: 'Result offset'
        optional :limit, type: Integer, default: options[:limit], desc: 'Number of elements to return', values: 1..50
      end
    end

    rescue_from NotFoundError, ActiveRecord::RecordNotFound do |exception|
      Log.instance.log_request(:warn, env, exception)
      error!('Notification not found', 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |exception|
      Log.instance.log_request(:warn, env, exception)
      error!(exception.message, 409)
    end

    rescue_from NoMatchError do |exception|
      error!(exception.to_s, 404)
    end

    helpers do
      def notification_params(params)
        {
          summary:  params[:summary],
          description: params[:description]
        }
      end

      # Adds auc_pagination_meta to rack env to be used by middlewares
      # Sets has_more field value by checking if resultset has more elements than limit
      # Chops result array to size of limit
      # Has to be handled here as default params (limit=?) are not accessible in rack env
      def paginated(result, params, with = API::Entities::Notification)
        env['auc_pagination_meta'] = params.to_hash
        if result.respond_to?(:count) && result.count > params[:limit]
          env['auc_pagination_meta'][:has_more] = true
          result = result[0, params[:limit]]
        end
        present result, with: with
      end
    end

    resource :notifications do
      desc 'Returns notification list'
      paginate
      get do
        paginated Notification.order(:created_at).offset(params[:offset]).limit(params[:limit] + 1),
                  params
      end

      desc 'Returns notifications that has/not been tagged by given tag'
      params do
        optional :tag, type: String
        optional :exclude, type: Boolean, default: false
      end
      paginate
      get '/tag/:tag' do
        # nasty - make it prepared st
        sql = 'SELECT n.*' \
              ' FROM notifications n' \
              " WHERE #{'NOT' if params[:exclude]} EXISTS (" \
              '  SELECT 1 FROM tags e' \
              '  WHERE e.notification_id = n.id' \
              "    AND e.ip = '#{env['REMOTE_ADDR']}'" \
              "    AND e.label = '#{params[:tag]}')"\
              ' ORDER BY n.created_at'\
              " LIMIT #{params[:limit] + 1}"\
              " OFFSET #{params[:offset]}"\

        paginated Notification.find_by_sql(sql), params
      end

      desc 'Returns notification by id'
      params do
        requires :id, type: Integer
      end
      get ':id' do
        notification = Notification.find(params[:id])
        present notification, with: API::Entities::Notification
      end

      desc 'Returns notification by summary'
      params do
        requires :summary, type: String
      end
      paginate
      get 'summary/:summary' do
        notifications = Notification.where('summary LIKE ?', "%#{params[:summary]}%")
                                    .order(:created_at)
                                    .offset(params[:offset])
                                    .limit(params[:limit] + 1)
        raise NoMatchError if notifications.blank?

        paginated notifications, params
      end

      desc 'Creates new notification'
      params do
        requires :summary, type: String
        requires :description, type: String
      end
      post do
        notification = Notification.new(notification_params(params))
        notification.save!
        present notification, with: API::Entities::Notification
      end

      desc 'Updates notification'
      params do
        requires :id, type: Integer, desc: 'Notification id'
        requires :summary,  type: String, desc: 'Summary, max length 160 chars'
        requires :description, type: String, desc: 'Description, max length 2000 chars'
      end
      put ':id' do
        notification = Notification.find(params[:id])
        notification.update_attributes!(notification_params(params))
        present notification, with: API::Entities::Notification
        # return_no_content
      end

      desc 'Tags notification' do
        detail <<-NOTE
        Adds a **tag** to given notification
        -----------------

      The tag is linked to incoming incoming request **ip** address

      This allows caller to filter messages by tag names in subsequent GET /tag/{tag} calls

        NOTE
      end
      params do
        requires :id, type: Integer
        requires :tag, type: String
      end
      put ':id/tag/:tag' do
        # notification = Notification.find(params[:id]) # keeping it decoupled
        tag = Tag.new(notification_id: params[:id],
                      label: params[:tag],
                      ip: env['REMOTE_ADDR'])
        tag.save!
        present tag, with: API::Entities::Tag
      end

      desc 'Deletes notification'
      params do
        requires :id, type: Integer
      end
      delete ':id' do
        notification = Notification.find(params[:id])
        notification.destroy!
        present notification, with: API::Entities::Notification
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
