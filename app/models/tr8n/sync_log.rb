#--
# Copyright (c) 2010-2011 Michael Berkovich
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
    sync_batch_size = 100
    key_count = 0
    translation_count = 0
    payload = []
    Tr8n::TranslationKey.find_each(:batch_size => sync_batch_size) do |key|
      key_count += 1
      
      payload << key.to_api_hash
      
      if key_count % sync_batch_size == 0
        exchange(payload)
      end
    end
    log.update_attributes(:finished_at => Time.now)
  end
  
  def self.exchange(payload)
    uri = URI.parse(endpoint)
    
    req = Net::HTTP::Post.new(uri.path)
    req.body = JSON.generate(post_params)
    req["Content-Type"] = "application/json"

    http = Net::HTTP.new(uri.host, uri.port)
    response = http.start {|htt| htt.request(req)}
  end
  
end