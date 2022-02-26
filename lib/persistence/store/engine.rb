# frozen_string_literal: true

module Persistence
  module Store
    # Class that acts as the proxy between the consumer (e.g. Repository) and
    # the Operation to be performed.
    class Engine
      attr_reader :operation, :table, :adapter, :adapter_method, :driver

      ADAPTERS = {
        postgres: Operations::Adapters::PostgresAdapter.adapter_method
      }.freeze

      def initialize(driver, table, adapter)
        if ADAPTERS.include?(adapter)
          @driver = driver
          @table = table
          @adapter = adapter
          @adapter_method = ADAPTERS[adapter]
        else
          msg = "The :#{adapter} adapter is not supported. Available: #{ADAPTERS.keys}"
          raise(Persistence::Errors::EngineError, msg)
        end
      end

      def select
        validate_no_existing_operation!
        @operation = Operations::Select.new(table)
        self
      end

      def create
        validate_no_existing_operation!
        @operation = Operations::Create.new(table)
        self
      end

      def update
        validate_no_existing_operation!
        @operation = Operations::Update.new(table)
        self
      end

      def delete
        validate_no_existing_operation!
        @operation = Operations::Delete.new(table)
        self
      end

      def count
        validate_no_existing_operation!
        @operation = Operations::Count.new(table)
        self
      end

      # Terminal method.
      # When invoked, it materializes the Operation and delegates the execution
      # to the driver.
      def perform
        validate_existing_operation!
        directive = operation.send(adapter_method)
        result = driver.run(directive)
        operation.finally(result)
      rescue NoMethodError => e
        msg = if e.name == 'run'
                "The #{driver.class} driver doesn't implements :run required by #{self.class}"
              else
                "The #{operation.class} operation doesn't implements the #{adapter.capitalize} adapter"
              end
        raise(Persistence::Errors::OperationError, msg)
      rescue Exeption => e
        raise(Persistence::Errors::DriverError, e.message)
      end

      private

      def validate_no_existing_operation!
        msg = "Can't overwrite current operation: #{operation}"
        raise(Persistence::Errors::EngineError, msg) if operation
      end

      def validate_existing_operation!
        msg = "Can't invoke :perform with no Operation defined"
        raise(Persistence::Errors::EngineError, msg) unless operation
      end

      def respond_to_missing?(method)
        operation.respond_to?(method)
      end

      def method_missing(method, *args, **kwargs, &block)
        operation.send(method, *args, **kwargs, &block)
        self
      rescue NoMehodError
        klass = operation.class

        msg = if klass == NilClass
                'No Operation has been invoked'
              else
                "#{klass} operation doesn't implements :#{method}"
              end

        raise(Persistence::Errors::OperationError, msg)
      end
    end
  end
end
