require "rails_helper"

describe OddsService do
  let(:service) { OddsService.new }

  describe "#events" do
    before do
      expect(service).to receive(:get)
                           .and_return(fixture("get_odds.xml"))
                           .at_least(:once)
    end

    it "has the events" do
      expect(service.events.size).to eq(16)
    end
  end
end
