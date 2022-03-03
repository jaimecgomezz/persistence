# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Retriever do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Retriever }.new }

  describe '#retrieve' do
    it 'returns self' do
      expect(mocker.retrieve(:id)).to be(mocker)
    end

    context 'with single argument' do
      let(:resulting) { mocker.retrieve(:id) }

      it 'assumes a single field is required' do
        expect(resulting.retrievables).to match({
          id: {
            alias: nil,
            resource: nil
          }
        })
      end

      context 'with :resource provided' do
        let(:resulting) { mocker.retrieve(:id, resource: :users) }

        it 'includes resource in mapping' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: :users
            }
          })
        end
      end
    end

    context 'with multiple arguments' do
      let(:resulting) { mocker.retrieve(:id, :name) }

      it 'assumes a list of fields was provided' do
        expect(resulting.retrievables).to match({
          id: {
            alias: nil,
            resource: nil
          },
          name: {
            alias: nil,
            resource: nil
          }
        })
      end

      context 'with :resource provided' do
        let(:resulting) { mocker.retrieve(:id, :name, resource: :users) }

        it 'includes resource un mapping' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: :users
            },
            name: {
              alias: nil,
              resource: :users
            }
          })
        end
      end
    end

    context 'with multiple arguments and some being lists' do
      let(:resulting) { mocker.retrieve(:id, [:name, :NAME]) }

      it 'assumes a list of fields with their alias was provided' do
        expect(resulting.retrievables).to match({
          id: {
            alias: nil,
            resource: nil
          },
          name: {
            alias: :NAME,
            resource: nil
          }
        })
      end

      context 'with :resource provided' do
        let(:resulting) { mocker.retrieve(:id, [:name, :NAME], resource: :users) }

        it 'includes resource in mapping' do
          expect(resulting.retrievables).to match({
            id: {
              alias: nil,
              resource: :users
            },
            name: {
              alias: :NAME,
              resource: :users
            }
          })
        end
      end
    end
  end
end
