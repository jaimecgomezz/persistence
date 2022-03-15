# frozen_string_literal: true

require_relative 'model/types'

module Persistence
  # An object that is defined by its identity.
  # See "Domain Driven Design" by Eric Evans.
  #
  # An entity is the core of an application, where the part of the domain
  # logic is implemented. It's a small, cohesive object that expresses coherent
  # and meaningful behaviors.
  #
  # It deals with one and only one responsibility that is pertinent to the
  # domain of the application, without caring about details such as persistence
  # or validations.
  #
  # This simplicity of design allows developers to focus on behaviors, or
  # message passing if you will, which is the quintessence of Object Oriented
  # Programming.
  class Entity
    require_relative 'entity/schema'

    # Syntactic shortcut to reference types in custom schema DSL
    module Types
      include Persistence::Model::Types
    end

    module ClassMethods
      # Define manual entity schema
      def attributes(type = nil, &blk)
        self.schema = Schema.new(type, &blk)
        @attributes = true
      end

      # Assign a schema
      def schema=(value)
        return if defined?(@attributes)

        @schema = value
      end

      attr_reader :schema
    end

    # @since 0.7.0
    # @api private
    def self.inherited(klass)
      klass.class_eval do
        @schema = Schema.new
        extend  ClassMethods
      end
    end

    # Instantiate a new entity
    #
    # @param attributes [Hash,#to_h,NilClass] data to initialize the entity
    #
    # @return [Persistence::Entity] the new entity instance
    def initialize(attributes = nil)
      @attributes = self.class.schema[attributes]
      freeze
    end

    def id
      attributes.fetch(:id, nil)
    end

    # Handle dynamic accessors
    #
    # If internal attributes set has the requested key, it returns the linked
    # value, otherwise it raises a NoMethodError
    def method_missing(method_name, *)
      attribute?(method_name) or super
      attributes.fetch(method_name, nil)
    end

    # Implement generic equality for entities
    #
    # Two entities are equal if they are instances of the same class and they
    # have the same id.
    #
    # @param other [Object] the object of comparison
    #
    # @return [FalseClass,TrueClass] the result of the check
    def ==(other)
      self.class == other.class &&
        id == other.id
    end

    # Implement predictable hashing for hash equality
    #
    # @return [Integer] the object hash
    def hash
      [self.class, id].hash
    end

    # Freeze the entity
    def freeze
      attributes.freeze
      super
    end

    # Serialize entity to a Hash
    #
    # @return [Hash] the result of serialization
    def to_h
      Hanami::Utils::Hash.deep_dup(attributes)
    end

    alias_method :to_hash, :to_h

    protected

    # Check if the attribute is allowed to be read
    def attribute?(name)
      self.class.schema.attribute?(name)
    end

    private

    attr_reader :attributes

    def respond_to_missing?(name, _include_all)
      attribute?(name)
    end
  end
end
