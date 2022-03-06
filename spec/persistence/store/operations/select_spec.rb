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
end
