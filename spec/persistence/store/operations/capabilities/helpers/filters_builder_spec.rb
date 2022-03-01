# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Helpers::FiltersBuilder do
  let(:now) { Time.now }
  let(:tomorrow) { now + (60 * 60 * 24) }
  let(:day_after_tomorrow) { tomorrow + (60 * 60 * 24) }
  let(:filters) do
    {
      a: [1, 2, 3],
      b: now..tomorrow,
      c: /[a-z]+/,
      d: 'word',
      e: {
        operand: :lt,
        value: 10
      },
      f: {
        g: {
          h: 10
        }
      }
    }
  end
  let(:builder) { described_class.new(filters) }

  describe '.new' do
    it 'expects filters' do
      expect(described_class).to respond_to(:new).with(1).argument
    end
  end

  describe '#build' do
    let(:result) { builder.build }

    it 'handles array filters' do
      expect(result[:a]).to eq({ operand: :in, value: filters[:a] })
    end

    it 'handles range filters' do
      range = filters[:b]
      expect(result[:b]).to eq({ operand: :between, value: [range.first, range.last] })
    end

    it 'handles regex filters' do
      expect(result[:c]).to eq({ operand: :like, value: filters[:c] })
    end

    it 'handles simple filters' do
      expect(result[:d]).to eq({ operand: :eq, value: filters[:d] })
    end

    it 'handles custom filters' do
      expect(result[:e]).to eq(filters[:e])
    end

    it 'handles nested filters' do
      expect(result[:f]).to match(
        {
          operand: :nested,
          value: {
            g: {
              operand: :nested,
              value: {
                h: {
                  operand: :eq,
                  value: 10
                }
              }
            }
          }
        }
      )
    end
  end
end
