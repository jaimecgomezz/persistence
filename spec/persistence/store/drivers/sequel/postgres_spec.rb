# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Postgres do
  let(:mocker) { described_class.new(db: db) }

  describe '#run_custom' do
    let(:id) { uuid }
    let(:db) { Sequel.mock(fetch: { id: id }) }

    context 'with successful execution' do
      let(:result) { mocker.run_custom("SELECT * WHERE id = :id", { id: id }) }

      it 'runs custom statement' do
        expect(result.first).to match({ id: id })
      end
    end

    context 'with exception during execution' do
      let(:db) { Sequel.mock(fetch: StandardError) }

      it 'handles exception' do
        expect do
          mocker.run_custom("SELECT * WHERE id = :id", { id: id })
        end .to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  describe '#build' do
    let(:db) { Class.new.new }
    let(:result) { mocker.build(operation) }

    context 'with Count operation' do
      let(:operation) { Persistence::Store::Operations::Count.new(:a).include_discarded }

      it 'build statement' do
        params = {}
        statement = "SELECT COUNT(a.*) FROM a"

        expect(result).to match([statement, params])
      end
    end

    context 'with Delete operation' do
      let(:operation) { Persistence::Store::Operations::Delete.new(:a).include_discarded }

      it 'build statement' do
        params = {}
        statement = "DELETE FROM ONLY a RETURNING *"

        expect(result).to match([statement, params])
      end
    end

    context 'with Discard operation' do
      let(:operation) { Persistence::Store::Operations::Discard.new(:a) }

      it 'build statement' do
        discarded_attribute = ["set_", Persistence::Config::DISCARD_ATTRIBUTE].join
        statement = "UPDATE ONLY a SET deleted_at = :#{discarded_attribute} RETURNING *"

        expect(result[0]).to match(statement)
        expect(result[1].keys).to include(discarded_attribute.to_sym)
      end
    end

    context 'with Insert operation' do
      let(:operation) { Persistence::Store::Operations::Insert.new(:a).values(id: 1) }

      it 'build statement' do
        params = { values_id: 1 }
        statement = "INSERT INTO a (id) VALUES (:values_id) RETURNING *"

        expect(result).to match([statement, params])
      end
    end

    context 'with Select operation' do
      let(:operation) { Persistence::Store::Operations::Select.new(:a).include_discarded }

      it 'build statement' do
        params = {}
        statement = "SELECT * FROM a"

        expect(result).to match([statement, params])
      end
    end

    context 'with Update operation' do
      let(:operation) { Persistence::Store::Operations::Update.new(:a).set(id: 2).where({ id: 1 }).include_discarded }

      it 'build statement' do
        params = { where_a_id: 1, set_id: 2 }
        statement = "UPDATE ONLY a SET id = :set_id WHERE ((id = :where_a_id)) RETURNING *"

        expect(result).to match([statement, params])
      end
    end

    context 'with unsupported operation' do
      let(:operation) do
        Class.new do
          def name
            :undefined
          end
        end.new
      end

      it 'raises exception' do
        expect { mocker.build(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end

  describe '#run' do
    let(:db) { Sequel.mock(fetch: fetch) }

    let(:result) { mocker.run(operation) }

    context 'with Count operation' do
      let(:fetch) { [{ count: 10 }] }
      let(:operation) { Persistence::Store::Operations::Count.new(:a) }

      it 'adequately process count' do
        expect(result).to be(10)
      end
    end

    context 'with Select operation' do
      let(:fetch) { [{ id: 1 }, { id: 2 }] }
      let(:base) { Persistence::Store::Operations::Select.new(:a) }

      context 'with limit of 1' do
        let(:operation) { base.limit(1) }

        it 'returns only first record' do
          expect(result).to match(fetch.first)
        end
      end

      context 'with limit different than 1' do
        let(:operation) { base }

        it 'returns all founded records' do
          expect(result).to match(fetch)
        end
      end
    end

    context 'with invalid db' do
      let(:db) { Class.new.new }

      it 'raises exception' do
        expect { mocker.run(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end

    context 'with invalid Operation' do
      let(:fetch) { [] }
      let(:operation) { Persistence::Store::Operations::Select.new(:a) }

      it 'raises exception on missing #name' do
        operation.instance_eval('undef :name')

        expect { mocker.run(operation) }.to raise_error(Persistence::Errors::DriverError)
      end

      it 'raises exception on missing #after' do
        operation.instance_eval('undef :after')

        expect { mocker.run(operation) }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
