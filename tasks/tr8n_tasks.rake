namespace :tr8n do
  desc "Sync extra files from tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config/tr8n ./config"
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    Tr8n::Config.reset_all!
  end
  
  desc "Adds missing languages from the yml file"
  task :update_languages => :environment do
    Tr8n::Config.default_languages.each do |locale, info|
      lang = Tr8n::Language.for(locale)
      next if lang
      
      info[:right_to_left] = false if info[:right_to_left].nil?
      info[:locale] = locale
      info[:enabled] = true
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
      lang.users.each do |luser|
        next unless luser.user
        next unless luser.user.language == old_locale
        luser.user.language = new_locale 
        luser.user.save
      end
    end
  end
  
end