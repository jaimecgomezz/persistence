# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Delete do
  let(:operation) { Persistence::Store::Operations::Delete.new(:a) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end

    context 'with Operation having a source' do
      it 'initializes class' do
        expect(described_class.new(operation)).to be_a(described_class)
      end
    end

    context 'with Operation not having a source' do
      let(:operation) { Class.new.new }

      it 'raises exception' do
        expect { described_class.new(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  context '#build' do
    let(:result) { described_class.new(operation).build }

    it 'builds clause' do
      expect(result).to eq("DELETE FROM ONLY a")
    end
  end
end
