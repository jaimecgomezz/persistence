# frozen_string_literal: true

module Persistence
  module Store
    module Operations
      module Capabilities
        # Makes the Operation capable of aggregating result fields.
        module Aggregator
          # Defines a @aggregations instance variable that maps each field
          # expected to be aggregated with a descriptive hash that should be
          # later understood by the Driver in order to build query's
          # aggregation component.
          #
          # # Handles a list of fields with their aggregations as keyword arguments
          # Select.all.aggregate(age: :avg, income: :sum)
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         age: {
          #           alias: nil,
          #           aggregation: :avg
          #         },
          #         income: {
          #           alias: nil,
          #           aggregation: :sum
          #         }
          #       }
          #     >
          #
          # # Handles a list of fields with custom aggregation mappings as keyword arguments
          # Select.all.aggregate(
          #   age: {
          #     alias: :AGE,
          #     aggregation: :avg
          #   },
          #   income: {
          #     alias: :INCOME,
          #     aggregation: :sum
          #   }
          # )
          # => #<Select:0x000055837e273178
          #       @aggregations={
          #         age: {
          #           alias: :AGE,
          #           aggregation: :avg
          #         },
          #         income: {
          #           alias: :INCOME,
          #           aggregation: :sum
          #         }
          #       }
          #     >
          def aggregate(**kwitems)
            clean_aggregator_configuration

            kwitems.each do |field, aggregation|
              case aggregation
              when Symbol, String
                handle_aggregation(field, aggregation)
              when Hash
                handle_aggregation_mapping(field, aggregation)
              else
                invalid_aggregation!(aggregation)
              end
            end

            self
          end

          def aggregations
            @aggregations ||= {}
          end

          private

          def handle_aggregation(field, aggregation)
            aggregations[field] = { alias: nil, aggregation: aggregation }
          end

          def handle_aggregation_mapping(field, mapping)
            invalid_aggregation!(mapping) unless valid_aggregation_mapping?(mapping)
            aggregations[field] = mapping
          end

          def valid_aggregation_mapping?(mapping)
            required = [:alias, :aggregation]
            (mapping.keys & required).size == required.size
          end

          def clean_aggregator_configuration
            @aggregations = {}
          end

          def invalid_aggregation!(sample)
            msg = "Invalid fields provided to #aggregate: #{sample}"
            raise(Persistence::Errors::OperationError, msg)
          end
        end
      end
    end
  end
end
