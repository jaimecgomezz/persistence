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
          # Select.all.order(:created_at, :updated_at, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc, nulls: :last },
          #         { criteria: :updated_at, order: :asc, nulls: :last }
          #       ]
          #     >
          #
          # # Handles a list of ordering criteria as keyword arguments
          # Select.all.order(:created_at, updated_at: :desc, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc, nulls: :last },
          #         { criteria: :updated_at, order: :desc, nulls: :last }
          #       ]
          #     >
          #
          # # Handles a list of ordering criteria with custom mappings as keyword arguments
          # Select.all.order(:created_at, updated_at: :desc, deleted_at: { order: :desc, nulls: :first }, nulls: :last)
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc, nulls: :last },
          #         { criteria: :updated_at, order: :desc, nulls: :last },
          #         { criteria: :deleted_at, order: :desc, nulls: :first }
          #       ]
          #     >
          def order(*items, **kwitems)
            nulls, remaining = kwarg_from_kwitems(kwitems, :nulls)

            items.map do |item|
              case item
              when Symbol, String
                criteria = item
                handle_criteria(nulls, criteria)
              else
                invalid_criteria!
              end
            end

            remaining.each do |criteria, value|
              case value
              when Symbol, String
                order = value
                handle_criteria(nulls, criteria, order)
              when Hash
                hash = value
                handle_criteria_hash(criteria, hash)
              else
                invalid_criteria!
              end
            end

            self
          end

          def orderings
            @orderings ||= []
          end

          private

          def orderings_indices
            @orderings_indices ||= {}
          end

          def kwarg_from_kwitems(kwitems, kwarg)
            value = kwitems[kwarg]
            remaining = kwitems.slice(*kwitems.keys - [kwarg])
            [value, remaining]
          end

          def handle_criteria(nulls, criteria, order = :asc)
            if (index = orderings_indices[criteria])
              orderings.delete_at(index)
              update_orderings_indices
            end

            orderings_indices[criteria] = orderings.size
            orderings.push({ criteria: criteria, order: order, nulls: nulls })
          end

          def handle_criteria_hash(criteria, hash)
            if (index = orderings_indices[criteria])
              orderings.delete_at(index)
              update_orderings_indices
            end

            orderings_indices[criteria] = orderings.size
            orderings.push(hash.merge({ criteria: criteria }))
          end

          def update_orderings_indices
            orderings.each_with_index do |ordering, index|
              orderings_indices[ordering[:criteria]] = index
            end
          end

          def invalid_criteria!
            msg = "Invalid ordering criteria provided to #order"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
