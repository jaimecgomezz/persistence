# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Base Clause class.
          class Clause
            attr_reader :operation

            def initialize(operation)
              @operation = operation
            end
          end
        end
      end
    end
  end
end
