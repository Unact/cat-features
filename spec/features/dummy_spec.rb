require "spec_helper"

RSpec.describe CatFeatures::Dummy do
  it "always returns 0" do
    expect(described_class.instance.dummy_col).to be 0
  end
end
