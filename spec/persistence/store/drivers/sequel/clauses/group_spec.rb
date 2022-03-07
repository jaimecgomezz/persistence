# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Group do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  context '#build' do
    let(:result) { mocker.build }

    context 'with empty groupings' do
      let(:operation) { base }

      it 'returns empty statement' do
        expect(result).to eq(["", {}])
      end
    end

    context 'with non-empty groupings' do
      let(:operation) { base.group(:country, :state, :municipality) }

      it 'build clause' do
        params = {}
        statement = "GROUP BY country, state, municipality"
        expect(result).to eq([statement, params])
      end
    end

    context 'with Operation not being a Grouper' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
