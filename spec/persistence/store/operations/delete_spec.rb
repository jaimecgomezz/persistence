# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Delete do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
  include_context 'retriever'
  include_context 'requirer'
end
