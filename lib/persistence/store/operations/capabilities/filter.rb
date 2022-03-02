# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        module Filter
          NESTED_METHODS = %i(or and).freeze

          def initialize(*args, **kwargs, &block)
            @__filtering_config = {
              state: nil,
              negate: false,
              primary_filters: nil,
              secondary_filters: []
            }
            super
          end

          def where(filters = nil)
            @__filtering_config[:state] = :filtering
            handle_primary_filters(filters)
            self
          end

          def where_not(filters = nil)
            @__filtering_config[:state] = :filtering
            @__filtering_config[:negate] = true
            handle_primary_filters(filters)
            self
          end

          private

          def filters
            ([primary_filters] + secondary_filters).compact
          end

          def respond_to_missing?(method, priv)
            valid_method_missing?(method) || super
          end

          def method_missing(method, *args, **kwargs, &block)
            if valid_method_missing?(method)
              handle_secondary_filters(kwargs, method)
              self
            else
              super
            end
          end

          def handle_primary_filters(filters)
            return if filters.nil?

            if primary_filters.nil?
              @__filtering_config[:primary_filters] = {
                __negate: negate_filtering,
                __operand: :eq,
                __filters: filters_builder.build(filters)
              }

              set_default_filtering_config
            else
              set_default_filtering_config
              msg = "Primary filters have already been set, use nested setters: #and, #or"
              raise(Persistence::Errors::OperationError, msg)
            end
          end

          def handle_secondary_filters(filters, operand)
            if !primary_filters.nil?
              @__filtering_config[:secondary_filters].push({
                __negate: negate_filtering,
                __operand: operand,
                __filters: filters_builder.build(filters)
              })
              set_default_filtering_config
            else
              set_default_filtering_config
              msg = "Primary filters should be set in order to use nested methods"
              raise(Persistence::Errors::OperationError, msg)
            end
          end

          def set_default_filtering_config
            @__filtering_config = @__filtering_config.merge({
              state: nil,
              negate: false
            })
          end

          def valid_method_missing?(method)
            filtering_state == :filtering && NESTED_METHODS.include?(method)
          end

          def filters_builder
            @filters_builder ||= Helpers::FiltersBuilder.new
          end

          def primary_filters
            @__filtering_config[:primary_filters]
          end

          def secondary_filters
            @__filtering_config[:secondary_filters]
          end

          def filtering_state
            @__filtering_config[:state]
          end

          def negate_filtering
            @__filtering_config[:negate]
          end
        end
      end
    end
  end
end
