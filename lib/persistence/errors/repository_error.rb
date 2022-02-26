# frozen_string_literal: true

module Persistence
  module Errors
    # A specialization of the base Error intended to better describe
    # Repository errors.
    class RepositoryError < Error
      def initialize(msg)
        message = "Repository error: #{msg}"
        super(message)
      end
    end
  end
end
