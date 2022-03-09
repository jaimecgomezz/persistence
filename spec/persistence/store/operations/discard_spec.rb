# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Discard do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'retriever'
  include_context 'setter'

  it 'sets discardable attribute by default' do
    keys = mocker.assignments.map { |a| a[:__field] }

    expect(keys).to include(Persistence::Config::DISCARD_ATTRIBUTE)
  end
end
