# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Where do
  let(:base) do
    Class.new(Persistence::Store::Operations::Select) do
      def initialize(source)
        @source = source
      end
    end.new(:a)
  end
  let(:mocker) { described_class.new(operation, {}) }

  describe '.new' do
    it 'expects operation and params' do
      expect(described_class).to respond_to(:new).with(2).arguments
    end
  end

  describe '#build' do
    let(:result) { mocker.build }

    context 'with empty user filters and empty global filters' do
      let(:operation) { base }

      it 'returns empty statement' do
        expect(result).to match(["", {}])
      end
    end

    context 'with non-empty user filters' do
      let(:operation_filtered) do
        base.
          where({ id: 1, name: 'Luis' }).
          where.and({ email: 'a@email.com', job: 'dev' }).
          where.or({ country: 'Mexico', age: 20, job: 'designer' }).
          where.and({ meta: { org: { info: { id: 10 } } }, ultra: { name: 'Julio' } })
      end
      let(:operation) { operation_filtered }

      it 'build clause' do
        params = {
          where_a_id: 1,
          where_a_name: 'Luis',
          where_b_email: 'a@email.com',
          where_b_job: 'dev',
          where_c_country: 'Mexico',
          where_c_age: 20,
          where_c_job: 'designer',
          where_d_meta__org__info__id: 10,
          where_d_ultra__name: 'Julio'
        }
        statement = [
          "WHERE",
          "((id = :where_a_id AND name = :where_a_name)",
          "AND (email = :where_b_email AND job = :where_b_job)",
          "OR (country = :where_c_country AND age = :where_c_age AND job = :where_c_job)",
          "AND (meta -> org -> info ->> id = :where_d_meta__org__info__id AND ultra ->> name = :where_d_ultra__name))"
        ].join(" ")

        expect(result[0]).to match(statement)
        expect(result[1]).to match(params)
      end

      context 'with non-empty global filters' do
        let(:operation) { operation_filtered.exclude_discarded }

        it 'build clause' do
          params = {
            where_a_id: 1,
            where_a_name: 'Luis',
            where_b_email: 'a@email.com',
            where_b_job: 'dev',
            where_c_country: 'Mexico',
            where_c_age: 20,
            where_c_job: 'designer',
            where_d_meta__org__info__id: 10,
            where_d_ultra__name: 'Julio',
            where_e_deleted_at: nil
          }
          statement = [
            "WHERE",
            "((id = :where_a_id AND name = :where_a_name)",
            "AND (email = :where_b_email AND job = :where_b_job)",
            "OR (country = :where_c_country AND age = :where_c_age AND job = :where_c_job)",
            "AND (meta -> org -> info ->> id = :where_d_meta__org__info__id AND ultra ->> name = :where_d_ultra__name))",
            "AND (deleted_at = :where_e_deleted_at)"
          ].join(" ")

          expect(result[0]).to match(statement)
          expect(result[1]).to match(params)
        end
      end
    end

    context 'wirth Operation not being a Filter' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
