# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Insert do
  let(:mocker) { described_class.new(:a) }

  include_context 'retriever'
  include_context 'requirer'
  include_context 'setter'
  include_context 'reactioner'
end
