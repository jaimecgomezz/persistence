# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Set do
  let(:base) { Persistence::Store::Operations::Update.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).arguments
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with empty assignments' do
      let(:operation) { base }

      it 'returns empty string' do
        expect(result).to match(["", {}])
      end
    end

    context 'with non-empty assignments' do
      let(:operation) { base.set(:income, age: 10, meta: { some: 'other' }) }

      it 'build clause' do
        params = {
          set_age: 10,
          set_meta: {
            some: 'other'
          }
        }

        statement = [
          "SET",
          [
            "income = DEFAULT",
            "age = :set_age",
            "meta = :set_meta"
          ].join(", ")
        ].join(" ")

        expect(result).to match([statement, params])
      end
    end

    context 'with Operation not being a Setter' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
