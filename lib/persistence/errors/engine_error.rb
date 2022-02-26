# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Engine errors.
    class EngineError < Error
      def initialize(msg)
        message = "Engine error: #{msg}"
        super(message)
      end
    end
  end
end
