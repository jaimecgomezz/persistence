# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Group do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with Operation being a Grouper' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not being a Grouper' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  context '#build' do
    let(:result) { described_class.new(operation.group(*groupings)).build }

    context 'with empty groupings' do
      let(:groupings) { [] }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with non-empty groupings' do
      let(:groupings) { [:country, :state, :municipality] }

      it 'build clause' do
        expect(result).to eq("GROUP BY country, state, municipality")
      end
    end
  end
end
