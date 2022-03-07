# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Insert do
  let(:base) { Persistence::Store::Operations::Insert.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  describe '#build' do
    let(:operation) { base }
    let(:result) { mocker.build }

    it 'builds clause' do
      params = {}
      statement = "INSERT INTO a"
      expect(result).to eq([statement, params])
    end

    context 'with operation defining assignments' do
      let(:operation) { base.set(:id, email: 'a@mail.com', meta: { id: 1 }) }

      it 'includes them in the clause' do
        params = {}
        statement = "INSERT INTO a (id, email, meta)"
        expect(result).to match([statement, params])
      end
    end

    context 'with Operation missing its source' do
      let(:operation) { Class.new.new }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
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
