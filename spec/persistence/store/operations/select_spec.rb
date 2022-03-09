# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Select do
  let(:mocker) { described_class.new(:a) }

  include_context 'sourcer'
  include_context 'filter'
  include_context 'aggregator'
  include_context 'retriever'
  include_context 'orderer'
  include_context 'differentiator'
  include_context 'grouper'
  include_context 'joiner'
  include_context 'requirer'
  include_context 'paginator'
  include_context 'preloader'
  include_context 'discard_manager'

  it 'discards discarded by default' do
    expected = Hash[[[Persistence::Config::DISCARD_ATTRIBUTE, nil]]]

    expect(mocker.global_filters).to include(expected)
  end

  describe '#after' do
    let(:results) { [1, 2, 3] }
    let(:result) { limited_mocker.after(results) }

    context 'with limit being 1' do
      let(:limited_mocker) { mocker.limit(1) }

      it 'returns first item' do
        expect(result).to match(results.first)
      end
    end

    context 'with limit being different than 1' do
      let(:limited_mocker) { mocker }

      it 'returns all items' do
        expect(result).to match(results)
      end
    end
  end
end
