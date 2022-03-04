# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of retrieving specific fields from results.
        module Retriever
          # Defines a @retrievables instance variable that maps each fields
          # expected to be retrieved by the operation with a descriptive hash
          # that should be later understood by the Driver in order to build
          # query's return.
          #
          # Examples
          #
          # # Handles fields as positional arguments
          # Select.where({ id: 1 }).retrieve(:id, :name, resource: :users)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: nil, resource: :users },
          #         name: { alias: nil, resource: :users }
          #       }
          #     >
          #
          # # Handles fields with aliases as keyword arguments
          # Select.where({ id: 1 }).retrieve(id: :ID, name: :NAME, resource: :users)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: :ID, resource: :users },
          #         name: { alias: :NAME, resource: :users }
          #       }
          #     >
          #
          # # Handles fields with custom mappings as kwarguments
          # Select.where({ id: 1 }).retrieve(
          #   id: {
          #     alias: :ID,
          #     resource: :users
          #   },
          #   name: {
          #     alias: :NAME,
          #     resource: :users
          #   },
          #   resource: :other
          # )
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: :ID, resource: :users },
          #         name: { alias: :NAME, resource: :users }
          #       }
          #     >
          def retrieve(*items, **kwitems)
            clear_previous_configuration

            resource, remaining = kwarg_from_kwitems(kwitems, :resource)

            items.map do |item|
              case item
              when Symbol, String
                field = item
                handle_field(resource, field)
              else
                invalid_fields!
              end
            end

            remaining.each do |field, value|
              case value
              when Symbol, String
                handle_field(resource, field, value)
              when Hash
                retrievables[field] = value
              else
                invalid_fields!
              end
            end

            self
          end

          def retrievables
            @retrievables ||= {}
          end

          private

          def kwarg_from_kwitems(kwitems, kwarg)
            value = kwitems[kwarg]
            remaining = kwitems.slice(*kwitems.keys - [kwarg])
            [value, remaining]
          end

          def handle_field(resource, field, aka = nil)
            retrievables[field] = { resource: resource, alias: aka }
          end

          def clear_previous_configuration
            @retrievables = {}
          end

          def invalid_fields!
            msg = "Invalid fields provided to #retrieve"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
