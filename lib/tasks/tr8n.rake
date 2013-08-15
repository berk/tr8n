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

namespace :tr8n do
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env)
    Tr8n::Config.reset_all!
  end

  desc "Export languages"
  task :export_languages => :environment do
    path = ENV['path'] || 'config/tr8n/languages'
    FileUtils.mkdir_p(path)

    proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&proc); nil) : (v.nil? or (v.is_a?(String) and v.blank?) or (v === false)) }

    Tr8n::Language.all.each do |lang|
      pp "Exporting #{lang.locale}..."
      file_path = path + "/" + lang.locale + ".json"
      File.open(file_path, 'w') do |file|
        json = lang.to_api_hash(:definition => true)
        json.delete_if(&proc)
        file.write(JSON.pretty_generate(json))
      end
    end
  end

  desc "Resets all metrics"
  task :reset_metrics => :environment do
    Tr8n::LanguageMetric.reset_metrics
  end

  desc "Calculates metrics"
  task :metrics => :environment do
    Tr8n::LanguageMetric.calculate_language_metrics
  end

  desc "Initializes default language cases"
  task :language_cases => :environment do
    Tr8n::Language.all.each do |lang|
      lang.reset_language_cases!
    end 
  end

  desc "Creates featured languages"
  task :featured_languages => :environment do
    Tr8n::Config.config[:featured_languages].each_with_index do |locale, index|
      lang = Tr8n::Language.for(locale)
      lang.featured_index = 10000 - (index * 100)
      lang.save
    end
  end
  
  # will delete all keys that have not been verified in the last 2 weeks
  task :delete_unverified_keys => :environment do
    date = env('before') || (Date.today - 2.weeks)
    
    puts "Running key destruction process..."
    t0 = Time.now
    
    puts "All keys not verified after #{date} will be destroyed!"
    unverified_keys = Tr8n::TranslationKey.find(:all, :conditions => ["verified_at is null or verified_at < ?", date])
    
    puts "There are #{unverified_keys.size} keys to be destroyed."
    puts "Destroying unverified keys..." if unverified_keys.size > 0

    destroy_count = 0
    unverified_keys.each do |tkey|
      tkey.destroy
      destroy_count += 1
      puts "Destroyed #{destroy_count} keys..." if destroy_count % 100 == 0
    end
    
    t1 = Time.now
  
    puts "Destroyed #{destroy_count} keys"
    puts "Destruction process took #{t1-t0} mls"
  end
  
  desc 'Update IP to Location table (file=<file|config/tr8n/data/ip_locations.csv>)'
  task :import_ip_locations => :environment do
    Tr8n::IpLocation.import_from_file('config/tr8n/data/ip_locations.csv', :verbose => true)
  end
  
  desc "Synchronize translations with tr8n.net"
  task :sync => :environment do
    opts = {}
    opts[:force] = true if ENV["force"] == "true"
    Tr8n::SyncLog.sync(opts)
  end
end