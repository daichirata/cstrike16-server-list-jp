# $Id: whereip.rb 111 2006-06-22 06:07:58Z macks $
#
# WhereIP
#
# Copyright (C) 2006 macks
# You can redistribute it and/or modify it under the terms of
# the GNU General Public License version 2 or any later version.
#

class WhereIP

  Record = Struct.new(:addr_begin, :addr_end, :cc)

  def self.load(dbfile)
    self.new(dbfile).load
  end

  def initialize(dbfile)
    @dbfile = dbfile
    @records = nil
  end

  def load
    @records = Marshal.load(File.open(@dbfile, 'rb') {|f| f.read})
    self
  end

  def update(filenames = [])
    if File.exist?(@dbfile)
      raise "#{@dbfile}: Permission denied" if not File.writable?(@dbfile)
    else
      File.open(@dbfile, 'w') {}
    end

    @records = []

    filenames.each do |filename|
      File.open(filename) do |f|
	f.each do |line|
	  next if line =~ /^\s*#/ 
	  registry, cc, type, start, value, date, status, ext = *line.chomp!.split(/\|/)
	  next unless status =~ /allocated|assigned/
	  next unless type == 'ipv4'

	  addr_begin = start.split(/\./).inject(0) {|a,b| a * 256 + b.to_i}
	  addr_end = addr_begin + value.to_i - 1

	  @records << Record.new(addr_begin, addr_end, cc)
	end
      end
    end

    @records = @records.sort_by {|r| r.addr_begin}

    File.open(@dbfile, 'wb') do |f|
      f.write Marshal.dump(@records)
    end
  end

  def match(string)
    raise if not @records
    if string =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
      addr = [$1, $2, $3, $4].inject(0) {|a, b| a * 256 + b.to_i}
      record = bsearch(@records) {|r|
	if r.addr_begin > addr
	  1
	elsif r.addr_end >= addr
	  0
	else
	  -1
	end
      }
      record && record.cc
    else
      nil
    end
  end

  private

  def bsearch(array, &block)
    startpos, endpos = 0, array.size - 1
    while startpos <= endpos
      pos = (startpos + endpos) / 2
      case yield(array[pos])
      when -1
	startpos = pos + 1
      when 0
	return array[pos]
      when 1
	endpos = pos - 1
      else
	raise TypeError, "block must return -1, 0 or 1."
      end
    end
    nil
  end


end # WhereIP
