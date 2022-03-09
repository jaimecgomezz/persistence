# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Count do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'discard_manager'

  it 'discards discarded by default' do
    expected = Hash[[[Persistence::Config::DISCARD_ATTRIBUTE, nil]]]

    expect(mocker.global_filters).to include(expected)
  end
end
