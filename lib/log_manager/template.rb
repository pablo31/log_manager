module LogManager
  class Template

    def initialize(name, message)
      @name = name
      @message = message
    end

    # trigger(:info)
    # trigger(:info, entity)
    # trigger(:info, entity, params={})
    # trigger(:info, params={})

    def trigger(log_level, *entity_and_params)
      entity, params = entity_and_params_from(*entity_and_params)
      return unless !entity || LogManager.should_trigger?(@name, entity, log_level)
      message = message_for(entity, params)
      LogManager.log_client.send(log_level, message)
    end

    def message_for(entity = nil, params = nil)
      replacements = Hash.new
      replacements.merge!(params) if params
      replacements.merge!(entity: entity) if entity
      replacements.empty? ? @message : @message % replacements
    end

    protected

    def entity_and_params_from(*entity_and_params)
      first = entity_and_params[0]
      last = entity_and_params[1]
      if first
        if first.kind_of?(Hash)
          entity = nil
          params = first
        else
          entity = first
          params = last # hash or nil
        end
      else
        entity = nil
        params = nil
      end
      [entity, params]
    end

  end
end
