# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Adapter errors.
    class AdapterError < Error
      def initialize(msg)
        message = "Adapter error: #{msg}"
        super(message)
      end
    end
  end
end
