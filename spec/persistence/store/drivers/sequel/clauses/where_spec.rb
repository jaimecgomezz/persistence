# frozen_string_literal: true

RSpec.describe Persistence::Store::Drivers::Sequel::Clauses::Where do
  let(:base) { Persistence::Store::Operations::Select.new(:a).include_discarded }
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

    context 'with simple user filters' do
      let(:operation) { base.where({ a: 1 }).where.and({ b: 'c' }).where.or({ c: 'value' }) }

      it 'builds clause' do
        params = {
          where_a_a: 1,
          where_b_b: 'c',
          where_c_c: 'value'
        }
        statement = "WHERE ((a = :where_a_a) AND (b = :where_b_b) OR (c = :where_c_c))"

        expect(result).to match([statement, params])
      end

      context 'with global filters' do
        let(:operation) { base.where({ a: 1 }).where.and({ b: 'c' }).where.or({ c: 'value' }).exclude_discarded }

        it 'includes them in clause' do
          params = {
            where_a_a: 1,
            where_b_b: 'c',
            where_c_c: 'value',
            where_d_deleted_at: nil
          }
          statement = "WHERE ((a = :where_a_a) AND (b = :where_b_b) OR (c = :where_c_c)) AND (deleted_at = :where_d_deleted_at)"

          expect(result).to match([statement, params])
        end
      end
    end

    context 'with simple user negated filters' do
      let(:operation) { base.where_not({ a: 1 }).where_not.and({ b: 'c' }).where_not.or({ c: 'value' }) }

      it 'builds clause' do
        params = {
          where_a_a: 1,
          where_b_b: 'c',
          where_c_c: 'value'
        }
        statement = "WHERE (NOT (a = :where_a_a) AND NOT (b = :where_b_b) OR NOT (c = :where_c_c))"

        expect(result).to match([statement, params])
      end

      context 'with global filters' do
        let(:operation) do
          base.where_not({ a: 1 }).where_not.and({ b: 'c' }).where_not.or({ c: 'value' }).exclude_discarded
        end

        it 'includes them in clause' do
          params = {
            where_a_a: 1,
            where_b_b: 'c',
            where_c_c: 'value',
            where_d_deleted_at: nil
          }
          statement = "WHERE (NOT (a = :where_a_a) AND NOT (b = :where_b_b) OR NOT (c = :where_c_c)) AND (deleted_at = :where_d_deleted_at)"

          expect(result).to match([statement, params])
        end
      end
    end

    context 'with complex filters' do
      let(:operation) { base.where(filters) }

      context 'arrays' do
        let(:filters) { { a: [1, 2, 3] } }

        it 'build IN clause' do
          params = { where_a_a: [1, 2, 3] }
          statement = "WHERE ((a IN :where_a_a))"

          expect(result).to match([statement, params])
        end
      end

      context 'time ranges' do
        let(:today) { Time.now }
        let(:day) { 60 * 60 * 24 }
        let(:tomorrow) { today + day }
        let(:filters) { { a: today..tomorrow } }

        it 'build BETWEEN clause' do
          params = {
            where_a_a_first: today.utc.to_s,
            where_a_a_last: tomorrow.utc.to_s
          }
          statement = "WHERE ((a BETWEEN :where_a_a_first AND :where_a_a_last))"

          expect(result).to match([statement, params])
        end
      end

      context 'common ranges' do
        let(:filters) { { a: 1..10 } }

        it 'build BETWEEN clause' do
          params = {
            where_a_a_first: 1,
            where_a_a_last: 10
          }
          statement = "WHERE ((a BETWEEN :where_a_a_first AND :where_a_a_last))"

          expect(result).to match([statement, params])
        end
      end

      context 'json' do
        let(:filters) { { a: { b: { c: { d: 1, e: { f: 2 } } } } } }

        it 'builds ->/->> clause' do
          params = {
            where_a_a__b__c__d: 1,
            where_a_a__b__c__e__f: 2
          }
          statement = "WHERE ((a -> b -> c ->> d = :where_a_a__b__c__d AND a -> b -> c -> e ->> f = :where_a_a__b__c__e__f))"

          expect(result).to match([statement, params])
        end
      end

      context 'time' do
        let(:now) { Time.now }
        let(:filters) { { a: now } }

        it 'build clause' do
          params = {
            where_a_a: now.utc.to_s
          }
          statement = "WHERE ((a = :where_a_a))"

          expect(result).to match([statement, params])
        end
      end

      context 'Operations' do
        let(:filters) { { a: Persistence::Store::Operations::Select.new(:a) } }

        it 'raises exception' do
          expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
        end
      end

      context 'truly complex filters' do
        let(:operation) do
          base.
            where({ id: 1, name: 'Luis' }).
            where.and({ email: 'a@email.com', job: 'dev' }).
            where.or({ country: 'Mexico', age: 20, job: 'designer' }).
            where.and({ meta: { org: { info: { id: 10 } } }, ultra: { name: 'Julio' } })
        end

        it 'builds clause' do
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

          expect(result).to match([statement, params])
        end
      end
    end

    context 'with Operation not being a Filter' do
      let(:operation) { Persistence::Store::Operations::Operation.new(:a) }

      it 'raises exception' do
        expect { mocker.build }.to raise_error(Persistence::Errors::DriverError)
      end
    end
  end
end
