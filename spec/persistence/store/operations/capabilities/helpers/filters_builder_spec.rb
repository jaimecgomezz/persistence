# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Helpers::FiltersBuilder do
  let(:builder) { described_class.new }
  let(:now) { Time.now }
  let(:tomorrow) { now + (60 * 60 * 24) }
  let(:day_after_tomorrow) { tomorrow + (60 * 60 * 24) }

  describe '.new' do
    it 'expects no arguments' do
      expect(described_class).to respond_to(:new).with(0).argument
    end
  end

  describe '#build' do
    context 'with valid filters' do
      let(:filters) do
        {
          a: [1, 2, 3],
          b: now..tomorrow,
          c: /[a-z]+/,
          d: 'word',
          e: {
            __operand: :lt,
            __value: 10
          },
          f: {
            g: {
              h: 10
            }
          }
        }
      end
      let(:result) { builder.build(filters) }

      it 'handles array filters' do
        expect(result[:a]).to match({ __operand: :in, __value: filters[:a] })
      end

      it 'handles range filters' do
        range = filters[:b]
        expect(result[:b]).to match({ __operand: :between, __value: [range.first, range.last] })
      end

      it 'handles regex filters' do
        expect(result[:c]).to match({ __operand: :like, __value: filters[:c] })
      end

      it 'handles simple filters' do
        expect(result[:d]).to match({ __operand: :eq, __value: filters[:d] })
      end

      it 'handles custom filters' do
        expect(result[:e]).to match(filters[:e])
      end

      it 'handles nested filters' do
        expect(result[:f]).to match(
          {
            __operand: :nested,
            __value: {
              g: {
                __operand: :nested,
                __value: {
                  h: {
                    __operand: :eq,
                    __value: 10
                  }
                }
              }
            }
          }
        )
      end
    end
  end

  context 'with invalid filters' do
    let(:filters) { ['invalid', 1, ['a'], Class.new].sample }

    it 'raises error' do
      expect { builder.build(filters) }.to raise_error(Persistence::Errors::OperationError)
    end
  end

  context 'with invalid custom filters' do
    let(:filters) { { __operand: :whatever, __value: 1 } }

    it 'raises error' do
      expect { builder.build(filters) }.to raise_error(Persistence::Errors::OperationError)
    end
  end
end
