# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::From do
  let(:operation) { Persistence::Store::Operations::Select.new(:a) }

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
    let(:result) { described_class.new(operation.join(joins)).build }

    context 'with empty joins' do
      let(:joins) { {} }

      it 'returns empty string' do
        expect(result).to eq("FROM a")
      end
    end

    context 'with non-empty joins' do
      let(:joins) do
        {
          b: {
            kind: :lj,
            left: :id,
            right: :a_id
          },
          c: {
            kind: 'CUSTOM JOIN',
            left: 'what',
            right: 'ever'
          },
          d: {
            kind: :roj,
            left: 'id',
            right: :a_id
          }
        }
      end

      it 'build clause' do
        sa = "LEFT JOIN ON a.id = b.a_id"
        sb = "CUSTOM JOIN ON a.what = c.ever"
        sc = "RIGHT OUTER JOIN ON a.id = d.a_id"
        joiner = " "

        statement = ["FROM ", "a ", sa, joiner, sb, joiner, sc].join

        expect(result).to eq(statement)
      end
    end
  end
end
