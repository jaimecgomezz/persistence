# frozen_string_literal: true

module Persistence
  module Transformers
    # Simple transformer that does nothing but deliver the Engine result with
    # no extra processing. Its main purpose is to follow the Null Pattern.
    class IdentityTransformer
      def one(result)
        result
      end

      def many(results)
        results
      end
    end
  end
end
