# Abstract controller providing a basic list action.
# The loaded model entries are available in the view as an instance variable
# named after the +model_class+ or by the helper method +entries+.
#
# The +index+ action lists all entries of a certain model and provides
# functionality to search and sort this list.
# Furthermore, it remembers the last search and sort parameters after the
# user returns from a displayed or edited entry.
class ListController < ApplicationController

  include DryCrud::GenericModel
  prepend DryCrud::Nestable
  include DryCrud::Rememberable
  include DryCrud::RenderCallbacks

  # customized cancan code to authorize with #model_class
  authorize_resource except: :index
  before_action :authorize_class, only: :index

  before_action :set_variant, only: :index

  delegate :list_serializer, to: 'self.class'

  define_render_callbacks :index

  helper_method :entries

  ##############  ACTIONS  ############################################

  #   GET /entries
  #   GET /entries.json
  #
  # List all entries of this model.
  def index
    respond_to do |format|
      format.html { entries }
      format.js { entries }
      format.json { json_render_entries }
      yield(format) if block_given?
    end
  end

  private

  def json_render_entries
    render json: entries, each_serializer: list_serializer, root: model_identifier.pluralize
  end

  # Helper method to access the entries to be displayed in the current index
  # page in an uniform way.
  def entries
    model_ivar_get(true) || model_ivar_set(list_entries)
  end

  # The base relation used to filter the entries.
  # Calls the #list scope if it is defined on the model class.
  #
  # This method may be adapted as long it returns an
  # <tt>ActiveRecord::Relation</tt>.
  # Some of the modules included extend this method.
  def list_entries
    paged(model_scope.list)
  end

  def set_variant
    request.variant = :tabbed if parent
  end

  def page_size
    params.fetch(:page_size, 25)
  end

  def paged(scope)
    scope.page(params[:page]).per(page_size)
  end

  class << self

    def list_serializer
      model_serializer
    end

  end

  def authorize_class
    authorize!(action_name.to_sym, model_class)
  end

  # Include these modules after the #list_entries method is defined.
  include DryCrud::Searchable
  include DryCrud::Sortable

end
