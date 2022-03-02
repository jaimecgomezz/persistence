# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an UPDATE Directive.
      class Update < Operation
        include Capabilities::Filter
        include Capabilities::Requirer
        include Capabilities::Retriever
        include Capabilities::Setter
      end
    end
  end
end
