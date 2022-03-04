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
          # Select.from(:users).retrieve(:id, :name)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: nil, resource: :users },
          #         name: { alias: nil, resource: :users }
          #       }
          #     >
          #
          # # Handles fields with aliases as keyword arguments
          # Select.from(:users).retrieve(id: :ID, name: :NAME)
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: :ID, resource: :users },
          #         name: { alias: :NAME, resource: :users }
          #       }
          #     >
          #
          # # Handles fields with custom mappings as keyword arguments
          # Select.from(:users).retrieve(
          #   id: {
          #     alias: :ID,
          #     resource: :accounts
          #   },
          #   name: {
          #     alias: :NAME,
          #     resource: :organizations
          #   }
          # )
          # => #<Select:0x000055837e273178
          #       @retrievables={
          #         id: { alias: :ID, resource: :accounts },
          #         name: { alias: :NAME, resource: :organization }
          #       }
          #     >
          def retrieve(*items, **kwitems)
            clear_retriever_configuration

            items.map do |field|
              case field
              when Symbol, String
                handle_retrievable_field(field)
              else
                invalid_retrievable_field!(field)
              end
            end

            kwitems.each do |field, value|
              case value
              when Symbol, String
                handle_retrievable_field(field, value)
              when Hash
                handle_retrievable_mapping(field, value)
              else
                invalid_retrievable_field!(field)
              end
            end

            self
          end

          def retrievables
            @retrievables ||= {}
          end

          private

          def handle_retrievable_field(field, aka = nil)
            retrievables[field] = { resource: @source, alias: aka }
          end

          def handle_retrievable_mapping(field, mapping)
            invalid_retrievable_field!(field) unless valid_retrievable_mapping?(mapping)

            retrievables[field] = mapping
          end

          def valid_retrievable_mapping?(mapping)
            required = [:resource, :alias]
            (mapping.keys & required).size == required.size
          end

          def clear_retriever_configuration
            @retrievables = {}
          end

          def invalid_retrievable_field!(sample)
            msg = "Invalid fields provided to #retrieve: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
