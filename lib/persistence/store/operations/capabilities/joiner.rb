# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of joining external resource in the result.
        module Joiner
          def join(resource)
          end
        end
      end
    end
  end
end
