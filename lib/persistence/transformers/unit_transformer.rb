# frozen_string_literal: true

module Persistence
  module Transformers
    # Simple transformers that does nothing but deliver the Engine result with
    # no extra processing. Its main purpose is to follow the Null Pattern.
    class UnitTransformer
      def one(item)
        item
      end

      def many(items, pagination)
        { items: items, _pagination: pagination }
      end
    end
  end
end
