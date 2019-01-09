class ApidocsController < ApplicationController
  skip_authorization_check

  layout false

  def show
    respond_to do |format|
      format.html
      format.json { render json: generate_doc }
    end
  end

  private

  def generate_doc
    Swagger::Setup.new(self, controller_classes).run
  end

  def controller_classes
    Rails.application.eager_load! if Rails.env.development?
    #(read_controllers + crud_controllers).sort_by(&:name)
    json_api_controllers
  end

  def json_api_controllers
    ActionController::Base.descendants.select { |model| model.include?(RenderJsonApi) }.select do |controller|
      controller.model_class rescue false
    end
  end

  def crud_controllers
    CrudController.subclasses.reject do |controller_class|
      # next if aggregates?
      excluded_classes = [
        :CrudTestModelsController,
        :ManageController
      ]
      excluded_classes.include? controller_class.name.to_sym
    end.compact
  end

  def read_controllers
    ReadController.subclasses - [CrudController]
  end

end
