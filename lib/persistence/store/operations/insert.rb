# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an INSERT Directive.
      class Insert < Operation
        include Capabilities::Retriever

        # Pending
        include Capabilities::Requirer
        include Capabilities::Setter
      end
    end
  end
end
