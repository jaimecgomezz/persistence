# frozen_string_literal: true

module Persistence
  module Store
    module Drivers
      module Sequel
        module Clauses
          class Offset
            attr_reader :operation, :params

            def initialize(operation, params)
              @operation = operation
              @params = params
            end

            def build
              offset = operation.pagination[:offset]

              return ["", params] unless offset

              ["OFFSET #{offset}", params]
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
