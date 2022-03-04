# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        module Filter
          # Creates the @filters instance variable that contains a list of
          # hashes that each describe a set of filters to be applied by the
          # directive. This filters should be later understood by the Driver in
          # order to build the filtering component of the Directive.
          #
          # If no filters are provided, it proceeds rather allows the caller to
          # access nested methods in order to further define filters.
          #
          # Select.where({ id: 1 })
          # => #<Select
          #       @filters=[
          #         {
          #           __negate: false,
          #           __operand: :and,
          #           __value: {
          #             __negate: false,
          #             __operand: :equal,
          #             __value: 1
          #           }
          #         }
          #       ]
          #     >
          def where(**hash)
            @filter_state = { filtering: true, negate: false }
            handle_primary_filters(hash)
            self
          end

          # Does the same thing as where, but it negates the set of filters
          # provided.
          #
          # Select.where_not({ id: 1 })
          # => #<Select
          #       @filters=[
          #         {
          #           __negate: true,
          #           __operand: :and,
          #           __value: {
          #             __negate: false,
          #             __operand: :equal,
          #             __value: 1
          #           }
          #         }
          #       ]
          #     >
          def where_not(**hash)
            @filter_state = { filtering: true, negate: true }
            handle_primary_filters(hash)
            self
          end

          def filters
            @filters ||= []
          end

          private

          def handle_primary_filters(hash)
            return if hash.empty?

            clear_filter_configuration

            invalid_filter_usage! unless filters.empty?

            add_filters(hash, :and)
          end

          def handle_secondary_filters(hash, operand)
            invalid_filter_usage! if filters.empty?

            add_filters(hash, operand)
          end

          def add_filters(hash, operand)
            filters.push({
              __operand: operand,
              __negate: filter_state[:negate],
              __filters: filters_builder.build(hash)
            })

            @filter_state = { filtering: false, negate: false }
          end

          def filters_builder
            @filters_builder ||= Helpers::FiltersBuilder.new
          end

          def filter_state
            @filter_state ||= { filtering: false, negate: false }
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

          def valid_method_missing?(method)
            filter_state[:filtering] && [:and, :or].include?(method)
          end

          def clear_filter_configuration
            @filters = []
          end

          def invalid_filter_usage!
            msg = "For setting extra filters use nested methods #where.and or #where.or"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
