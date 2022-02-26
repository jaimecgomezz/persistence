# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      # Responsible of building a READ Directive.
      class SelectOperation < BaseOperation
        attr_reader :single

        def finally(result)
          return result.first if single

          result
        end
      end
    end
  end
end
