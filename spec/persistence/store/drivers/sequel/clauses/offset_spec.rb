# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Offset do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with Operation being a Paginator' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not being a Paginator' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  context '#build' do
    context 'with unset offset' do
      let(:result) { described_class.new(operation).build }

      it 'returns empty string' do
        expect(result).to eq("")
      end
    end

    context 'with set offset' do
      let(:result) { described_class.new(operation.offset(10)).build }

      it 'builds clause' do
        expect(result).to eq("OFFSET 10")
      end
    end
  end
end
