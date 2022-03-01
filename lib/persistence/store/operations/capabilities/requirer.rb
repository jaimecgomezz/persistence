# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation being capable of requiring Operations.
        module Requirer
          def require(operations); end
        end
      end
    end
  end
end
