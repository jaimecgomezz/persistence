# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Values do
  let(:base) { Persistence::Store::Operations::Insert.new(:a) }
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).arguments
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with empty assignments' do
      let(:operation) { base }

      it 'returns an empty statement' do
        expect(result).to match(["", {}])
      end
    end

    context 'with non-empty assignments' do
      let(:operation) { base.set(:id, email: 'a@email.com', meta: { country: 'Mexico' }) }

      it 'build clause' do
        params = {
          values_email: 'a@email.com',
          values_meta: { country: 'Mexico' }
        }
        statement = [
          "VALUES",
          [
            "(",
            [
              "DEFAULT",
              ":values_email",
              ":values_meta"
            ].join(", "),
            ")"
          ].join
        ].join(" ")

        expect(result).to match([statement, params])
      end
    end

    context 'with Operation not being a Setter' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
