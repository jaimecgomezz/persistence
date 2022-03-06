# frozen_string_literal: true

module Persistence
  module Transformers
    # Transforms an Engine result into the Entity provided, assuming that the
    # entity itself is capable of dealing with the attributes after the
    # initialization.
    class InitializerTransformer
      attr_reader :entity

      def initialize(entity)
        @entity = entity
      end

      def one(result)
        return if result.nil?

        entity.new(result)
      rescue ArgumentError
        msg = "#{self.class}: #{entity} doesn't expects attributes on .new"
        raise(Persistence::Errors::TransformerError, msg)
      end

      def many(results)
        results.map { |result| one(result) }
      end
    end
  end
end
