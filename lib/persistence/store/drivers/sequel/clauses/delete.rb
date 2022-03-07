module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's DELETE clause.
          class Delete
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              ["DELETE FROM ONLY #{operation.source}", params]
            rescue NoMethodError
              msg = "The Operation doesn't has a @source defined"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
