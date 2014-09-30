class OddsService
  include HTTParty
  def get_odds
    get_and_parse "http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=Football&sportsubtype=NFL"
  end

  def events
    doc = get_odds
    doc.search("event").map{ |event_doc| OddsEvent.new(event_doc) }
  end

  protected

  def get(url)
    self.class.get(url).body
  end

  def get_and_parse(url)
    Nokogiri::XML(get(url))
  end

  class OddsEvent
    def initialize(doc)
      @doc = doc
    end
  end
end

