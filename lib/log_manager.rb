require 'singleton'
require 'class_config'
require 'log_manager/version'
require 'log_manager/template'
require 'log_manager/templates_manager'
require 'log_manager/registrations_manager'

module LogManager

  extend ClassConfig
  attr_config :log_client
  attr_config :redis_client
  attr_config :events_time_window, 300 # seconds

  class << self

    def clear_templates!
      TemplatesManager.instance.clear_templates!
    end

    def should_trigger?(*args)
      RegistrationsManager.instance.should_trigger?(*args)
    end

    # interface

    def add_template(*args)
      TemplatesManager.instance.add_template(*args)
    end

    def trigger(log_level, template_name, *args)
      template = TemplatesManager.instance.find(template_name)
      raise "No template present with name '#{template_name}'" unless template
      template.trigger(log_level, *args)
    end

    # helpers

    def debug(*args)
      trigger(:debug, *args)
    end

    def info(*args)
      trigger(:info, *args)
    end

    def warn(*args)
      trigger(:warn, *args)
    end

    def error(*args)
      trigger(:error, *args)
    end

  end

end
