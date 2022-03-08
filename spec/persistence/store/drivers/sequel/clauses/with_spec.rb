# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::With do
  let(:base) { Persistence::Store::Operations::Select.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  context '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  context '#build' do
    let(:result) { mocker.build }

    context 'with empty requirements' do
      let(:operation) { base }

      it 'returns empty string' do
        expect(result).to eq(["", {}])
      end
    end

    context 'with non-empty requirements' do
      let(:operation) { base.requiring(a: "SELECT * FROM a", b: "SELECT id FROM b", c: "SELECT COUNT(*) FROM c") }

      it 'build clause' do
        params = {}
        statement = [
          "WITH",
          [
            "a AS (SELECT * FROM a)",
            "b AS (SELECT id FROM b)",
            "c AS (SELECT COUNT(*) FROM c)"
          ].join(", ")
        ].join(" ")

        expect(result).to match([statement, params])
      end
    end

    context 'with Operation not being a Requirer' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
