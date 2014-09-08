#!/usr/bin/env ruby

def phillc
  @phillc ||= User.find_by(yahoo_uid: "JBAMN3TTXS5EN3SAWHYJKRRGNU")
end

