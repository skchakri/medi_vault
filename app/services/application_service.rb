# frozen_string_literal: true

class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end

  private

  def success(data = {})
    ServiceResult.new(success: true, data: data)
  end

  def failure(errors, data: {})
    ServiceResult.new(success: false, errors: Array(errors), data: data)
  end
end

class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: {}, errors: [])
    @success = success
    @data = data
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
