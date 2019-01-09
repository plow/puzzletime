class ReadController < ListController
  # Defines before callbacks for the render actions. A virtual callback
  # unifiying render_new and render_edit, called render_form, is defined
  # further down.
  define_render_callbacks :show, :new, :edit

  before_action :entry, only: [:show]

  helper_method :entry, :full_entry_label

  class_attribute :top_show_attrs
  self.top_show_attrs = []

  #prepend RenderJsonApi

  #   GET /entries/1
  #   GET /entries/1.json
  #
  # Show one entry of this model.
  def show
    respond_to do |format|
      format.html
      format.json { json_render_entry }
      yield(format) if block_given?
    end
  end

  private

  def json_render_entry
    render json: entry, serializer: model_serializer, include: '**'
  end

  def json_api_include
    params.permit(include: [])[:include] || []
  end

  def json_api_fields
    params.permit(fields: {}).to_h.collect do |model, string|
      [model.to_sym, string.split(',').collect(&:to_sym)]
    end.to_h
  end

  # Main accessor method for the handled model entry.
  def entry
    model_ivar_get || model_ivar_set(find_entry)
  end

  # Sets an existing model entry from the given id.
  def find_entry
    model_scope.find(params[:id])
  end

  # A label for the current entry, including the model name.
  def full_entry_label
    "#{models_label(false)} <i>#{ERB::Util.h(entry)}</i>".html_safe
  end

end
