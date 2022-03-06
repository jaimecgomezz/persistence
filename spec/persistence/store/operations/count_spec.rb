# frozen_string_literal: true

require_relative 'context'

RSpec.describe Persistence::Store::Operations::Count do
  let(:mocker) { described_class.new(:a) }

  include_context 'filter'
end
