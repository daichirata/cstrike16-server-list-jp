require "socket"
require 'steam-condenser'
require 'dalli'
require File.expand_path('whereip', File.dirname(__FILE__))

module CStrike
  module JPServer
    DEFAULT_DBFILE = File.expand_path(File.join("..", "..", "cache", "whereip.db"), File.dirname(__FILE__))
    UDP_RECV_TIMEOUT = 3

    Settings = Struct.new(:server_name, :map, :game_directory,
                          :game_description, :appID, :number_players,
                          :maximum_players, :number_bots, :dedicated,
                          :os, :password, :secure, :game_version)

    @dc = Dalli::Client.new

    class << self
      def jp?(server)
        @whereip.match(server) == "JP" ? true : false
      end

      def cache
        @whereip  ||= WhereIP.load(DEFAULT_DBFILE)
        master    = MasterServer.new(*MasterServer::GOLDSRC_MASTER_SERVER)
        servers   = master.servers(MasterServer::REGION_ASIA, '\gamedir\cstrike')
        jp_server = Hash[*servers.select{|s| jp?(s[0]) }.flatten]
        @dc.set('jp_server', jp_server)
      end

      def list
        servers, result = @dc.get('jp_server'), []
        servers.each do |host, port|
          if data = query(host, port)
            result << data
          end
        end
        return result
      end

      def query(host, port = 27015)
        host, port = host.to_s, port.to_i
        sock = UDPSocket.open
        sock.send("\377\377\377\377TSource Engine Query\0", 0,host,port)
        resp = if select([sock], nil, nil, UDP_RECV_TIMEOUT)
                 sock.recvfrom(65536)
               end

        if resp.nil?
          return nil
        else
          data = resp[0].unpack('@6Z*Z*Z*Z*vcccaaccZ*')
          return nil if data[0] == "27.0.0.1:27015" || data[0] == ""

          server_info = Settings.new(data[0],data[1],data[2],data[3],data[4],data[5],
                                     data[6],data[7],data[8],data[9],data[10],data[11],
                                     data[12])
          return server_info
        end
      end
    end
  end
end
