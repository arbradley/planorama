module ResourceMethods
  extend ActiveSupport::Concern

  def index
    authorize model_class, policy_class: policy_class
    if serializer_class
      render json: @collection,
             each_serializer: serializer_class,
             meta: {
               total: @collection_total,
               page: @page,
               perPage: @per_page
             },
             root: 'data',
             # meta_key: 'header',
             include: includes,
             adapter: :json,
             content_type: 'application/json'
    else
      render json: @collection,
             meta: {
               total: @collection_total,
               page: @page,
               perPage: @per_page
             },
             root: 'data',
             # meta_key: 'header',
             include: includes,
             adapter: :json,
             content_type: 'application/json'
    end
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def show
    authorize @object, policy_class: policy_class
    render_object(@object)
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def create
    model_class.transaction do
      authorize model_class, policy_class: policy_class
      before_save
      @object.save!
      after_save
    end
    after_save_tx
    render_object(@object)
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def update
    model_class.transaction do
      authorize @object, policy_class: policy_class
      before_update
      @object.update!(strip_params(_permitted_params(object_name)))
      @object.reload
      after_update
    end
    after_update_tx
    render_object(@object)
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def destroy
    model_class.transaction do
      authorize @object, policy_class: policy_class
      @object.public_send(object_destroy_method)
      render status: :ok, json: {}.to_json, content_type: 'application/json'
    end
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def restore
    model_class.transaction do
      authorize @object, policy_class: policy_class
      @object.public_send(object_restore_method)
      render_object(@object)
    end
  rescue => ex
    Rails.logger.error ex.message if Rails.env.development?
    Rails.logger.error ex.backtrace.join("\n\t") if Rails.env.development?
    render status: :bad_request, json: {error: ex.message}
  end

  def render_object(object)
    if serializer_class
      render json: object,
             include: includes,
             serializer: serializer_class,
             content_type: 'application/json'
    else
      render json: object,
             content_type: 'application/json'
    end
  end

  def before_update
  end

  def before_save
  end

  def after_update
  end

  def after_save
  end

  def after_save_tx
  end

  def after_update_tx
  end

  def object_destroy_method
    :destroy
  end

  def object_restore_method
  end

  def action
    params[:action].to_sym
  end

  def collection
    base = if belong_to_class
             parent = belong_to_class.find belongs_to_param_id
             parent.send(belongs_to_relationship)
           else
             model_class
           end

    @per_page = params[:perPage]&.to_i || model_class.default_per_page
    @page = params[:page]&.to_i || 0
    @order = params[:sortField] || ''
    @direction = params[:sortOrder] || ''
    @filters = JSON.parse(params[:filter]) if params[:filter].present?
    @order.slice!('$.')
    # base
    policy_scope(base, policy_scope_class: policy_scope_class)
      .includes(includes)
      .references(references)
      .where(query(@filters))
      .order("#{@order} #{@direction}")
      .page(@page)
      .per(@per_page)
  end

  def query(filters = nil)
    # Go through the filter and construct the where clause
    return nil unless filters.present?

    table = Arel::Table.new(model_class.table_name)
    q = nil
    filters.each do |k,v|
      next unless v.present?

      a = "#{k}"
      a.slice!('$.')
      type = model_class.columns_hash[a].type

      case type
      when :integer
        part = table[a.to_sym].eq(v.to_i)
      when :boolean
        part = table[a.to_sym].eq(['true', true, 1].include?(v))
      when :string
        part = table[a.to_sym].matches("%#{v}%")
      else
        part = table[a.to_sym].matches("%#{v}%")
      end

      q = q ? q.and(part) : part
    end

    q
  end

  def model_name
    "#{model_class}"
  end

  def model_class
    if defined?(self.class::MODEL_CLASS)
      self.class::MODEL_CLASS.constantize
    else
      self.class.name.sub('Controller', '').singularize.constantize
    end
  end

  def serializer_class
    self.class::SERIALIZER_CLASS.constantize if defined? self.class::SERIALIZER_CLASS
  end

  # authorize @publication, policy_class: PublicationPolicy
  def policy_class
    # return an overide for policy class if there is one
    return self.class::POLICY_CLASS.constantize if defined? self.class::POLICY_CLASS

    # else use the 'global' policy
    # TODO: global policy class

    # if we return none then Pundit's policy finder will be used ...
    return PlannerPolicy
  end

  def policy_scope_class
    return self.class::POLICY_SCOPE_CLASS.constantize if defined? self.class::POLICY_SCOPE_CLASS

    PlannerPolicy::Scope
  end

  def object_name
    controller_name.singularize
  end

  def resource_id
    params[:id]
  end

  def load_resource
    if member_action?
      @object ||= load_resource_instance

      instance_variable_set("@#{object_name}", @object)
    else
      @collection ||= collection
      @collection_total ||= collection.total_count

      instance_variable_set("@#{controller_name}", @collection_total)
      instance_variable_set("@#{controller_name}", @collection)
    end
  end

  def load_resource_instance
    if new_actions.include?(action)
      build_resource
    elsif resource_id
      find_resource
    end
  end

  def find_resource
    if belong_to_class
      parent = belong_to_class.find belongs_to_param_id
      policy_scope(
        parent.send(belongs_to_relationship),
        policy_scope_class: policy_scope_class
      ).find(resource_id)
    else
      policy_scope(model_class, policy_scope_class: policy_scope_class).find(resource_id)
    end
  end

  def build_resource
    if belong_to_class
      parent = belong_to_class.find belongs_to_param_id
      parent.send(belongs_to_relationship).new(strip_params(_permitted_params(object_name)))
    else
      model_class.new(strip_params(_permitted_params(object_name)))
    end
  end

  def collection_actions
    [:index]
  end

  def member_action?
    !collection_actions.include? action
  end

  def new_actions
    [:new, :create]
  end

  def allowed_params
    nil
  end

  def includes
    []
  end

  def references
    []
  end

  def belongs_to_param_id
    nil
  end

  def belong_to_class
    nil
  end

  def belongs_to_relationship
    nil
  end


  def _permitted_params(_object_name)
    if allowed_params
      params.permit(
        allowed_params
      )
    else
      params[_object_name]
    end
  end

  def strip_params(_permitted_params)
    return unless _permitted_params

    _permitted_params.each{|k,v| _permitted_params[k] = v&.strip if v.respond_to?(:strip)}
  end
end
