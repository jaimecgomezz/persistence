# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Filter do
  let(:filters) { { a: 1, b: 2 } }
  let(:secondary_filters) { { b: 3, c: 4 } }

  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Filter }.new }
  let(:filters_builder) { Persistence::Store::Operations::Capabilities::Helpers::FiltersBuilder.new }

  it 'exposes #where' do
    expect(mocker).to respond_to(:where)
  end

  describe '#where' do
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
        expect(resulting.filters.first).to match({
          __negate: false,
          __operand: :and,
          __filters: filters_builder.build(filters)
        })
      end

      context 'and existing primary filters' do
        it 'raises exception' do
          expect { resulting.where(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    describe '#or' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where(filters).where.or(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.filters.last).to match({
            __negate: false,
            __operand: :or,
            __filters: filters_builder.build(secondary_filters)
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
          expect(resulting.filters.last).to match({
            __negate: false,
            __operand: :and,
            __filters: filters_builder.build(secondary_filters)
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
        expect(resulting.filters.first).to match({
          __negate: true,
          __operand: :and,
          __filters: filters_builder.build(filters)
        })
      end

      context 'and existing primary filters' do
        it 'raises exception' do
          expect { resulting.where_not(secondary_filters) }.to raise_error(Persistence::Errors::OperationError)
        end
      end
    end

    describe '#or' do
      context 'with existing primary filters' do
        let(:resulting) { mocker.where_not(filters).where_not.or(secondary_filters) }

        it 'adds secondary filters' do
          expect(resulting.filters.last).to match({
            __negate: true,
            __operand: :or,
            __filters: filters_builder.build(secondary_filters)
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
          expect(resulting.filters.last).to match({
            __negate: true,
            __operand: :and,
            __filters: filters_builder.build(secondary_filters)
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
