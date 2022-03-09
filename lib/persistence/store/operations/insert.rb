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

        def after(results)
          return results unless results.size == 1

          results.first
        end
      end
    end
  end
end
