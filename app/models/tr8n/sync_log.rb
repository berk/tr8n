#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
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
  set_table_name :tr8n_sync_logs
  
  def self.sync(opts = {})
    access_token
    
    sync_log = Tr8n::SyncLog.create(:started_at => Time.now)

    translation_count = 0
    payload = []
    batch_count = 0
    total_key_count = 0
    
    log("Begin synchronization process...")
    log("Registering keys...")
    
    conditions = "synced_at is null or updated_at > synced_at"
    conditions = nil if opts[:force]

    # STDOUT.sync = true
    
    Tr8n::TranslationKey.find_each(:conditions => conditions, :batch_size => Tr8n::Config.synchronization_batch_size) do |key|
      total_key_count += 1
      sync_hash = key.to_sync_hash
      payload << sync_hash

      key.mark_as_synced!
      
      # if sync_hash["label"] == "you have {count||message}"
      #   payload << sync_hash
      # end  
      
      if payload.size == Tr8n::Config.synchronization_batch_size
        log("Sending #{batch_count+1} batch of #{Tr8n::Config.synchronization_batch_size} keys...")
        batch_count += 1
        exchange(payload)
        payload = []
      end
    end

    if payload.size > 0
      # pp "Sending final batch..."
      batch_count += 1
      exchange(payload, opts)
    end

    sync_log.keys_sent = total_key_count
    
    log("Sent #{total_key_count} keys in #{batch_count} batches.")

    batch_count = 0
    total_key_count = 0
    
    unless opts[:force]
      log("Downloading translations...")

      key_count = download
      while key_count > 0
        batch_count += 1
        total_key_count += key_count
        key_count = download(opts)
      end
      log("Downloaded #{total_key_count} keys in #{batch_count} batches.")
    end

    sync_log.keys_received = total_key_count
    sync_log.finished_at = Time.now
    sync_log.save
    
  rescue Exception => ex  
    log_error(ex)
    pp ex.backtrace
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
  
  def self.exchange(payload, opts = {})
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/application/sync")
    params = {:method => "register", :batch_size => Tr8n::Config.synchronization_batch_size, :translation_keys => payload}
    
    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{access_token}"
    req.body = params.to_json

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

  def self.download(opts = {})
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/application/sync")
    params = {:method=>"download", :batch_size => Tr8n::Config.synchronization_batch_size}
    params[:force] = true if opts[:force]
    
    req = Net::HTTP::Post.new(uri.path)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{access_token}"
    req.body = params.to_json

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end

    if response.is_a?(Net::HTTPInternalServerError)
      raise Exception.new("Failed to download translations: #{response.body}")
    end
    
    raise Tr8n::Exception.new("Synchronization failed") unless response.is_a?(Net::HTTPOK)
    
    data = HashWithIndifferentAccess.new(JSON.parse(response.body))
    # pp data
    
    data[:translation_keys].each do |tkey_hash|
      # pp tkey_hash
      tkey, translations = Tr8n::TranslationKey.create_from_sync_hash(tkey_hash, Tr8n::Config.system_translator)
      tkey.mark_as_synced!
    end
    
    data[:translation_keys].size
  end
  
  def self.log(msg)
    pp "#{Time.now}: #{msg}"
  end

  def self.log_error(msg)
    pp "Error: #{msg}"
  end
  
end
