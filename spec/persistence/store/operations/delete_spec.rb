# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Delete do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'retriever'
  include_context 'requirer'
  include_context 'discard_manager'

  it 'discards discarded by default' do
    expected = Hash[[[Persistence::Config::DISCARD_ATTRIBUTE, nil]]]

    expect(mocker.global_filters).to include(expected)
  end

  describe '#after' do
    let(:result) { mocker.after(results) }

    context 'with results size being 1' do
      let(:results) { [1] }

      it 'returns first item' do
        expect(result).to match(results.first)
      end
    end

    context 'with results size being different than 1' do
      let(:results) { [1, 2, 3] }

      it 'returns all items' do
        expect(result).to match(results)
      end
    end
  end
end
