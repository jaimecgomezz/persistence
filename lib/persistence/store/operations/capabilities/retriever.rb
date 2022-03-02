# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of retrieving specific fields from results.
        module Retriever
          def retrieve(fields)
          end
        end
      end
    end
  end
end
