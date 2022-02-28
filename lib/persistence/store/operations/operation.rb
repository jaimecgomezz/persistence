# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Defines the basic Operation structure and behaviour.
      class Operation
        attr_reader :table

        def initialize(table)
          @table = table
        end

        # Hook executed after the Driver has run the Directive.
        def finally(result)
          result
        end
      end
    end
  end
end
