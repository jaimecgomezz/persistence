# frozen_string_literal: true

module Persistence
  module Transformers
    # Transforms an Engine result into the Entity provided by setting each
    # attribute contained in said result into an initialized entity.
    class SetterTransformer
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end

      def one(item)
        entity.new.tap do |instance|
          item.each do |key, value|
            accessor = "#{key}="
            instance.send(accessor, value)
          rescue NoMethodError
            msg = "#{self.class}: No :#{key} setter available for #{entity.name}"
            raise(Persistence::Errors::TransformerError, msg)
          end
        end
      end

      def many(items, pagination)
        transformed = items.map { |item| one(item) }

        { items: transformed, _pagination: pagination }
      end
    end
  end
end
