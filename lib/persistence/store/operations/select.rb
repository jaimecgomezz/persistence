# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a READ Directive.
      class Select < Operation
        include Capabilities::Sourcer
        include Capabilities::Filter
        include Capabilities::Aggregator
        include Capabilities::Retriever
        include Capabilities::Orderer
        include Capabilities::Differentiator
        include Capabilities::Grouper
        include Capabilities::Joiner
        include Capabilities::Requirer
        include Capabilities::Paginator
        include Capabilities::DiscardedManager

        # Pending
        include Capabilities::Preloader

        def initialize(source)
          exclude_discarded
          super(source)
        end

        def after(results)
          return results if pagination[:limit] != 1

          results.first
        end
      end
    end
  end
end
