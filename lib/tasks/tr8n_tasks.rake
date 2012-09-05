namespace :tr8n do
  desc "Sync config and db migrations for tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config/tr8n ./config"
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end

  desc "Sync db migrations for tr8n plugin."
  task :sync_db do
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and ENV['force'] != 'true'
    Tr8n::Config.reset_all!
  end
  
  desc "Switches from manager flag to levels approach"
  task :upgrade_managers => :environment do
    # both of the following management approaches are deprecated, now use level only
    Tr8n::LanguageUser.find(:all, :conditions => "manager = true").each do |lu|
      next unless lu.translator
      lu.translator.update_attributes(:level => Tr8n::Config.manager_level)
    end
    Tr8n::Translator.connection.execute("update tr8n_translators set level = #{Tr8n::Config.manager_level} where manager = true")
  end
  
  desc "Adds missing languages from the yml file"
  task :import_languages => :environment do
    Tr8n::Config.default_languages.each do |locale, info|
      lang = Tr8n::Language.for(locale)
      next if lang
      
      info[:right_to_left] = false if info[:right_to_left].nil?
      info[:locale] = locale
      info[:enabled] = false
      lang = Tr8n::Language.create(info)
      
      lang.reset!
    end
  end

  desc "Updates languages with missing keys"
  task :update_language_keys => :environment do
    Tr8n::Config.default_languages.each do |locale, info|
      lang = Tr8n::Language.for(locale)
      next unless lang
      
      lang.google_key = info[:google_key] 
      lang.facebook_key = info[:facebook_key] 
      lang.save      
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
  
  task :rtl_languages => :environment do
    File.open('rtllanguages.yml', 'w') do |f| 
      Tr8n::Language.find(:all, :conditions => ["right_to_left = ?", true], :order => "english_name asc").each do |l|
        f.puts("\"#{l.locale}\":\n")
      end
    end
  end
  
  task :export_languages => :environment do
    File.open('languages.yml', 'w') do |f| 
      Tr8n::Language.find(:all, :order => "english_name asc").each do |l|
        f.puts("\"#{l.locale}\":\n")
        f.puts("\tenglish_name: \"#{l.english_name}\"\n")
        f.puts("\tnative_name: \"#{l.native_name}\"\n")
        f.puts("\tgoogle_key: \"#{l.google_key}\"\n")
        f.puts("\tfacebook_key: \"#{l.facebook_key}\"\n")
      end
    end
  end
  
  task :configure_fallbacks => :environment do
    Tr8n::Language.all.each do |lang|
      locale = lang.locale
      next unless locale.index("-")
      fallback_locale = locale.split("-").first
      lang.fallback_language = Tr8n::Language.for(fallback_locale)
      lang.save
    end
  end
  
  task :verify_keys => :environment do
    used_keys = {}
    
    # verification timestamp
    v_time = Time.now
    
    puts "Running verification process..."
    t0 = Time.now

    log_path = Tr8n::KeyLogger.logfile_path
    
    puts "Looking up log file at location..."
    puts "File path: #{log_path}"
   
    unless File.exists?(log_path)
      puts "Log file not found. Key logging process is not running."
      return 
    end

    puts "Log file found. Renaming log file..."
    new_log_path = Tr8n::KeyLogger.switch_log(v_time)
    puts "Renamed file path: #{new_log_path}"
    
    puts "Scanning log file..."
    
    counter = 1
    file = File.new(new_log_path, "r")
    while (key_line = file.gets)
      key_id = key_line.strip
      used_keys[key_id] = true
      counter += 1
      
      puts "Scanned #{counter} lines..." if counter % 100 == 0
    end
    file.close
    t1 = Time.now
    puts "Scanned #{used_keys.keys.size} unique keys"
    puts "Scanning process took #{t1-t0} mls"
    
    puts "Marking keys as verified..."
    puts "There are #{Tr8n::TranslationKey.count} keys in the system"
    
    verify_count = 0 
    used_keys.keys.each do |key|
      tkey = Tr8n::TranslationKey.find_by_id(key)
      next unless tkey
      tkey.verify!(v_time)
      verify_count += 1
    end
    
    t2 = Time.now
    puts "Verified #{verify_count} keys"
    puts "Verification process took #{t2-t1} mls"
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
  
  desc 'imports language cases'
  task :import_language_cases => :environment do
    Tr8n::Config.init_language_cases
  end

  desc 'imports relationship keys'
  task :import_relationship_keys => :environment do
    Tr8n::Config.init_relationship_keys
  end

  desc 'imports configuration keys'
  task :import_configuration_keys => :environment do
    Tr8n::Config.init_configuration_keys
  end

  desc 'delete translations without keys'
  task :delete_orphan_translations => :environment do
    trns = Tr8n::Translation.find(:all, :conditions => "translation_key_id not in (select tr8n_translation_keys.id from tr8n_translation_keys)")
    puts "Deleting #{trns.count} translations..."
    
    trns.each do |trn|
      trn.destroy
    end
    
    puts "Done."
  end
    
  desc 'syncs up translations'
  task :exchange => :environment do
    opts = {}
    opts[:force] = true if ENV["force"] == "true"
    Tr8n::SyncLog.sync(opts)
  end
  
end