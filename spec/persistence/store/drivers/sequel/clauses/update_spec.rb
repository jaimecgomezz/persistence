# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Update do
  let(:operation) { Persistence::Store::Operations::Update.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  context '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  context '#build' do
    let(:result) { mocker.build }

    it 'builds clause' do
      params = {}
      statement = "UPDATE ONLY a"
      expect(result).to match([statement, params])
    end

    context 'with Operation not having a source' do
      let(:operation) { Class.new.new }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
