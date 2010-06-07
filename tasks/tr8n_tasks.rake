namespace :tr8n do
  desc "Sync extra files from tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config ."
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    Tr8n::Config.reset_all!
  end
  
  task :update_languages => :environment do
    {"am" => "hy", "gs" => "ka", "eu_ES" => "eu", "ur_PK" => "ur"}. each do |old, new|
      lang = Tr8n::Language.for(old)
      next unless lang
      lang.update_attributes(:locale => new)
    end
    Tr8n::Language.all.each do |lang|
      next unless lang.locale.index("_")
      lang.update_attributes(:locale => lang.locale.gsub("_", "-"))
    end
  end
  
  task :clean_icons => :environment do
    Tr8n::Language.all.each do |lang|
      FileUtils.cp("#{RAILS_ROOT}/public/images/tr8n/flags/#{lang.flag}.png", "#{RAILS_ROOT}/public/images/tr8n/flags/used/#{lang.flag}.png")
    end
  end

  task :reset_metrics => :environment do
    Tr8n::LanguageMetric.reset_metrics
  end

  task :metrics => :environment do
    Tr8n::LanguageMetric.calculate_language_metrics
  end

  task :featured => :environment do
    ["en-US", "es", "pt", "fr", "de", "it", "ru", "et", "iw", "zh-TW"].each_with_index do |locale, index|
      lang = Tr8n::Language.for(locale)
      lang.featured_index = (index + 1) * 100
      lang.save
    end
  end
  
end