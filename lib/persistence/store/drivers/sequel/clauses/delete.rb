module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's DELETE clause.
          class Delete
            attr_reader :operation

            def initialize(operation)
              validate_source!(operation)
              @operation = operation
            end

            def build
              "DELETE FROM ONLY #{operation.source}"
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
