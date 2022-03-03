# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a READ Directive.
      class Select < Operation
        include Capabilities::Filter
        include Capabilities::Aggregator
        include Capabilities::Retriever

        # Pending
        include Capabilities::Requirer
        include Capabilities::Preloader
        include Capabilities::Differentiator
        include Capabilities::Grouper
        include Capabilities::Joiner
        include Capabilities::Orderer
        include Capabilities::Paginator
      end
    end
  end
end
