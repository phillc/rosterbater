require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) { build(:user) }
    it { should be_valid }

    describe "with no yahoo_uid" do
      before do
        user.yahoo_uid = nil
      end
      it { should be_invalid }
    end

    describe "with a duplicate yahoo_uid" do
      before do
        user.yahoo_uid = create(:user).yahoo_uid
      end
      it { should be_invalid }
    end
  end
end
