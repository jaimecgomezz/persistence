# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Builder do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:instance) { described_class.new(operation, clauses) }

  describe '.new' do
    it 'expects operation and clauses' do
      expect(described_class).to respond_to(:new).with(2).arguments
    end
  end

  describe '#build' do
    let(:result) { instance.build }

    context 'with empty clauses' do
      let(:operation) { base }
      let(:clauses) { [] }

      it 'returns empty statement' do
        expect(result).to match(["", {}])
      end
    end

    context 'with single clause' do
      let(:operation) { base }
      let(:clauses) { [Persistence::Store::Drivers::Sequel::Clauses::Select] }

      it 'build clause' do
        statement, params = clauses.first.new(operation, {}).build

        expect(result).to match([statement, params])
      end
    end

    context 'with multiple clauses' do
      let(:operation) { base.where({ id: 1 }) }
      let(:clauses) do
        [
          Persistence::Store::Drivers::Sequel::Clauses::Select,
          Persistence::Store::Drivers::Sequel::Clauses::From,
          Persistence::Store::Drivers::Sequel::Clauses::Where
        ]
      end

      it 'build clause' do
        statement_a, params_a = clauses[0].new(operation, {}).build
        statement_b, params_b = clauses[1].new(operation, params_a).build
        statement_c, params = clauses[2].new(operation, params_b).build

        statement = [statement_a, statement_b, statement_c].join(" ")

        expect(result).to match([statement, params])
      end
    end

    context 'with no valid Operation' do
      let(:operation) { Class.new.new }
      let(:clauses) { [Persistence::Store::Drivers::Sequel::Clauses::Select] }

      it 'raises exception' do
        expect { instance.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
