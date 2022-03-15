# frozen_string_literal: true

require "rom/types"

module Persistence
  module Model
    module Types
      include ROM::Types

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # Class level interface
      module ClassMethods
        # Define an entity of the given type
        #
        # @param type [Persistence::Entity] an entity
        #
        # @example
        #   class Account < Persistence::Entity
        #     attributes do
        #       attribute :owner, Types::Entity(User)
        #     end
        #   end
        #
        #   account = Account.new(owner: User.new(name: "Luca"))
        #   account.owner.class # => User
        #   account.owner.name  # => "Luca"
        #
        #   account = Account.new(owner: { name: "MG" })
        #   account.owner.class # => User
        #   account.owner.name  # => "MG"
        def Entity(type)
          type = Schema::CoercibleType.new(type) unless type.is_a?(Dry::Types::Definition)
          type
        end

        # Define an array of given type
        #
        # @param type [Object] an object
        #
        # @example
        #   class Account < Persistence::Entity
        #     attributes do
        #       # ...
        #       attribute :users, Types::Collection(User)
        #     end
        #   end
        #
        #   account = Account.new(users: [User.new(name: "Luca")])
        #   user    = account.users.first
        #   user.class # => User
        #   user.name  # => "Luca"
        #
        #   account = Account.new(users: [{ name: "MG" }])
        #   user    = account.users.first
        #   user.class # => User
        #   user.name  # => "MG"
        def Collection(type)
          type = Schema::CoercibleType.new(type) unless type.is_a?(Dry::Types::Definition)
          Types::Array.member(type)
        end
      end

      # Types for schema definitions
      module Schema
        # Coercer for objects within custom schema definition
        class CoercibleType < Dry::Types::Definition
          # Coerce given value into the wrapped object type
          #
          # @param value [Object] the value
          #
          # @return [Object] the coerced value of `object` type
          #
          # @raise [TypeError] if value can't be coerced
          def call(value)
            return if value.nil?

            if valid?(value)
              coerce(value)
            else
              msg = "#{value.inspect} must be coercible into #{object}"
              raise(TypeError, msg)
            end
          end

          # Check if value can be coerced
          #
          # It is true if value is an instance of `object` type or if value
          # responds to `#to_hash`.
          #
          # @param value [Object] the value
          #
          # @return [TrueClass,FalseClass] the result of the check
          def valid?(value)
            value.is_a?(object) ||
              value.respond_to?(:to_hash)
          end

          # Coerce given value into an instance of `object` type
          #
          # @param value [Object] the value
          #
          # @return [Object] the coerced value of `object` type
          def coerce(value)
            case value
            when object
              value
            else
              object.new(value.to_hash)
            end
          end

          def object
            result = primitive
            return result unless result.respond_to?(:primitive)

            result.primitive
          end
        end
      end
    end
  end
end
