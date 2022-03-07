# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Insert do
  let(:mocker) { described_class.new(operation) }

  describe '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with valid operation provided' do
      let(:operation) { Persistence::Store::Operations::Insert.new(:a) }

      it 'builds clause' do
        expect(result).to eq("INSERT INTO a")
      end

      context 'with operation defining assignments' do
        let(:operation) do
          Persistence::Store::Operations::Insert.new(:a).set(:id, email: 'a@mail.com', meta: { id: 1 })
        end

        it 'includes them in the clause' do
          expect(result).to eq("INSERT INTO a (id, email, meta)")
        end
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
