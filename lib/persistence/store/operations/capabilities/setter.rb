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
          # # Handle fields with default as positional arguments
          # Update.from(:users).where({ id: 1 }).set(:income)
          # => #<Update
          #       @assignments=[
          #         {
          #           __field: :income,
          #           __value: :default,
          #           __kind: :expression
          #         }
          #       ]
          #     >
          #
          # # Handles fields with hashes as values, as keyword arguments
          # Update.from(:users).where({ id: 1 }).set(info: { country: 'Mexico' })
          # => #<Update
          #       @assignments=[
          #         {
          #           __field: :info,
          #           __value: { country: 'Mexico' },
          #           __kind: :literal
          #         }
          #       ]
          #     >
          #
          # # Handles custom field mappings as positional arguments
          # Update.from(:users).where({ id: 1 }).set(information: { __value: { country: 'Mexico' }, __kind: :literal} })
          # => #<Update
          #       @assignments=[
          #         {
          #           __field: :information,
          #           __value: { country: 'Mexico' },
          #           __kind: :literal
          #         }
          #       ]
          #     >
          def set(*items, **kwitems)
            clear_setter_configuration

            items.each do |field|
              case field
              when Symbol, String
                handle_setter_field(field)
              else
                invalid_setter_field!(field)
              end
            end

            kwitems.each do |field, value|
              if valid_setter_custom_mapping?(value)
                assignments.push(value.merge({ __field: field }))
              else
                handle_setter_field_hash(field, value)
              end
            end

            self
          end

          alias_method :values, :set

          def assignments
            @assignments ||= []
          end

          private

          def handle_setter_field(field, value: nil)
            hash = if value
                     { __field: field, __value: value, __kind: :literal }
                   else
                     { __field: field, __value: :default, __kind: :expression }
                   end

            assignments.push(hash)
          end

          def handle_setter_field_hash(field, hash)
            assignments.push({ __field: field, __value: hash, __kind: :literal })
          end

          def valid_setter_custom_mapping?(mapping)
            return false unless mapping.is_a?(Hash)

            required = [:__value, :__kind]
            (mapping.keys & required).size == required.size
          end

          def clear_setter_configuration
            @assignments = []
          end

          def invalid_setter_field!(sample = nil)
            msg = "Invalid field provided to #set"
            msg += ": #{sample}" if sample
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
