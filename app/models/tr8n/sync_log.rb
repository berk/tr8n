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
    sent_batch_count = 0
    
    Tr8n::TranslationKey.find_each(:conditions => ["synced_at is null or updated_at > synced_at"], :batch_size => Tr8n::Config.synchronization_batch_size) do |key|
      key_count += 1
      sync_hash = key.to_sync_hash
      payload << sync_hash
      
      key.update_attributes(:synced_at => Time.now + 5.seconds)
      
      # if sync_hash["label"] == "Hello World!"
      #   payload << sync_hash
      #   pp sync_hash 
      # end  
      
      if payload.size == Tr8n::Config.synchronization_batch_size
        # pp "Sending #{sent_batch_count+1} batch of #{Tr8n::Config.synchronization_batch_size} keys..."
        sent_batch_count += 1
        exchange(payload)
        payload = []
      end
    end

    if payload.size > 0
      # pp "Sending final batch..."
      sent_batch_count += 1
      exchange(payload)
    end

    log.update_attributes(:finished_at => Time.now)
    
    pp "Sent #{sent_batch_count} batches of #{Tr8n::Config.synchronization_batch_size} keys, totaling #{key_count} keys."
    
  rescue Exception => ex  
    pp ex.message
  end
  
  def self.access_token
    @access_token ||= begin
      uri = URI.parse("#{Tr8n::Config.synchronization_server}/platform/oauth/request_token?client_id=#{Tr8n::Config.synchronization_key}&client_secret=#{Tr8n::Config.synchronization_secret}&grant_type=client_credentials")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)
      raise Tr8n::Exception.new("Failed to get access token") unless data["access_token"]
      data["access_token"]
    end
  end
  
  def self.exchange(payload)
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/application/sync")
    
    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{access_token}"
    req.body = {:translation_keys => payload}.to_json

    # pp payload
    
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    if response.is_a?(Net::HTTPInternalServerError)
      raise Exception.new("Failed to synchronize keys: #{response.body}")
    end
    
    raise Tr8n::Exception.new("Synchronization failed") unless response.is_a?(Net::HTTPOK)
    
    data = HashWithIndifferentAccess.new(JSON.parse(response.body))
    # pp data
    
    data[:translation_keys].each do |tkey_hash|
      # pp tkey_hash
      Tr8n::TranslationKey.create_from_sync_hash(tkey_hash, Tr8n::Config.system_translator)
    end
  end
  
end