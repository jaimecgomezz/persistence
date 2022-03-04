# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        #
        # TODO:
        #   - Use the kwargs syntax
        #   - Support overwritability
        #   - Add support for Operations as values
        module Filter
          NESTED_METHODS = %i(or and).freeze

          def where(hash = nil)
            @filtering_config = { filtering: true, negate: false }
            handle_primary_filters(hash)
            self
          end

          def where_not(hash = nil)
            @filtering_config = { filtering: true, negate: true }
            handle_primary_filters(hash)
            self
          end

          def filters
            @filters ||= []
          end

          private

          def handle_primary_filters(hash)
            return if hash.nil?

            invalid_usage! unless filters.empty?

            add_filters(hash, :and)
          end

          def handle_secondary_filters(hash, operand)
            invalid_usage! if filters.empty?

            add_filters(hash, operand)
          end

          def add_filters(hash, operand)
            filters.push({
              __operand: operand,
              __negate: filtering_config[:negate],
              __filters: filters_builder.build(hash)
            })
            reset_filtering_config
          end

          def filters_builder
            @filters_builder ||= Helpers::FiltersBuilder.new
          end

          def reset_filtering_config
            @filtering_config = { filtering: false, negate: false }
          end

          def filtering_config
            @filtering_config ||= { filtering: false, negate: false }
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
            filtering_config[:filtering] && NESTED_METHODS.include?(method)
          end

          def invalid_usage!
            reset_filtering_config
            msg = if filters.empty?
                    "Can't set extra filters until #where or #where_not had been called at least once"
                  else
                    "For setting extra filters use nested methods #where.and or #where.or"
                  end
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
