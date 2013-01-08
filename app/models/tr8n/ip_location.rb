#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#
#-- Tr8n::IpLocation Schema Information
#
# Table name: tr8n_ip_locations
#
#  id            INTEGER        not null, primary key
#  low           integer(8)     
#  high          integer(8)     
#  registry      varchar(20)    
#  assigned      date           
#  ctry          varchar(2)     
#  cntry         varchar(3)     
#  country       varchar(80)    
#  created_at    datetime       
#  updated_at    datetime       
#
# Indexes
#
#  index_tr8n_ip_locations_on_high    (high) 
#  index_tr8n_ip_locations_on_low     (low) 
#
#++

class Tr8n::IpLocation < ActiveRecord::Base
  self.table_name = :tr8n_ip_locations
  
  attr_accessible :low, :high, :registry, :assigned, :ctry, :cntry, :country

  def self.no_country_clause
    %q{COALESCE(country, 'ZZZ') = 'ZZZ'}
  end

  def self.find_by_ip(ip)
    ip = case ip
      when String
        Tr8n::IpAddress.new(ip).to_i
      else
        ip.to_i
    end
    first(:conditions => ['low <= ? AND ? <= high', ip, ip]) || new.freeze
  rescue ArgumentError
    puts "Invalid ip: #{ip}" unless Rails.env.test?
    new.freeze
  end

  def blank?
    new_record? || 'ZZZ' == cntry
  end

  def self.import_from_file(file, opts = {})
    opts ||= {:verbose => true}
    puts "Deleting old records..." if opts[:verbose]
    delete_all
    puts "Done." if opts[:verbose] 
    puts "Importing new records..."  if opts[:verbose]

    file = File.open(file) if file.is_a?(String)
    index = 0
    file.each_line do |line|
      begin
        next if line =~ /^\s*\#|^\s*$/
        line.chomp!.tr!('"\'','')
        values = line.split(',')
        create!(
          :low      =>  values[0],
          :high     =>  values[1],
          :registry =>  values[2],
          :assigned =>  Time.at(values[3].to_i),
          :ctry     =>  values[4],
          :cntry    =>  values[5],
          :country  =>  values[6]
        )
        index += 1
        pp "Imported #{index} locations" if opts[:verbose] and (index+1) % 1000 == 0
      rescue Exception => e
        pp line, e
      end
    end

    pp "Done. Imported #{count} locations" if opts[:verbose]
  end
  
end
