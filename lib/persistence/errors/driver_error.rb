# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Driver errors.
    class DriverError < Error
      def initialize(msg)
        message = "Driver error: #{msg}"
        super(message)
      end
    end
  end
end
