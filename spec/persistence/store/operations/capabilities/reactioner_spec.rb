# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Reactioner do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Reactioner }.new }

  describe '#react' do
    it 'returns self' do
      expect(mocker.react(a: :b)).to be(mocker)
    end

    context 'when it is called multiple times' do
      let(:resulting) { mocker.react(a: :b) }

      it 'overwrites previous configuration' do
        expect(resulting.react(c: :d).reactions).to match({
          c: {
            action: :d,
            constraint: :c
          }
        })
      end
    end

    context 'with keyword arguments' do
      context 'having symbols/strings as their values' do
        let(:resulting) { mocker.react(a: :noting, b: :update) }

        it 'assumes a list of events with their reactions was provided' do
          expect(resulting.reactions).to match({
            a: {
              action: :noting,
              constraint: :a
            },
            b: {
              action: :update,
              constraint: :b
            }
          })
        end
      end

      context 'having hashes as their values' do
        context 'with hashes being valid reactions mappings' do
          let(:resulting) do
            mocker.react(a: { action: :nothing, constraint: :A }, b: { action: :update, constraint: :id })
          end

          it 'assumes a list of events with custom reaction mappings was provided' do
            expect(resulting.reactions).to match({
              a: {
                action: :nothing,
                constraint: :A
              },
              b: {
                action: :update,
                constraint: :id
              }
            })
          end
        end

        context 'with hashes being invalid reactions mappings' do
          it 'raises exception' do
            expect { mocker.react(a: {}) }.to raise_error(Persistence::Errors::OperationError)
          end
        end
      end
    end
  end
end
