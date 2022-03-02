# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Defines the basic Operation structure and behaviour.
      class Operation
        attr_reader :resource

        def initialize(resource)
          @resource = resource
        end
      end
    end
  end
end
