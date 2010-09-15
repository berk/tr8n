namespace :tr8n do
  desc "Sync extra files from tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config/tr8n ./config"
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env)
    Tr8n::Config.reset_all!
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
  
  # for old Geni languages only
  task :fix_languages => :environment do
    {"ay-BO"  => "ay",
    "en-CAN"  => "en-CA",
    "eo-EO"   => "eo",
    "fo-FO"   => "fo",
    "fr-CAN"  => "fr-CA",
    "gn-PY"   => "gn",
    "gu-IN"   => "gu",
    "iw"      => "he",
    "jv-ID"   => "jw",
    "kz"      => "kk",
    "kl"      => "tlh",
    "mg-MG"   => "mg",
    "mr-IN"   => "mr",
    "ps-AF"   => "ps",
    "qu-PE"   => "qu",
    "rm-CH"   => "rm",
    "sa-IN"   => "sa",
    "ta-IN"   => "ta",
    "xh-ZA"   => "xh",
    "zu-ZA"   => "zu"}.each do |old_locale, new_locale|
      lang = Tr8n::Language.for(old_locale)
      next unless lang
      lang.locale = new_locale
      lang.save
      
      # FOR GENI ONLY - REMOVE AFTER USE
      lang.language_users.each do |luser|
        next unless luser.user
        next unless luser.user.language == old_locale
        luser.user.language = new_locale 
        luser.user.save
      end
    end
  end
  
  task :deprecate_keys => :environment do
    used_keys = {}
    
    puts "Running deprecation process..."
    t0 = Time.now

    puts "Scanning log file..."
    counter = 1
    file = File.new(Tr8n::KeyLogger.logfile_path, "r")
    while (key_line = file.gets)
      key_id = key_line.strip
      used_keys[key_id] ||= 0
      used_keys[key_id] += 1
      counter += 1
      
      puts "Scanned #{counter} lines..." if counter % 100 == 0
    end
    file.close
    t1 = Time.now
    puts "Scanned #{used_keys.keys.size} unique keys"
    puts "Scanning process took #{t1-t0} mls"
    
    puts "Deprecating keys..."
    puts "There are #{Tr8n::TranslationKey.count} keys in the system"
    
    deprecate_count = 0
    undeprecate_count = 0
    Tr8n::TranslationKey.all.each do |tkey|
      key_id = tkey.id.to_s
      if used_keys[key_id]
        if tkey.deprecated?
          tkey.undeprecate!
          undeprecate_count += 1
        end
      else
        unless tkey.deprecated?
          tkey.deprecate!
          deprecate_count += 1
        end
      end
    end
    
    t2 = Time.now
    puts "Deprecated #{deprecate_count} keys and undeprecated #{undeprecate_count} keys"
    puts "Deprecation process took #{t2-t1} mls"
  end  
  
  # will delete all keys deprecated prior to the date passed as a parameter
  task :delete_deprecated_keys => :environment do
    date = env('before') || Date.today
    
    puts "Running deprecation destruction process..."
    t0 = Time.now
    
    puts "All keys deprecated before #{date} will be destroyed!"
    deprecated_keys = Tr8n::TranslationKey.find(:all, :conditions => ["deprecated_at is not null and deprecated_at < ?", date])
    
    puts "There are #{deprecated_keys.size} keys to be destroyed."
    puts "Destroying deprecated keys..." if deprecated_keys.size > 0

    destroy_count = 0
    deprecated_keys.each do |tkey|
      tkey.destroy
      destroy_count += 1
      puts "Destroyed #{destroy_count} keys..." if destroy_count % 100 == 0
    end
    
    t1 = Time.now
  
    puts "Destroyed #{destroy_count} keys"
    puts "Destruction process took #{t1-t0} mls"
  end
  
end