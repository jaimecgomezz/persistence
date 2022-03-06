# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      class Discard < Operation
        include Capabilities::Filter
        include Capabilities::Retriever
        include Capabilities::Setter
      end
    end
  end
end
