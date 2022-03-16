# frozen_string_literal: true

RSpec.describe Persistence::Utils::Hash do
  describe ".deep_symbolize_keys" do
    let(:hash) { { "foo" => "bar", "baz" => [{ "one" => 1 }, "two"] } }
    let(:result) { described_class.deep_symbolize(hash) }

    it "returns a new hash with symbolized keys" do
      expect(result).to match({ foo: "bar", baz: [{ one: 1 }, "two"] })
      expect(hash).to match("foo" => "bar", "baz" => [{ "one" => 1 }, "two"])
    end
  end

  describe ".deep_dup" do
    it "returns ::Hash" do
      hash = described_class.deep_dup({})

      expect(hash).to be_kind_of(::Hash)
    end

    it "duplicates string values" do
      input  = { "a" => "hello" }
      result = described_class.deep_dup(input)

      result["a"] << " world"

      expect(input.fetch("a")).to eq("hello")
    end

    it "duplicates array values" do
      input  = { "a" => [1, 2, 3] }
      result = described_class.deep_dup(input)

      result["a"] << 4

      expect(input.fetch("a")).to eq([1, 2, 3])
    end

    it "duplicates hash values" do
      input  = { "a" => { "b" => 2 } }
      result = described_class.deep_dup(input)

      result["a"]["c"] = 3

      expect(input.fetch("a")).to eq("b" => 2)
    end

    it "duplicates nested hashes" do
      input  = { "a" => { "b" => { "c" => 3 } } }
      result = described_class.deep_dup(input)

      result["a"].delete("b")

      expect(input).to eq("a" => { "b" => { "c" => 3 } })
    end
  end
end
