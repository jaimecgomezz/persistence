# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      class Discard < Operation
        include Capabilities::Filter
        include Capabilities::Retriever
        include Capabilities::Setter

        def initialize(source)
          values = Hash[[[Persistence::Config::DISCARD_ATTRIBUTE, Time.now.utc.to_s]]]
          set(**values)
          super(source)
        end
      end
    end
  end
end
