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
          # # Handles single field
          # Select.where({ id: 1 }).retrieve(:id)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: nil, resource: nil }
          #       }
          #     >
          #
          # # Handles a list of fields
          # Select.where({ id: 1 }).retrieve(:id, :name, resource: :users)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: nil, resource: :users },
          #         name: { alias: nil, resource: :users }
          #       }
          #     >
          #
          # # Handles fields with alias
          # Select.where({ id: 1 }).retrieve(:id, [:name, :NAME], resource: :users)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: nil, resource: :users },
          #         name: { alias: :NAME, resource: :users }
          #       }
          #     >
          def retrieve(*items, **kwitems)
            resource, remaining = resource_from_kwitems(kwitems)

            items.map do |item|
              case item
              when Symbol, String
                field = item
                handle_field(resource, field)
              when Array
                field, aka = item
                handle_field(resource, field, aka)
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

          def resource_from_kwitems(kwitems)
            resource = kwitems[:resource]
            remaining = kwitems.slice(*kwitems.keys - [:resource])
            [resource, remaining]
          end

          def handle_field(resource, field, aka = nil)
            retrievables[field] = { resource: resource, alias: aka }
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
