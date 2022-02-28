# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation being capable of requiring Operations.
        module Requirable
          def require(operations); end
        end
      end
    end
  end
end
