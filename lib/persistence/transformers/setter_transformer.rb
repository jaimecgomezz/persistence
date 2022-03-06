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

      def one(result)
        return if result.nil?

        entity.new.tap do |instance|
          result.each do |key, value|
            accessor = "#{key}="
            instance.send(accessor, value)
          rescue NoMethodError
            msg = "#{self.class}: No :#{key} setter available for #{entity.name}"
            raise(Persistence::Errors::TransformerError, msg)
          end
        end
      end

      def many(results)
        results.map { |result| one(result) }
      end
    end
  end
end
