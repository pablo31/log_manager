require "spec_helper"

RSpec.describe LogManager do

  let(:log_client) { double }

  before :each do
    LogManager.clear_templates!
    LogManager.log_client = log_client
    LogManager.redis_client = MockRedis.new
  end

  def expect_one_log_with(message)
    [:debug, :info, :warn, :error].each do |log_level|
      expect(log_client).to receive(log_level).with(message).once
    end
  end

  def expect_multiple_logs_with(message, times)
    [:debug, :info, :warn].each do |log_level|
      expect(log_client).to receive(log_level).with(message).exactly(times).times
    end
    [:error].each do |log_level|
      expect(log_client).to receive(log_level).with(message).once
    end
  end

  context 'generic template creation' do

    it 'should register and trigger a new template' do
      # template creation
      template_name = :schedule_triggered
      template_message = "Schedule triggered successfully"
      LogManager.add_template(template_name, template_message)
      # expectations
      expect_one_log_with(template_message)
      # trigger
      LogManager.debug(:schedule_triggered)
      LogManager.info(:schedule_triggered)
      LogManager.warn(:schedule_triggered)
      LogManager.error(:schedule_triggered)
    end

    it 'should register and trigger a new template with embedded parameters' do
      # template creation
      template_name = :schedule_triggered
      template_message = "Schedule triggered successfully at %{time}"
      LogManager.add_template(template_name, template_message)
      # expectations
      time = Time.now.to_i
      expect_one_log_with(template_message % { time: time })
      # trigger
      LogManager.debug(:schedule_triggered, time: time)
      LogManager.info(:schedule_triggered, time: time)
      LogManager.warn(:schedule_triggered, time: time)
      LogManager.error(:schedule_triggered, time: time)
    end

  end

  context 'entity template creation' do

    it 'should register and trigger a new template for certain entity' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule triggered successfully'
      LogManager.add_template(template_name, template_message)
      # expectations
      expect_one_log_with(template_message)
      # trigger
      entity = 'scheduler_number_one'
      LogManager.debug(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.error(:schedule_triggered, entity)
    end

    it 'should register and trigger a new template for certain entity with embedded parameters' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule triggered successfully at %{time}'
      LogManager.add_template(template_name, template_message)
      # expectations
      time = Time.now.to_i
      expect_one_log_with(template_message % { time: time })
      # trigger
      entity = 'scheduler_number_one'
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.error(:schedule_triggered, entity, time: time)
    end

    it 'should register and trigger a new template for certain entity with that entity in the message' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule for %{entity} triggered successfully'
      LogManager.add_template(template_name, template_message)
      # expectations
      entity = 'scheduler_number_one'
      expect_one_log_with(template_message % { entity: entity })
      # trigger
      LogManager.debug(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.error(:schedule_triggered, entity)
    end

    it 'should register and trigger a new template for certain entity with that entity in the message and embedded parameters' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule for %{entity} triggered successfully at %{time}'
      LogManager.add_template(template_name, template_message)
      # expectations
      entity = 'scheduler_number_one'
      time = Time.now.to_i
      expect_one_log_with(template_message % { entity: entity, time: time })
      # trigger
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.error(:schedule_triggered, entity, time: time)
    end

  end

  context 'entity template creation and double trigger' do

    it 'should register and trigger a new template for certain entity and trigger it only once' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule triggered successfully'
      LogManager.add_template(template_name, template_message)
      # expectations
      expect_multiple_logs_with(template_message, 2)
      # trigger
      entity = 'scheduler_number_one'
      LogManager.debug(:schedule_triggered, entity)
      LogManager.debug(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.error(:schedule_triggered, entity) # double error
      LogManager.error(:schedule_triggered, entity) # double error
    end

    it 'should register and trigger a new template for certain entity with embedded parameters and trigger it only once' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule triggered successfully at %{time}'
      LogManager.add_template(template_name, template_message)
      # expectations
      time = Time.now.to_i
      expect_multiple_logs_with(template_message % { time: time }, 2)
      # trigger
      entity = 'scheduler_number_one'
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.error(:schedule_triggered, entity, time: time) # double error
      LogManager.error(:schedule_triggered, entity, time: time) # double error
    end

    it 'should register and trigger a new template for certain entity with that entity in the message' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule for %{entity} triggered successfully'
      LogManager.add_template(template_name, template_message)
      # expectations
      entity = 'scheduler_number_one'
      expect_multiple_logs_with(template_message % { entity: entity }, 2)
      # trigger
      LogManager.debug(:schedule_triggered, entity)
      LogManager.debug(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.info(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.warn(:schedule_triggered, entity)
      LogManager.error(:schedule_triggered, entity) # double error
      LogManager.error(:schedule_triggered, entity) # double error
    end

    it 'should register and trigger a new template for certain entity with that entity in the message and embedded parameters' do
      # template creation
      template_name = :schedule_triggered
      template_message = 'Schedule for %{entity} triggered successfully at %{time}'
      LogManager.add_template(template_name, template_message)
      # expectations
      entity = 'scheduler_number_one'
      time = Time.now.to_i
      expect_multiple_logs_with(template_message % { entity: entity, time: time }, 2)
      # trigger
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.debug(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.info(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.warn(:schedule_triggered, entity, time: time)
      LogManager.error(:schedule_triggered, entity, time: time) # double error
      LogManager.error(:schedule_triggered, entity, time: time) # double error
    end

  end

end
