require 'spec_helper'

describe User do
  describe "validations" do
    subject(:user) { build(:user) }
    it { should be_valid }

    describe "with no uid" do
      before do
        user.uid = nil
      end
      it { should be_invalid }
    end

    describe "with a duplicate uid" do
      before do
        user.uid = create(:user).uid
      end
      it { should be_invalid }
    end
  end
end
