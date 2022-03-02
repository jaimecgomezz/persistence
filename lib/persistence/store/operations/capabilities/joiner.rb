# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of joining external tables in the result.
        module Joiner
          def join(table); end
        end
      end
    end
  end
end
