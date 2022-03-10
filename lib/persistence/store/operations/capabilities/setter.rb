# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of setting values.
        module Setter
          # Creates the @assignments instance variable that contains a list of
          # descriptive hashes that define each field to be set. This mapping
          # should be later understood by the Driver in order to build the
          # assignment component of the Directive.
          #
          # # Handle fields with default values
          # Update.from(:users).where({ id: 1 }).set({ income: :default })
          # => #<Update
          #       @assignments=[
          #         {
          #           field: :income,
          #           value: :default,
          #           kind: :expression
          #         }
          #       ]
          #     >
          #
          # # Handles fields with hashes as values
          # Update.from(:users).where({ id: 1 }).set({ info: { country: 'Mexico' } })
          # => #<Update
          #       @assignments=[
          #         {
          #           field: :info,
          #           value: { country: 'Mexico' },
          #           kind: :literal
          #         }
          #       ]
          #     >
          #
          # # Handles custom field mappings
          # Update.from(:users).where({ id: 1 }).set({ information: { value: { country: 'Mexico' }, kind: :literal} } })
          # => #<Update
          #       @assignments=[
          #         {
          #           field: :information,
          #           value: { country: 'Mexico' },
          #           kind: :literal
          #         }
          #       ]
          #     >
          def set(hash)
            clear_setter_configuration

            hash.each do |field, value|
              case value
              when Hash
                if valid_setter_custom_mapping?(value)
                  assignments.push(value.merge({ field: field }))
                else
                  handle_setter_field_hash(field, value)
                end
              else
                handle_setter_field(field, value)
              end
            end

            self
          end

          alias_method :values, :set

          def assignments
            @assignments ||= []
          end

          private

          def handle_setter_field(field, value)
            base = { field: field, value: value }

            kind = case value
                   when Symbol
                     :expression
                   else
                     :literal
                   end

            assignments.push(base.merge({ kind: kind }))
          end

          def handle_setter_field_hash(field, hash)
            assignments.push({ field: field, value: hash, kind: :literal })
          end

          def valid_setter_custom_mapping?(mapping)
            return false unless mapping.is_a?(Hash)

            required = [:value, :kind]
            (mapping.keys & required).size == required.size
          end

          def clear_setter_configuration
            @assignments = []
          end
        end
      end
    end
  end
end
