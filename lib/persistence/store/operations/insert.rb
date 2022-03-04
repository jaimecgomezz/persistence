# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building an INSERT Directive.
      class Insert < Operation
        include Capabilities::Retriever
        include Capabilities::Requirer
        include Capabilities::Setter
        include Capabilities::Reactioner
      end
    end
  end
end
