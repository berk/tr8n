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
#-- Tr8n::SyncLog Schema Information
#
# Table name: tr8n_sync_logs
#
#  id                       INTEGER     not null, primary key
#  started_at               datetime    
#  finished_at              datetime    
#  keys_sent                integer     
#  translations_sent        integer     
#  keys_received            integer     
#  translations_received    integer     
#  created_at               datetime    
#  updated_at               datetime    
#
# Indexes
#
#
#++

class Tr8n::SyncLog < ActiveRecord::Base
  self.table_name = :tr8n_sync_logs

  attr_accessible :started_at, :finished_at, :keys_sent, :translations_sent, :keys_received, :translations_received

  def self.sync(opts = {})
    sync_log = Tr8n::SyncLog.create(:started_at => Time.now, 
                                    :keys_received => 0, :translations_received => 0, 
                                    :keys_sent => 0, :translations_sent => 0)
    sync_log.sync(opts)
    sync_log
  end
  
  def sync(opts = {})
    access_token

    translation_keys = []
    batch_count = 0
    
    log("Begin synchronization process...")
    log("Pushing keys...")
    
    conditions = "synced_at is null or updated_at > synced_at"
    conditions = nil if opts[:force]

    # STDOUT.sync = true
    
    languages = Tr8n::Language.enabled_languages
    total_key_count = Tr8n::TranslationKey.count(:conditions => conditions)
    log("#{total_key_count} translation keys will be synchronized with the remote server in chunks of #{batch_size} keys...")
    
    Tr8n::TranslationKey.find_each(:conditions => conditions, :batch_size => batch_size) do |key|
      self.keys_sent += 1
      tkey_hash = key.to_sync_hash(:languages => languages)
      self.translations_sent += tkey_hash["translations"].size if tkey_hash["translations"]
      translation_keys << tkey_hash

      key.mark_as_synced!
      
      # if sync_hash["label"] == "you have {count||message}"
      #   payload << sync_hash
      # end  
      
      if translation_keys.size >= Tr8n::Config.synchronization_batch_size
        batch_count += 1
        push_translations(translation_keys, opts)
        translation_keys = []
        log("Sent #{self.keys_sent} keys and #{self.translations_sent} translations.")
      end
    end

    if translation_keys.size > 0
      batch_count += 1
      push_translations(translation_keys, opts)
      log("Sent #{self.keys_sent} keys with #{self.translations_sent} translations.")
    end
    
    log("Done. Sent #{total_key_count} keys with #{self.translations_sent} translations in #{batch_count} calls.")

    batch_count = 0
    
    unless opts[:force]
      log("Pulling translations...")

      key_count = pull_translations(opts)
      while key_count > 0
        batch_count += 1
        key_count = pull_translations(opts)
      end
      log("Done. Downloaded #{self.translations_received} keys with #{self.translations_received} translations.")
    end

    self.finished_at = Time.now
    save
  rescue Exception => ex  
    log_error(ex)
    # pp ex.backtrace
  end
  
  def access_token
    @access_token ||= begin
      uri = URI.parse("#{Tr8n::Config.synchronization_server}/platform/oauth/request_token?client_id=#{Tr8n::Config.synchronization_key}&client_secret=#{Tr8n::Config.synchronization_secret}&grant_type=client_credentials")
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)
      raise Tr8n::Exception.new("Failed to get access token") unless data["access_token"]
      data["access_token"]
    end
  end
  
  def batch_size
    @batch_size ||= Tr8n::Config.synchronization_batch_size
  end
  
  def translator 
    @translator ||= Tr8n::Config.system_translator
  end
  
  def push_translations(payload, opts = {})
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/application/sync")
    params = {:method => "push", :batch_size => batch_size, :translation_keys => payload}
    
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
    return unless data[:translation_keys]
    
    # pp data
    self.keys_received += data[:translation_keys].size
    
    data[:translation_keys].each do |tkey_hash|
      # pp tkey_hash
      self.translations_received += tkey_hash["translations"].size if tkey_hash["translations"]
      Tr8n::TranslationKey.create_from_sync_hash(tkey_hash, translator)
    end
  end

  def pull_translations(opts = {})
    uri = URI.parse("#{Tr8n::Config.synchronization_server}/api/application/sync")
    params = {:method=>"pull", :batch_size => batch_size}
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
    return 0 unless data[:translation_keys]

    self.keys_received += data[:translation_keys].size
    
    data[:translation_keys].each do |tkey_hash|
      self.translations_received += tkey_hash["translations"].size if tkey_hash["translations"]
      tkey, translations = Tr8n::TranslationKey.create_from_sync_hash(tkey_hash, translator)
      tkey.mark_as_synced!
    end
    
    data[:translation_keys].size
  end
  
  def log(msg)
    pp "#{Time.now}: #{msg}"
  end

  def log_error(msg)
    pp "Error: #{msg}"
  end
  
end
