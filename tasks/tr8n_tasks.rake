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
  
end