# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of setting values.
        module Setter
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
                assignments[field] = value
              else
                handle_setter_field_hash(field, value)
              end
            end

            self
          end

          def assignments
            @assignments ||= {}
          end

          private

          def handle_setter_field(field, value: nil)
            assignments[field] = if value
                                   { __value: value, __kind: :literal }
                                 else
                                   { __value: :default, __kind: :expression }
                                 end
          end

          def handle_setter_field_hash(field, hash)
            assignments[field] = { __value: hash, __kind: :literal }
          end

          def valid_setter_custom_mapping?(mapping)
            return false unless mapping.is_a?(Hash)

            required = [:__value, :__kind]
            (mapping.keys & required).size == required.size
          end

          def clear_setter_configuration
            @assignments = {}
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
