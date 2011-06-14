#--
# Copyright (c) 2010-2011 Scott Steadman, Michael Berkovich
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

class Tr8n::IpAddress

  def self.non_routable_networks
    @non_routable_networks ||= [
      Tr8n::IpAddress.new('10.0.0.0/8'),
      Tr8n::IpAddress.new('127.0.0.0/8'),
      Tr8n::IpAddress.new('172.16.0.0/12'),
      Tr8n::IpAddress.new('192.168.0.0/16'),
    ]
  end

  def self.routable?(ip)
    not non_routable?(ip)
  end

  def self.non_routable?(ip)
    return true if ip.blank?
    ip = new(ip.to_s) unless ip.is_a?(Tr8n::IpAddress)
    ip.non_routable?
  rescue ArgumentError
    return true
  end

  def non_routable?
    self.class.non_routable_networks.each {|network| return true if network.include?(self)}
    false
  end

end
