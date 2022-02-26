# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Contains modules that should define ONLY 2 methods.
      #
      # #adapter_method
      # Returns the name of the concrete method that transforms the Operation
      # into a Directive. It is also used within Engine's ADAPTERS constant,to
      # dynamically register adapters.
      #
      # #as_<adapter_name>
      # The concrete method that transforms the Operation into a Directive. It
      # is merely symbolic since its main purpose is to raise and exception
      # whenever the Operation that includes the Adapter hasn't implemented this
      # method.
      module Adapters
      end
    end
  end
end

require_relative 'adapters/postgres_adapter'
