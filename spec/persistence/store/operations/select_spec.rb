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
end
