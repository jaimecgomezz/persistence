# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation being capable of requiring tables to being
        # available at execution time.
        module Requirer
          def require(operations); end
        end
      end
    end
  end
end
