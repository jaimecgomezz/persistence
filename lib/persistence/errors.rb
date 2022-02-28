# frozen_string_literal: true

module Persistence
  # Contains Errors that describe exceptions that can be triggered during the
  # execution of any Persistence namespace component.
  module Errors
  end
end

require_relative 'errors/error'
require_relative 'errors/engine_error'
require_relative 'errors/operation_error'
require_relative 'errors/transformer_error'
require_relative 'errors/driver_error'
require_relative 'errors/repository_error'
