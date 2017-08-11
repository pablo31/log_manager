module LogManager
  class TemplatesManager
    include Singleton

    def initialize
      clear_templates!
    end

    def add_template(name, message)
      template = Template.new(name, message)
      @templates[name] = template
    end

    def find(template_name)
      @templates[template_name]
    end

    def clear_templates!
      @templates = Hash.new
    end

  end
end
