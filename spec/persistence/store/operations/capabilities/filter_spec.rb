# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Filter do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Filter }.new }

  let(:filters) { { a: 1, b: 2 } }
  let(:secondary_filters) { { b: 3, c: 4 } }

  describe '#where' do
    it 'returns self' do
      expect(mocker.where({ id: 1 })).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.where({ id: 1 }) }

      it 'overwrites previous configuration' do
        expect(resulting.where({ id: 2 }).user_filters).to match([
          {
            negate: false,
            operand: :and,
            filters: { id: 2 }
          }
        ])
      end
    end

    context 'with no arguments' do
      let(:resulting) { mocker.where }

      it 'grants access to nested methods' do
        expect(resulting).to respond_to(:or).with(1).argument
        expect(resulting).to respond_to(:and).with(1).argument
      end
    end

    context 'with hash argument' do
      let(:resulting) { mocker.where(filters) }

      it 'sets primary filters' do
        expect(resulting.user_filters.first).to match({
          negate: false,
          operand: :and,
          filters: filters
        })
      end
    end

    describe '#or' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where(filters).where.or(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.user_filters.last).to match({
            negate: false,
            operand: :or,
            filters: secondary_filters
          })
        end
      end

      context 'without existing primary filters' do
        it 'raises exception' do
          expect { mocker.where.or(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    describe '#and' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where(filters).where.and(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.user_filters.last).to match({
            negate: false,
            operand: :and,
            filters: secondary_filters
          })
        end
      end

      context 'without existing primary filters' do
        it 'raises exception' do
          expect { mocker.where.and(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end

  describe '#where_not' do
    it 'returns self' do
      expect(mocker.where_not({ id: 1 })).to be(mocker)
    end

    context 'with method being called multiple times' do
      let(:resulting) { mocker.where_not({ id: 1 }) }

      it 'overwrites previous configuration' do
        expect(resulting.where_not({ id: 2 }).user_filters).to match([
          {
            negate: true,
            operand: :and,
            filters: { id: 2 }
          }
        ])
      end
    end

    context 'with no arguments' do
      let(:resulting) { mocker.where_not }

      it 'grants access to nested methods' do
        expect(resulting).to respond_to(:or).with(1).argument
        expect(resulting).to respond_to(:and).with(1).argument
      end
    end

    context 'with hash argument' do
      let(:resulting) { mocker.where_not(filters) }

      it 'sets primary filters' do
        expect(resulting.user_filters.first).to match({
          negate: true,
          operand: :and,
          filters: filters
        })
      end
    end

    describe '#or' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where_not(filters).where_not.or(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.user_filters.last).to match({
            negate: true,
            operand: :or,
            filters: secondary_filters
          })
        end
      end

      context 'without existing primary filters' do
        it 'raises exception' do
          expect { mocker.where_not.or(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    describe '#and' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where_not(filters).where_not.and(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.user_filters.last).to match({
            negate: true,
            operand: :and,
            filters: secondary_filters
          })
        end
      end

      context 'without existing primary filters' do
        it 'raises exception' do
          expect { mocker.where_not.and(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end
  end
end
