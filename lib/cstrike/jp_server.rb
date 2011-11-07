require './whereip'
require 'steam-condenser'

module CStrike
  module JPServer
    DEFAULT_DBFILE = "../../cache/whereip.db"

    def self.jp?(server)
      @whereip.match(server) == "JP" ? true : false
    end

    def self.cache
      @whereip ||= WhereIP.load(DEFAULT_DBFILE)
      master = MasterServer.new(*MasterServer::GOLDSRC_MASTER_SERVER)
      servers = master.servers(MasterServer::REGION_ASIA, '\gamedir\cstrike')
      servers.select{|s| jp?(s[0]) }
    end
  end
end

p CStrike::JPServer::cache
