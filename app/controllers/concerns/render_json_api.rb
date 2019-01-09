module RenderJsonApi

  def index
    super do |format|
      format.jsonapi { jsonapi_render(entries) }
      yield(format) if block_given?
    end
  end

  def show
    super do |format|
      format.jsonapi { jsonapi_render(entry) }
      yield(format) if block_given?
    end
  end

  def jsonapi_pagination(resources)
    return unless action_name == 'index' && resources.present?
    JsonApi::Pager.new(resources, model_class, safe_params).render
  end

  def jsonapi_class
    @jsonapi_class ||= Hash.new do |hash, class_name|
      hash[class_name] = JsonApi::Serializer.new(class_name).build
    end
  end

  def jsonapi_expose
    { controller: self, current_user: current_user }
  end

  def rescued_polymorphic_path(*objects)
    polymorphic_path(*objects) rescue nil
  end

  private

  def json_render_entries
    model_serializer? ? super : jsonapi_render(entries)
  end

  def json_render_entry
    model_serializer? ? super : jsonapi_render(entry)
  end

  def model_serializer?
    model_serializer rescue nil
  end

  def jsonapi_render(object)
    # render jsonapi: object, include: jsonapi_include, fields: jsonapi_fields, expose: jsonapi_expose
    render jsonapi: JsonApi::Serializer.new(model_class.name).build.new(object).serialized_json
  end

  def jsonapi_include
    params.permit(:include)[:include] || []
  end

  def jsonapi_fields
    params.permit(fields: {}).fetch('fields', []).to_h.collect do |model, string|
      [model, string.split(',')]
    end.to_h
  end

end
