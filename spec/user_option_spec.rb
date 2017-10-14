require "spec_helper"

UserOption = CatFeatures::UserOption

RSpec.describe CatFeatures::UserOption do
  it "class methods work correct" do
    expect(UserOption[:user_option_1]).to be_nil
    UserOption[:user_option_1] = "1234"
    expect(UserOption[:user_option_1]).to eq "1234"
    expect(UserOption::Model.count).to eq 1

    UserOption[:user_option_1] = nil
    expect(UserOption[:user_option_1]).to be_nil
    expect(UserOption::Model.count).to eq 0
  end

  it "instance methods work correct" do
    expect(UserOption.by_user(:dba)[:user_option_2]).to be_nil
    UserOption.by_user(:dba)[:user_option_2] = "1234"
    expect(UserOption.by_user(:dba)[:user_option_2]).to eq "1234"
    expect(UserOption::Model.count).to eq 1

    UserOption.by_user(:dba)[:user_option_2] = nil
    expect(UserOption.by_user(:dba)[:user_option_2]).to be_nil
    expect(UserOption::Model.count).to eq 0
  end

  it "if user specified - return his option" do
    UserOption[:user_option_3] = "default"
    expect(UserOption.by_user(:dba)[:user_option_3]).to eq "default"

    UserOption.by_user(:dba)[:user_option_3] = "dba"
    expect(UserOption.by_user(:dba)[:user_option_3]).to eq "dba"

    expect(UserOption[:user_option_3]).to eq "default"
  end
end
