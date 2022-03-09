# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Count do
  let(:mocker) { described_class.new(:a) }

  include_context 'retriever'
  include_context 'filter'
  include_context 'discard_manager'

  it 'retrieves count by default' do
    expect(mocker.retrievables).to include({
      '*': {
        alias: nil,
        resource: mocker.source,
        aggregation: 'COUNT'
      }
    })
  end

  it 'discards discarded by default' do
    expected = Hash[[[Persistence::Config::DISCARD_ATTRIBUTE, nil]]]

    expect(mocker.global_filters).to include(expected)
  end

  describe '#after' do
    let(:result) { mocker.after([{ count: 10 }]) }

    it 'returns directly the count' do
      expect(result).to be(10)
    end
  end
end
