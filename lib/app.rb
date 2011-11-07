require 'sinatra'
require 'steam-condenser'
$: << File.dirname(__FILE__) + '/lib'
require 'whereip'

module CStrike
  File.expand_path('..', File.dirname(__FILE__))
  DEFAULT_DBFILE = "#{APP_ROUTE}/cache/whereip.db"



master = MasterServer.new(*MasterServer::GOLDSRC_MASTER_SERVER)
servers = master.servers(MasterServer::REGION_ASIA, '\gamedir\cstrike')

servers.each do |s|
  puts s[0]
end

get '/' do
  'Hello world!'
end

whereip = WhereIP.load(DEFAULT_DBFILE)



def match(whereip, str, prefix = nil)
  print prefix if prefix
  if cc = whereip.match(str)
    puts "#{cc}: #{ISO3166::MAP[cc]}"
  else
    puts "Unknown"
  end
end

if ARGV.empty?
  interactive = $stdin.stat.chardev? && $stdout.stat.chardev?
  puts "initialized" if interactive
  while line = $stdin.gets
    prefix = "#{line.chomp}: " if not interactive
    match(whereip, line, prefix)
  end
elsif ARGV.size == 1
  match(whereip, ARGV[0])
else # ARGV.size > 1
  ARGV.each do |address|
    match(whereip, address, "#{address}: ")
  end
end

