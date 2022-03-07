# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::OnConflict do
  let(:base) { Persistence::Store::Operations::Insert.new(:login_attempts) }
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and filters' do
      expect(described_class).to respond_to(:new).with(2).argument
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with no conflicts' do
      let(:operation) { base }

      it 'returns empty statement and params' do
        stmnt, params = result
        expect(stmnt).to be_empty
        expect(params).to be_empty
      end
    end

    context 'on :update action' do
      context 'with expressions' do
        let(:operation) do
          base.react(
            conflicting: :unique_email,
            action: :update,
            using: {
              count: {
                value: 'EXCLUDED.count + 1',
                kind: :expression
              }
            }
          )
        end

        it 'builds clause' do
          stmnt, params = result
          expect(stmnt).to eq("ON CONFLICT ON CONSTRAINT unique_email DO UPDATE SET count = EXCLUDED.count + 1")
          expect(params).to match({})
        end
      end

      context 'with literals' do
        let(:operation) do
          base.react(
            conflicting: :unique_email,
            action: :update,
            using: {
              count: {
                value: 0,
                kind: :literal
              },
              other: {
                value: 'other',
                kind: :literal
              }
            }
          )
        end

        it 'builds clause' do
          stmnt, params = result
          expect(stmnt).to eq("ON CONFLICT ON CONSTRAINT unique_email DO UPDATE SET count = :conflicting_count, other = :conflicting_other")
          expect(params).to match({ conflicting_count: 0, conflicting_other: 'other' })
        end
      end
    end

    context 'on :nothing action' do
      let(:operation) { base.react(conflicting: [:email], action: :nothing, using: {}) }

      it 'build clause' do
        stmnt, params = result
        expect(stmnt).to eq("ON CONFLICT (email) DO NOTHING")
        expect(params).to match({})
      end
    end

    context 'with Operation not being a Reactioner' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
