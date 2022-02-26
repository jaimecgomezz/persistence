# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Operation errors.
    class OperationError < Error
      def initialize(msg)
        message = "Operation error: #{msg}"
        super(message)
      end
    end
  end
end
