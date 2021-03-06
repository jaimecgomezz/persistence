# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of being filtered by specific criteria.
        module Filter
          # Creates the @global_filters and the @user_filters instance
          # variables. The former contains filters managed by the Persistence
          # library, like the ones used to prevent discarded records from
          # appearing in the final results, while the latter contains a list of
          # descriptive hashes that allows the Driver to build the filtering
          # component of the Directive.
          #
          # Select.where({ id: 1 })
          # => #<Select
          #       @user_filters=[
          #         {
          #           negate: false,
          #           operand: :and,
          #           filters: { id: 1 }
          #         }
          #       ]
          #     >
          #
          # Select.where({ id: 1 }).where.and({ email: 'a@email.com' })
          # => #<Select
          #       @user_filters=[
          #         {
          #           negate: false,
          #           operand: :and,
          #           filters: { id: 1 }
          #         },
          #         {
          #           negate: false,
          #           operand: :and,
          #           filters: { email: 'a@email.com' }
          #         }
          #       ]
          #     >
          #
          # Select.where_not({ id: 1 }).where_not.or({ email: 'a@email.com' })
          # => #<Select
          #       @user_filters=[
          #         {
          #           negate: true,
          #           operand: :and,
          #           filters: { id: 1 }
          #         },
          #         {
          #           negate: true,
          #           operand: :or,
          #           filters: { email: 'a@email.com' }
          #         }
          #       ]
          #     >
          def where(hash = nil)
            @filter_state = { filtering: true, negate: false }
            handle_primary_filters(hash)
            self
          end

          # Does the same thing as where, but it negates the set of filters
          # provided.
          #
          # Select.where_not({ id: 1 })
          # => #<Select
          #       @user_filters=[
          #         {
          #           negate: true,
          #           operand: :and,
          #           filters: { id: 1 }
          #         }
          #       ]
          #     >
          def where_not(hash = nil)
            @filter_state = { filtering: true, negate: true }
            handle_primary_filters(hash)
            self
          end

          def user_filters
            @user_filters ||= []
          end

          def global_filters
            @global_filters ||= {}
          end

          private

          def handle_primary_filters(hash)
            return unless hash

            clear_filter_configuration

            invalid_filter_usage! unless user_filters.empty?

            add_filters(hash, :and)
          end

          def handle_secondary_filters(hash, operand)
            invalid_filter_usage! if user_filters.empty?

            add_filters(hash, operand)
          end

          def add_filters(hash, operand)
            user_filters.push({
              filters: hash,
              operand: operand,
              negate: filter_state[:negate]
            })

            @filter_state = { filtering: false, negate: false }
          end

          def filter_state
            @filter_state ||= { filtering: false, negate: false }
          end

          def respond_to_missing?(method, priv)
            valid_method_missing?(method) || super
          end

          def method_missing(method, *args, **kwargs, &block)
            if valid_method_missing?(method)
              hash = args.first
              raise(ArgumentError, "wrong number of arguments (given 0, expected 1)") unless hash
              handle_secondary_filters(hash, method)
              self
            else
              super
            end
          end

          def valid_method_missing?(method)
            filter_state[:filtering] && [:and, :or].include?(method)
          end

          def clear_filter_configuration
            @user_filters = []
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
