# frozen_string_literal: true

module Persistence
  module Transformers
    # Transforms an Engine result into the Entity provided, assuming that the
    # entity itself is capable of dealing with the attributes after the
    # initialization.
    class InitializerTransformer
      def initialize(entity)
        @entity = entity
      end

      def one(item)
        entity.new(item)
      rescue ArgumentError
        msg = "#{self.class}: #{entity} doesn't expects attributes on .new"
        raise(Persistence::Errors::TransformerError, msg)
      end

      def many(items, pagination)
        transformed = items.map { |item| one(item) }

        { items: transformed, _pagination: pagination }
      end
    end
  end
end
