# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Offset
            attr_reader :operation

            def initialize(operation)
              validate_paginator!(operation)
              @operation = operation
            end

            def build
              offset = operation.pagination[:offset]
              return "" unless offset

              "OFFSET #{offset}"
            end

            private

            def validate_paginator!(operation)
              klass = Persistence::Store::Operations::Capabilities::Paginator
              return if operation.class.ancestors.include?(klass)

              msg = "The Operation isn't a Paginator"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
