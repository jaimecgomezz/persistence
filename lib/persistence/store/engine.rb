# frozen_string_literal: true

module Persistence
  module Store
    # Class that acts as the proxy between the consumer (e.g. Repository) and
    # the Operation to be performed.
    class Engine
      OPERATIONS = {
        count: Operations::Count,
        delete: Operations::Delete,
        insert: Operations::Insert,
        update: Operations::Update,
        discard: Operations::Discard,
        selection: Operations::Select
      }

      attr_reader :source, :driver, :operation

      def initialize(source, driver)
        @source = source
        @driver = driver
      end

      def perform
        validate_operation_selected!
        driver.run(operation)
      rescue NoMethodError
        raise_engine_error! "Invalid driver, it should implement #run(operation)"
      end

      def perform_custom(*args, **kwargs, &block)
        driver.run_custom(*args, **kwargs, &block)
      rescue NoMethodError
        raise_engine_error! "Invalid driver, it should implement #run_custom"
      end

      private

      def respond_to_missing?(name, pub)
        operation.respond_to?(name) || OPERATIONS[name.to_sym] || super
      end

      def method_missing(method, *args, **kwargs, &block)
        operation.send(method, *args, **kwargs, &block)
        self
      rescue NoMethodError => e
        case e.receiver
        when NilClass
          operation_not_supported!(method) unless (o = OPERATIONS[method.to_sym])
          @operation = o.new(source)
          self
        when operation.class
          method_missing_in_operation!(method)
        else
          super
        end
      end

      def validate_operation_selected!
        raise_engine_error! "Can't #perform when no operation has been selected" unless operation
      end

      def operation_not_supported!(name)
        raise_engine_error! "The operation #{name} isn't supported"
      end

      def method_missing_in_operation!(name)
        raise_engine_error! "The #{operation.name} operation doesn't implements ##{name}"
      end

      def raise_engine_error!(msg)
        raise(Persistence::Errors::EngineError, msg)
      end
    end
  end
end
