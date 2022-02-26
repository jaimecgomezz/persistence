# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Transformer errors.
    class TransformerError < Error
      def initialize(msg)
        message = "Transformer error: #{msg}"
        super(message)
      end
    end
  end
end
