module LogManager
  class RegistrationsManager
    include Singleton

    def should_trigger?(template_name, entity, log_level)
      return true unless log_level == :error
      register_call(template_name, entity, log_level) <= 1
    end

    def register_call(template_name, entity, log_level)
      key = key_for(template_name, entity, log_level)
      registrations = redis_client.incr(key)
      if registrations == 1
        redis_client.expire(key, events_time_window)
      end
      registrations
    end

    def key_for(template_name, entity, log_level)
      "log_manager:#{entity}:#{template_name}:#{log_level}"
    end

    protected

    def redis_client
      LogManager.redis_client
    end

    def events_time_window
      LogManager.events_time_window
    end

  end
end
