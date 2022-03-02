# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of aggregating result fields.
        module Aggregator
          def aggregate(fields)
          end
        end
      end
    end
  end
end
