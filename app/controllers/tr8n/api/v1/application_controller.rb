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

###########################################################################
## API for getting translations from the main server
###########################################################################

class Tr8n::Api::V1::ApplicationController < ActionController::Base
  unloadable

  # for ssl access to the translator - using ssl_requirement plugin  
  ssl_allowed :sync  if respond_to?(:ssl_allowed)

  def sync
    ensure_push_enabled

    sync_log = Tr8n::SyncLog.create(:started_at => Time.now, 
                                    :keys_received => 0, :translations_received => 0, 
                                    :keys_sent => 0, :translations_sent => 0)

    method = params[:method] || "push"
    
    payload = []
    
    if method == "push"
      payload = push_translations(sync_log)
    
    elsif method == "pull"
      payload = pull_translations(sync_log)
      
    end

    sync_log.finished_at = Time.now
    sync_log.save
    
    sanitize_api_response(:translation_keys => payload)    
  rescue Tr8n::Exception => ex
    sanitize_api_response("error" => ex.message)    
  end

private

  def ensure_push_enabled
    raise Tr8n::Exception.new("Push is disabled") unless Tr8n::Config.synchronization_push_enabled?
    raise Tr8n::Exception.new("Unauthorized server push attempt") unless Tr8n::Config.synchronization_push_servers.include?(request.env['REMOTE_HOST'])
  end
  
  def translator
    @translator ||= Tr8n::Config.system_translator
  end
  
  def languages
    @languages ||= Tr8n::Language.enabled_languages
  end
  
  def batch_size
    @batch_size ||= Tr8n::Config.synchronization_batch_size
  end
  
  def push_translations(sync_log, opts = {})
    payload = []

    # already parsed by Rails
    # keys = JSON.parse(params[:translation_keys])
    keys = params[:translation_keys]
    return payload unless keys
  
    sync_log.keys_received += keys.size
  
    keys.each do |tkey_hash|
      # pp tkey_hash
      tkey, remaining_translations = Tr8n::TranslationKey.create_from_sync_hash(tkey_hash, translator)
      next unless tkey

      sync_log.translations_received += tkey_hash[:translations].size if tkey_hash[:translations]
      sync_log.translations_sent += remaining_translations.size

      tkey.mark_as_synced!
    
      payload << tkey.to_sync_hash(:translations => remaining_translations, :languages => languages)
    end
    
    payload
  end
  
  def pull_translations(sync_log, opts = {})
    payload = []
  
    # find all keys that have changed since the last sync
    changed_keys = Tr8n::TranslationKey.where("synced_at is null or updated_at > synced_at").limit(batch_size)
    sync_log.keys_sent += changed_keys.size
    
    changed_keys.each do |tkey|
      tkey_hash = tkey.to_sync_hash(:languages => languages)
      payload << tkey_hash
      sync_log.translations_sent += tkey_hash["translations"].size if tkey_hash["translations"]
      tkey.mark_as_synced!
    end
    
    payload
  end  
  
  def sanitize_api_response(response)
    if Tr8n::Config.api[:response_encoding] == "xml"
      render(:text => response.to_xml)
    else
      render(:json => response.to_json)
    end      
  end
  
end