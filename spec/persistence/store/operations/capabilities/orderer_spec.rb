# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Orderer do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Orderer }.new }

  describe '#order' do
    it 'returns self' do
      expect(mocker.order(:created_at)).to be(mocker)
    end

    context 'with method being called more than once' do
      let(:resulting) { mocker.order(:created_at, updated_at: { order: :asc, nulls: :last }) }

      it 'respects newest criteria' do
        expect(resulting.order(:deleted_at, removed_at: { order: :desc, nulls: :first }).orderings).to match([
          { criteria: :deleted_at, order: :asc },
          { criteria: :removed_at, order: :desc, nulls: :first }
        ])
      end
    end

    context 'with positional arguments' do
      context 'being symbols/strings' do
        let(:resulting) { mocker.order(:created_at, :updated_at) }

        it 'assumes a list of ordering criteria with default ordering was given' do
          expect(resulting.orderings).to match([
            { criteria: :created_at, order: :asc },
            { criteria: :updated_at, order: :asc }
          ])
        end
      end

      context 'being any other data type' do
        it 'raises exception' do
          expect { mocker.order(1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as values' do
        let(:resulting) { mocker.order(:created_at, updated_at: :desc) }

        it 'assumes a list of criteria with custom ordering was given' do
          expect(resulting.orderings).to match([
            { criteria: :created_at, order: :asc },
            { criteria: :updated_at, order: :desc }
          ])
        end
      end

      context 'with hashes as values' do
        let(:resulting) { mocker.order(:created_at, updated_at: :desc, deleted_at: { order: :asc, nulls: :last }) }

        it 'assumes a list of criteria with custom mappings was given' do
          expect(resulting.orderings).to match([
            { criteria: :created_at, order: :asc },
            { criteria: :updated_at, order: :desc },
            { criteria: :deleted_at, order: :asc, nulls: :last }
          ])
        end
      end

      context 'with any other data type as values' do
        it 'raises exception' do
          expect { mocker.order(created_at: 1) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe '#reverse_existing_orderings!' do
    context 'with valid existing orderings' do
      let(:resulting) { mocker.order(:created_at, updated_at: :desc).reverse_existing_orderings! }

      it 'reverts orderings' do
        expect(resulting.orderings).to match([
          { criteria: :created_at, order: :desc },
          { criteria: :updated_at, order: :asc }
        ])
      end
    end

    context 'with invalid existing orderings' do
      it 'raises exception' do
        expect do
          mocker.order(created_at: :lol).reverse_existing_orderings!
        end.to raise_error(Persistence::Errors::OperationError)
      end
    end
  end
end
