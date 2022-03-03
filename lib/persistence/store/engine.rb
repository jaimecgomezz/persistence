# frozen_string_literal: true

module Persistence
  module Store
    # Class that acts as the proxy between the consumer (e.g. Repository) and
    # the Operation to be performed.
    class Engine
      attr_reader :resource, :driver

      def initialize(resource, driver:)
        @resource = resource
        @driver = driver
      end

      def perform_custom(*args, **kwargs, &block)
        driver.run_custom(*args, **kwargs, &block)
      end
    end
  end
end
