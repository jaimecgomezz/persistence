# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of ordering results.
        module Orderer
          # Defines an instance variable called @orderings that maps each
          # ordering criteria to a descriptive hash that should be later
          # understood by the Driver in order to build an ordering directive.
          #
          # # Handles a list of ordering criteria as positional arguments
          # Select.all.order(:created_at, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings={
          #         created_at: { order: :asc, nulls: :last }
          #       }
          #     >
          #
          # # Handles a list of ordering criteria as keyword arguments
          # Select.all.order(created_at: :desc, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings={
          #         created_at: { order: :desc, nulls: nil }
          #       }
          #     >
          #
          # # Handles a list of ordering criteria with custom mappings as keyword arguments
          # Select.all.order(created_at: { order: :desc, nulls: :first }, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings={
          #         created_at: { order: :desc, nulls: :first }
          #       }
          #     >
          def order(*items, **kwitems)
            nulls, remaining = kwarg_from_kwitems(kwitems, :nulls)

            items.map do |item|
              case item
              when Symbol, String
                field = item
                handle_field(nulls, field)
              else
                invalid_orderings!
              end
            end

            remaining.each do |field, value|
              case value
              when Symbol, String
                handle_field(nulls, field, value)
              when Hash
                orderings[field] = value
              else
                invalid_orderings!
              end
            end

            self
          end

          def orderings
            @orderings ||= {}
          end

          private

          def kwarg_from_kwitems(kwitems, kwarg)
            value = kwitems[kwarg]
            remaining = kwitems.slice(*kwitems.keys - [kwarg])
            [value, remaining]
          end

          def handle_field(nulls, field, order = :asc)
            orderings[field] = { order: order, nulls: nulls }
          end

          def invalid_orderings!
            msg = "Invalid orderings provided to #order"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
