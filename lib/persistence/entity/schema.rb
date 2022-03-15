# frozen_string_literal: true

module Persistence
  class Entity
    # Entity schema is a definition of a set of typed attributes.
    #
    # @example Entity with custom Schema
    #   class Account < Persistence::Entity
    #     attributes do
    #       attribute :id,         Types::Int
    #       attribute :name,       Types::String
    #       attribute :codes,      Types::Array(Types::Int)
    #       attribute :users,      Types::Array(User)
    #       attribute :email,      Types::String.constrained(format: /@/)
    #       attribute :created_at, Types::DateTime
    #     end
    #   end
    #
    #   account = Account.new(name: "Acme Inc.")
    #   account.name # => "Acme Inc."
    #
    #   account = Account.new(foo: "bar")
    #   account.foo # => NoMethodError
    #
    # @example Schemaless Entity
    #   class Account < Persistence::Entity
    #   end
    #
    #   account = Account.new(name: "Acme Inc.")
    #   account.name # => "Acme Inc."
    #
    #   account = Account.new(foo: "bar")
    #   account.foo # => "bar"
    class Schema
      # Schemaless entities logic
      class Schemaless
        def initialize
          freeze
        end

        # @param attributes [#to_hash] the attributes hash
        #
        # @return [Hash]
        def call(attributes)
          if attributes.nil?
            {}
          else
            Hanami::Utils::Hash.deep_symbolize(attributes.to_hash.dup)
          end
        end

        def attribute?(_name)
          true
        end
      end

      # Schema definition
      class Definition
        # Schema DSL
        class Dsl
          TYPES = %i(schema strict weak permissive strict_with_defaults symbolized).freeze

          DEFAULT_TYPE = TYPES.first

          def self.build(type, &blk)
            type ||= DEFAULT_TYPE
            msg = "Unknown schema type: `#{type.inspect}'"
            raise(StandardError, msg) unless TYPES.include?(type)

            attributes = new(&blk).to_h
            [attributes, Persistence::Model::Types::Coercible::Hash.__send__(type, attributes)]
          end

          def initialize(&blk)
            @attributes = {}
            instance_eval(&blk)
          end

          # Define an attribute
          #
          # @param name [Symbol] the attribute name
          # @param type [Dry::Types::Definition] the attribute type
          #
          # @example
          #   class Account < Persistence::Entity
          #     attributes do
          #       attribute :id,         Types::Int
          #       attribute :name,       Types::String
          #       attribute :codes,      Types::Array(Types::Int)
          #       attribute :users,      Types::Array(User)
          #       attribute :email,      Types::String.constrained(format: /@/)
          #       attribute :created_at, Types::DateTime
          #     end
          #   end
          #
          #   account = Account.new(name: "Acme Inc.")
          #   account.name # => "Acme Inc."
          #
          #   account = Account.new(foo: "bar")
          #   account.foo # => NoMethodError
          def attribute(name, type)
            @attributes[name] = type
          end

          def to_h
            @attributes
          end
        end

        # Instantiate a new DSL instance for an entity
        #
        # @param blk [Proc] the block that defines the attributes
        #
        # @return [Persistence::Entity::Schema::Dsl] the DSL
        def initialize(type = nil, &blk)
          raise LocalJumpError unless block_given?

          @attributes, @schema = Dsl.build(type, &blk)
          @attributes = Hash[@attributes.map { |k, _| [k, true] }]
          freeze
        end

        # Process attributes
        #
        # @param attributes [#to_hash] the attributes hash
        #
        # @raise [TypeError] if the process fails
        # @raise [ArgumentError] if data is missing, or unknown keys are given
        def call(attributes)
          schema.call(attributes)
        rescue Dry::Types::SchemaError => exception
          raise TypeError, exception.message
        rescue Dry::Types::MissingKeyError, Dry::Types::UnknownKeysError => exception
          require 'pry'
          binding.pry
          raise ArgumentError, exception.message
        end

        # Check if the attribute is known
        #
        # @param name [Symbol] the attribute name
        #
        # @return [TrueClass,FalseClass] the result of the check
        def attribute?(name)
          attributes.key?(name)
        end

        private

        attr_reader :schema
        attr_reader :attributes
      end

      # Build a new instance of Schema with the attributes defined by the given block
      #
      # @param blk [Proc] the optional block that defines the attributes
      #
      # @return [Persistence::Entity::Schema] the schema
      def initialize(type = nil, &blk)
        @schema = if block_given?
                    Definition.new(type, &blk)
                  else
                    Schemaless.new
                  end
      end

      # Process attributes
      #
      # @param attributes [#to_hash] the attributes hash
      #
      # @raise [TypeError] if the process fails
      def call(attributes)
        Hanami::Utils::Hash.deep_symbolize(schema.call(attributes))
      end

      alias_method :[], :call

      # Check if the attribute is known
      #
      # @param name [Symbol] the attribute name
      #
      # @return [TrueClass,FalseClass] the result of the check
      def attribute?(name)
        schema.attribute?(name)
      end

      protected

      attr_reader :schema
    end
  end
end
