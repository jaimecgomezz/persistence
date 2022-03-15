# frozen_string_literal: true

RSpec.describe Persistence::Entity::Schema do
  describe "without definition" do
    let(:subject) { described_class.new }

    describe "#call" do
      it "processes attributes" do
        result = subject.call({ "foo" => "bar" })

        expect(result).to match({ foo: "bar" })
      end
    end

    describe "#attribute?" do
      it "always returns true" do
        expect(subject.attribute?(:foo)).to be(true)
      end
    end
  end

  describe "with definition" do
    let(:subject) do
      described_class.new do
        attribute :id, Persistence::Model::Types::Coercible::Integer
      end
    end

    describe "#call" do
      it "processes attributes" do
        result = subject.call({ id: "1" })

        expect(result).to match({ id: 1 })
      end

      it "ignores unknown attributes" do
        result = subject.call({ id: 1, foo: "bar" })

        expect(result).to match({ id: 1 })
      end
    end

    describe "#attribute?" do
      it "returns true for known attributes" do
        expect(subject.attribute?(:id)).to be(true)
      end

      it "returns false for unknown attributes" do
        expect(subject.attribute?(:foo)).to be(false)
      end
    end
  end
end
