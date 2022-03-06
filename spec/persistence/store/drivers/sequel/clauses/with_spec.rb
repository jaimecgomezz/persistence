# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::With do
  let(:instance) { described_class.new(operation) }

  context '.new' do
    it 'expects operation' do
      expect(described_class).to respond_to(:new).with(1).argument
    end
  end

  context '#build' do
    let(:result) { instance.build }

    context 'with operation being a Requirer' do
      let(:operation) { Persistence::Store::Operations::Select.new(:a).requiring(requirements) }

      context 'with empty requirements' do
        let(:requirements) { {} }

        it 'returns empty string' do
          expect(result).to eq("")
        end
      end

      context 'with non-empty requirements' do
        let(:requirements) { { groups: "SELECT * FROM groups", accounts: "SELECT id, email FROM accounts" } }

        it 'build clause' do
          expect(result).to eq("WITH groups AS (SELECT * FROM groups), accounts AS (SELECT id, email FROM accounts)")
        end
      end
    end

    context 'with operation not being a Requirer' do
      let(:operation) { Class.new.new }

      it 'raises exception' do
        expect { instance.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
