# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of ordering results.
        module Orderer
          # Defines a @orderings instance variable which is an ordered list of
          # descriptive hashes that each define how ordering should occur. This
          # list should be later understood by the Driver in order to build the
          # ordering component of the Directive.
          #
          # # Handles a list of ordering criteria as positional arguments
          # Select.all.order(:created_at, :updated_at)
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc },
          #         { criteria: :updated_at, order: :asc }
          #       ]
          #     >
          #
          # # Handles a list of ordering criteria as keyword arguments
          # Select.all.order(:created_at, updated_at: :desc)
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc },
          #         { criteria: :updated_at, order: :desc }
          #       ]
          #     >
          #
          # # Handles a list of ordering criteria with custom mappings as keyword arguments
          # Select.all.order(:created_at, updated_at: :desc, deleted_at: { order: :desc, nulls: last })
          # => #<Select:0x000055837e273178
          #       @orderings=[
          #         { criteria: :created_at, order: :asc },
          #         { criteria: :updated_at, order: :desc },
          #         { criteria: :deleted_at, order: :desc, nulls: :last }
          #       ]
          #     >
          def order(*items, **kwitems)
            clear_orderer_configuration

            items.map do |criteria|
              case criteria
              when Symbol, String
                handle_order_criteria(criteria)
              else
                invalid_order_criteria!(criteria)
              end
            end

            kwitems.each do |criteria, value|
              case value
              when Symbol, String
                handle_order_criteria(criteria, value)
              when Hash
                handle_order_mapping(criteria, value)
              else
                invalid_order_criteria!(criteria)
              end
            end

            self
          end

          def orderings
            @orderings ||= []
          end

          private

          def handle_order_criteria(criteria, order = :asc)
            orderings.push({ criteria: criteria, order: order })
          end

          def handle_order_mapping(criteria, mapping)
            invalid_order_criteria!(criteria) unless valid_order_mapping?(mapping)

            orderings.push(mapping.merge({ criteria: criteria }))
          end

          def valid_order_mapping?(mapping)
            required = [:order]
            (mapping.keys & required).size == required.size
          end

          def clear_orderer_configuration
            @orderings = []
            @orderings_indices = {}
          end

          def invalid_order_criteria!(sample)
            msg = "Invalid ordering criteria provided to #order: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
