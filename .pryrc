#!/usr/bin/env ruby

def phillc
  @phillc ||= User.find_by(yahoo_uid: "JBAMN3TTXS5EN3SAWHYJKRRGNU")
end

def phillc_service
  YahooService.new(phillc)
end

