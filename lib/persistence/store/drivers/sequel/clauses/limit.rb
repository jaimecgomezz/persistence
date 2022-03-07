# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Limit
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              limit = operation.pagination[:limit]

              return ["", params] unless limit

              ["LIMIT #{limit}", params]
            rescue NoMethodError
              msg = "The Operation isn't a Paginator"
              raise(Persistence::Errors::DriverError, msg)
            end
          end
        end
      end
    end
  end
end
