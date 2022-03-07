# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Offset do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  context '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  context '#build' do
    let(:operation) { base }
    let(:result) { mocker.build }

    it 'returns empty string' do
      expect(result).to match(["", {}])
    end

    context 'with offset defined' do
      let(:operation) { base.offset(10) }

      it 'builds clause' do
        params = {}
        statement = "OFFSET 10"
        expect(result).to eq([statement, params])
      end
    end

    context 'with Operation not being a Paginator' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
