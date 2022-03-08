# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          # Class specialized in building SQL's UPDATE clause.
          class Update
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              ["UPDATE ONLY #{operation.source}", params]
            rescue NoMethodError
              msg = "The Operation doesn't has a @source"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
