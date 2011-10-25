#--
# Copyright (c) 2010-2011 Michael Berkovich, tr8n.net
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

class Tr8n::SyncLog < ActiveRecord::Base
  
  def self.sync
    log = Tr8n::SyncLog.create(:started_at => Time.now)
    key_count = 0
    translation_count = 0
    payload = []
    Tr8n::TranslationKey.find_each(:batch_size => Tr8n::Config.synchronization_batch_size) do |key|
      key_count += 1
      
      payload << key.to_api_hash

      puts "*"
      
      if key_count % Tr8n::Config.synchronization_batch_size == 0
        exchange(payload)
      end
    end
    log.update_attributes(:finished_at => Time.now)
  rescue Exception => ex  
    pp ex.message
  end
  
  def self.access_token
    @access_token ||= begin
      uri = URI.parse("#{Tr8n::Config.synchronization_server}/platform/oauth/request_token?client_id=#{Tr8n::Config.synchronization_key}&client_secret=#{Tr8n::Config.synchronization_secret}&grant_type=client_credentials")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)
      raise Tr8n::Exception.new("Failed to get access token") unless data["access_toke"]
      data["access_token"]
    end
  end
  
  def self.exchange(payload)
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/sync")
    
    req = Net::HTTP::Post.new(uri.path)
    req.body = JSON.generate({:translation_keys => payload})
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{access_token}"

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.start {|htt| htt.request(req)}
    raise Tr8n::Exception.new("Synchronization failed") unless response.status == 200
    
    data = JSON.parse(response.body)
    
    data[:translation_keys].each do |tkey_hash|
      Tr8n::TranslationKey.create_from_api_hash(tkey_hash, Tr8n::Config.system_translator)
    end
  end
  
end