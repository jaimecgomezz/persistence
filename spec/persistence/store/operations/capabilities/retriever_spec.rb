# frozen_string_literal: true

RSpec.describe Persistence::Store::Operations::Capabilities::Retriever do
  let(:mocker) { Class.new { include Persistence::Store::Operations::Capabilities::Retriever }.new }

  describe '#retrieve' do
    it 'returns self' do
      expect(mocker.retrieve(:id)).to be(mocker)
    end

    context 'with positional argumemts all being symbols' do
      let(:resulting) { mocker.retrieve(:id, :name) }

      it 'assumes list of fields was provided' do
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

        it 'includes resource in mapping' do
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

    context 'with positional arguments all being lists of symbols' do
      let(:resulting) { mocker.retrieve([:id, :ID], [:name, :NAME]) }

      it 'assumes a list of fields with their alias was provided' do
        expect(resulting.retrievables).to match({
          id: {
            alias: :ID,
            resource: nil
          },
          name: {
            alias: :NAME,
            resource: nil
          }
        })
      end

      context 'with :resource provided' do
        let(:resulting) { mocker.retrieve([:id, :ID], [:name, :NAME], resource: :users) }

        it 'includes resource un mapping' do
          expect(resulting.retrievables).to match({
            id: {
              alias: :ID,
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

    context 'with positional arguments being either symbols of lists of symbols' do
      let(:resulting) { mocker.retrieve(:id, [:name, :NAME]) }

      it 'assumes a list of fields with optional aliases was provided' do
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
