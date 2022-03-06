# frozen_string_literal: true

module Persistence
  # Abstract layer that hides implementation details related to the persistence
  # layer. It has 2 main responsibilities:
  #   - Querying the DB through the Engine
  #   - Transform Engine's result into the expected format using the Tranformer
  #
  # Example
  #
  # class UserRepository < Repository
  # end
  #
  # user_repository = UserRespository.new
  # users_paginated = user_repository.all
  class Repository
    attr_reader :engine, :transformer

    def initialize(engine:, transformer: nil)
      @engine = engine
      @transformer = transformer || Transformers::UnitTransformer
    end

    def count
      engine.count.perform
    end

    def count_where(filters)
      engine.count.where(filters).perform
    end

    def all
      transformer.many(engine.select.perform)
    end

    def first
      transformer.one(engine.select.limit(1).perform)
    end

    def last
      transformer.one(engine.select.order(:desc).limit(1).perform)
    end

    def find(id)
      transformer.one(engine.select.where({ id: id }).limit(1).perform)
    end

    def find_many(ids)
      transformer.many(engine.select.where({ id: ids }).perform)
    end

    def find_discarded(id)
      transformer.one(engine.select.include_discarded.where({ id: id }).limit(1).perform)
    end

    def find_many_discarded(ids)
      transformer.many(engine.select.include_discarded.where({ id: ids }).perform)
    end

    def find_where(filters)
      transformer.one(engine.select.where(filters).limit(1).perform)
    end

    def find_many_where(filters)
      transformer.many(engine.select.where(filters).perform)
    end

    def create(input)
      transformer.one(engine.insert.set(input).perform)
    end

    def bulk(inputs)
      inputs.map do |input|
        create(input)
      end.compact
    end

    def update(id, input)
      tranformer.one(engine.update.where({ id: id }).set(input).perform)
    end

    def update_where(filters, input)
      transformer.many(engine.update.where(filters).set(input).perform)
    end

    def destroy(id)
      transformer.one(engine.delete.include_discarded.where({ id: id }).perform)
    end

    def destroy_where(filters)
      transformer.many(engine.delete.include_discarded.where(filters).perform)
    end

    def discard(id)
      transformer.one(engine.discard.where({ id: id }).perform)
    end

    def discard_where(filters)
      tranformer.many(engine.discard.where(filters).perform)
    end
  end
end
