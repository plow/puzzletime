module Swagger
  class Setup
    attr_reader :controller, :controller_classes

    def initialize(controller, controller_classes)
      @controller = controller
      @controller_classes = controller_classes
    end

    def run
      classes = [setup_metadata, setup_controllers].flatten
      Swagger::Blocks.build_root_json(classes)
    end

    def host
      uri = URI.parse(controller.request.url)
      @host = "#{uri.host}:#{uri.port}"
    end

    def json_api_mimetype
      'application/vnd.api+json' #TODO read from fast_jsonapi JSONAPI::Rails::Railtie::MEDIA_TYPE
    end

    def setup_tags(swagger_doc)
      Swagger::TagsSetup.new(swagger_doc).run
    end

    private

    def setup_metadata # rubocop:disable Metrics/MethodLength
      ApidocsController.instance_exec(self) do |helper|
        include Swagger::Blocks
        swagger_root do
          key :swagger, '2.0'
          info do
            key :version, Puzzletime.version
            key :title, 'Puzzletime'
            contact do
              key :name, 'Puzzletime Team'
            end
          end
          helper.setup_tags(self)
          key :host, helper.host
          key :basePath, '/'
          key :docExpansion, 'none'
          key :produces, [helper.json_api_mimetype]
          key :consumes, [helper.json_api_mimetype]
        end
      end
      ApidocsController
    end

    def setup_controllers
      controller_classes.collect do |controller_class|
        has_path = setup_controller(controller_class)
        setup_model(controller_class.model_class) if has_path

        [controller_class, controller_class.model_class]
      end
    end

    def setup_model(model_class)
      model_class.instance_exec(self) do |_helper|
        include Swagger::Blocks
        swagger_schema model_class.name.to_sym do
          model_class.columns.each do |column|
            property column.name do
              key :type, column.type
            end
          end
        end
      end
    end

    def setup_controller(controller_class)
      controller_class.send :include, Swagger::Blocks
      Swagger::ControllerSetup.new(controller_class).run
      Swagger::NestedControllerSetup.new(controller_classes, controller_class).run
    end

  end

end
