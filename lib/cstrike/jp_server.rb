require "socket"
require 'steam-condenser'
require 'dalli'
require File.expand_path('whereip', File.dirname(__FILE__))

module CStrike
  module JPServer
    DEFAULT_DBFILE = File.expand_path(File.join("..", "..", "cache", "whereip.db"), File.dirname(__FILE__))
    UDP_RECV_TIMEOUT = 3
    MEM_CACHED = Dalli::Client.new

    List = Struct.new(:server_name, :os, :password, :host, :port)
    Info = Struct.new(:server_name, :map, :game_directory,
                      :game_description, :appID, :number_players,
                      :maximum_players, :number_bots, :dedicated,
                      :os, :password, :secure, :game_version, :host, :port)
    class << self
      def jp?(server)
        @whereip.match(server) == "JP" ? true : false
      end

      def cache
        @whereip  ||= WhereIP.load(DEFAULT_DBFILE)
        master    = MasterServer.new(*MasterServer::GOLDSRC_MASTER_SERVER)
        servers   = master.servers(MasterServer::REGION_ASIA, '\gamedir\cstrike')
        MEM_CACHED.set('jp_server', create_list(servers.select!{|s|jp?(s[0])}))
      end

      def get_list
        MEM_CACHED.get('jp_server')
      end

      def get_info(host, port)
        data = query(host, port)
        Info.new(data[0],data[1],data[2],data[3],data[4],data[5],
                 data[6],data[7],data[8],data[9],data[10],data[11],
                 data[12], host, port)
      end

      def create_list(servers, result = [])
        return nil if servers.nil?
        servers.each do |server|
          if data = query(server[0], server[1])
            result << List.new(data[0],data[9],data[10], server[0], server[1])
          end
        end
        return result
      end

      def query(host, port)
        host, port, server_info = host.to_s, port.to_i, nil
        sock = UDPSocket.open
        sock.send("\377\377\377\377TSource Engine Query\0", 0, host, port)
        if select([sock], nil, nil, UDP_RECV_TIMEOUT)
          resp = sock.recvfrom(65536)
          data = resp[0].unpack('@6Z*Z*Z*Z*vcccaaccZ*')
          return nil if data[0].to_s =~ /(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/
          server_info = data
        end
        return server_info
      end
    end
  end
end
