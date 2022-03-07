# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's UPDATE clause.
          class Update
            attr_reader :operation

            def initialize(operation)
              validate_source!(operation)
              @operation = operation
            end

            def build
              "UPDATE ONLY #{operation.source}"
            end

            private

            def validate_source!(operation)
              return if operation.respond_to?(:source) && operation.source

              msg = "The Operation doesn't has a source defined"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
