# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Discard do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'retriever'
  include_context 'setter'
end
