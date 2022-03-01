# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being joined with other tables.
        module Joiner
          def join(table); end
        end
      end
    end
  end
end
