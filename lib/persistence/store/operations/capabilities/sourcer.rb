# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of overwriting its source.
        module Sourcer
          # Simply overwrites the @resource instance variable.
          def from(source)
            case source
            when Symbol, String
              @source = source
            else
              invalid_source!
            end

            self
          end

          private

          def invalid_source!
            msg = "Invalid source provided to #from"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
