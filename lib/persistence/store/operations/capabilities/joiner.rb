# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of joining external resource in the result.
        module Joiner
          # Creates the @joins instance variable that maps resources to
          # descriptive mappings that describe how the @source should be joining
          # with them. This mappings should later be understood by the Driver to
          # build the joining component of the Directive.
          #
          # # Handles a list of resource mappings as keyword arguments
          # Select.from(:a).join(b: { kind: :lo, left: :id, right: :a_id })
          # => #<Select
          #       @joins={
          #         b: {
          #           kind: :lo,
          #           left: :id,
          #           right: :a_id
          #         }
          #       }
          #     >
          def join(**kwitems)
            clear_joiner_configuration

            kwitems.each do |resource, mapping|
              case mapping
              when Hash
                handle_join_mapping(resource, mapping)
              else
                invalid_join_mapping!(resource)
              end
            end

            self
          end

          def joins
            @joins ||= {}
          end

          private

          def handle_join_mapping(resource, mapping)
            invalid_join_mapping!(resource) unless valid_join_mapping?(mapping)
            joins[resource] = mapping
          end

          def valid_join_mapping?(mapping)
            required = [:kind, :left, :right]
            (mapping.keys & required).size == required.size
          end

          def clear_joiner_configuration
            @joins = {}
          end

          def invalid_join_mapping!(sample)
            msg = "Invalid mappings provided to #join: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
