# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Contains modules that should define ONLY 2 methods.
      #
      # #adapter_method
      # Returns the concrete method that transforms the Operation into a
      # Directive.
      #
      # #as_<adapter_name>
      # The concrete method that transforms the Operation into a Directive.
      #
      # This methods are merely symbolic and the adapter itself is really
      # intended to detect missing implementations on any Operation that
      # includes them. Also, to dynamically register them at the Engine.
      module Adapters
      end
    end
  end
end

require_relative 'adapters/postgres_adapter'
