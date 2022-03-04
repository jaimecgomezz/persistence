# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an INSERT Directive.
      class Insert < Operation
        include Capabilities::Retriever
        include Capabilities::Requirer

        # Pending
        include Capabilities::Setter
      end
    end
  end
end
