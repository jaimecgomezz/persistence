# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of ordering results.
        module Orderer
          def order(order)
          end
        end
      end
    end
  end
end
