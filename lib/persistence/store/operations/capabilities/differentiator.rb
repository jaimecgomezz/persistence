# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of returning distinc results.
        module Differentiator
          def distinct(fields)
          end
        end
      end
    end
  end
end
